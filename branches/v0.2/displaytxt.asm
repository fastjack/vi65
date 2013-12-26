;
;    VI65 (c) 2010-2013 Soci/Singular (soci@c64.rulez.org)
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;

		.if (TARGET==C64) || (TARGET==PLUGIN)
scr		= $0400
width		= 40
height		= 25
cache		= $334
		.elsif TARGET==VIC20BIG
scr		= $1000
width		= 22
height		= 23
cache		= $334
		.elsif TARGET==VIC20
scr		= $1e00
width		= 22
height		= 23
cache		= $334
		.elsif TARGET==C16
scr		= $0c00
width		= 40
height		= 25
cache		= $333
		.elsif TARGET==PLUS4
scr		= $0c00
width		= 40
height		= 25
cache		= $333
		.elsif (TARGET==PET40) || (TARGET==PET80)
scr		= $8000
		.if TARGET==PET40
width		= 40
		.else
width		= 80
		.fi
height		= 25
cache		= $27a
		.elsif TARGET==C128
scr		= $400
width		= 40
height		= 25
cache		= $0b00
		.elsif TARGET==ATARI800
scr		= $bc40
width		= 40
height		= 24
cache		= $0489
		.elsif TARGET==APPLE2
scr		= $0400
		.if GFX==3
width		= 80
		.else
width		= 40
		.fi
height		= 24
cache		= $0800
		.fi

displayinit	.proc
		ldx #height-1
		lda #255
-		sta paintone.cachec,x
		dex
		bpl -
		lda #statusmsg.banner
		jsr setstatusmsg
		jsr display
		.if (TARGET==C64) || (TARGET==C128) || (TARGET==PLUGIN)
		#kernal
		.if (TARGET==C64) || (TARGET==PLUGIN)
		lda #$80
		sta $291
		.fi
		ldx #c2-c1
-		ldy c1-1,x
		lda c2-1,x
		sta $d000,y
		dex
		bne -
		lda #3-(scr >> 14)
		sta $dd00
		lda #0
-		sta $d800,x
		sta $d900,x
		sta $da00,x
		sta $db00,x
		inx
		bne -
		#ram
		rts

c1		.byte $15, $21, $20, $11, $16, $18
c2		.byte $00, $0f, $06, $1b, $08, ((scr >> 6) & $f0)+6

		.elsif (TARGET==VIC20) || (TARGET==VIC20BIG)
		lda #$80
		sta $291
		lda #$c2
		sta $9005
		lda #$1e
		sta $900f
		ldx #0
		txa
-
		.if TARGET==VIC20BIG
		sta $9400,x
		sta $9500,x
		.else
		sta $9600,x
		sta $9700,x
		.fi
		inx
		bne -
		rts
		.elsif (TARGET==PLUS4) || (TARGET==C16)
		lda #$80
		sta $547
		lda #$61
		sta $ff15
		lda #$06
		sta $ff19
		lda #$1b
		sta $ff06
		lda $ff07
		and #$40
		ora #$08
		sta $ff07
		lda #$d5
		sta $ff13
		lda #>(scr-$400)
		sta $ff14
		sta e+2
		ldx #0
		ldy #4
		lda #$10
e		sta scr-$400,x
		inx
		bne e
		inc e+2
		dey
		bne e
		rts
		.elsif TARGET==APPLE2
		sta $c00f
		.if width==80
		sta $c00d
		.else
		sta $c00c
		.fi
		rts
		.elsif (TARGET==PET40) || (TARGET==PET80)
		rts
		.elsif TARGET==ATARI800
		lda #$70
		sta $2c8		;border
		lda #$00
		sta $2c5		;text
		lda #$0a
		sta $2c6		;background
		rts
		.fi
		.pend

displayexit	.proc
		#kernal
		.if (TARGET==C64) || (TARGET==C128) || (TARGET==PLUGIN)
		lda #147
		jmp chrout
		.elsif (TARGET==C16) || (TARGET==PLUS4)
		lda #147
		jmp chrout
		.elsif (TARGET==PET40) || (TARGET==PET80)
		lda #147
		jmp chrout
		.elsif TARGET==ATARI800
		rts
		.elsif TARGET==APPLE2
		rts
		.fi
		.pend

displaylowinit	.proc
		#loadw scr, screen
		rts
		.pend

displaylow	.proc
		stx paintone.ao+1
		sta paintone.cursorcol+1

		ldx windows.start,y
		lda windows.end,y
		sta leng+1		;length of window

lp		jsr paintone
		ldy #0
		pha (currentline),y
		iny
		lda (currentline),y
		sta currentline+1
		pla currentline

		inx
leng		cpx #height-1
		bne lp
		rts
		.pend

paintone	.proc
		stx u+1
		lda cachec,x
		cmp column2
		bne +
in		lda cachel,x
		cmp currentline
		bne +
		lda cacheh,x
		cmp currentline+1
		bne +
garbagelow	cmp #0
		blt jo
+
		lda column2
		sta cachec,x
		lda currentline
		sta cachel,x
		lda currentline+1
		sta cacheh,x
		lda #$fe-at+m1
		sta at+1
		ldy activewin
		txa
		sec
		sbc windows.start,y
		clc
		adc line2
		tay
		lda #0
		adc line2+1
		cpy lines
		sbc lines+1
		bcc +
		lda #0
		sta ln+1
		tay
		.if TARGET==ATARI800
		lda #"-"^32
		.elsif TARGET==APPLE2
		lda #"~"+128
		.else
		lda #"-"
		.fi
		gne m2
+
		ldy #4
		lda (currentline),y
		sec
		sbc column2
		bge +
		lda #0
+		sta ln+1
		tya
		sec
		adc column2
		adc currentline
		sta currenttext
		lda currentline+1
		adc #0
		sta currenttext+1

		ldy #0
m1		lda (currenttext),y
		.if TARGET==ATARI800
		cmp #$20
		blt e1
		cmp #$40
		blt e2
		cmp #$60
		bge +
		eor #$60^$20
e2		eor #$20^$40
e1		eor #$40
+
		.elsif TARGET==APPLE2
		eor #$80
		.else
		cmp #128
		bcs hi
		cmp #$20
		bcc inv
		cmp #$60
		bcc en
		and #$df
		gcs ei
en		and #$3f
		gpl ei

hi		and #$7f
		cmp #$7f
		bne +
		lda #$5e
+		cmp #$20
		ora #$40
		bcs ei
inv		ora #$80
ei
		.fi

ln		cpy #0
		blt m2
		lda #$fe-at+m2
		sta at+1
		.if TARGET==ATARI800
		lda #32-32
		.elsif TARGET==APPLE2
		lda #32+128
		.else
		lda #32
		.fi
m2
		.if (TARGET==APPLE2) && (width==80)
		tax
		tya
		lsr
		tay
		bcs +
		sta $c001
		bit $c055
+		txa
		.fi
		sta (screen),y
		.if (TARGET==APPLE2) && (width==80)
		bcs +
		bit $c054
		sta $c000
+		tya
		rol
		tay
		txa
		.fi
		iny
		cpy #width
at		blt m1

u		ldx #0
jo
		lda activewin
ao		cmp #0
		bne nc
		lda currentline
		cmp cursorline
		bne nc
		lda currentline+1
		cmp cursorline+1
		bne nc
		lda #255
		sta ao+1
cursorcol	lda #0
		sbc column2
		sta cursor.in+1
		lda screen
		sta cursor.at1+1
		sta cursor.at2+1
		lda screen+1
		sta cursor.at1+2
		sta cursor.at2+2
		lda #0
		jsr cursor.in
		ldx u+1
nc
		.if TARGET==APPLE2
		lda screen
		eor #128
		sta screen
		bmi +
		inc screen+1
		lda screen+1
		and #3
		bne +
		lda #>scr
		sta screen+1
		lda screen
		clc
		adc #40
		sta screen
+
		.else
		lda screen
		clc
		adc #width
		sta screen
		bcc +
		inc screen+1
+
		.fi
		rts

o

		.logical cache
cachec		.fill height
cachel		.fill height
cacheh		.fill height
		.here

		*= o

		.pend

cursoroff	.proc
		lda cursor.on+1
		beq cursor.x
		gne cursor
		.pend

cursor		.proc
on		lda #0
in		ldx #0
		.if (TARGET==APPLE2) && (width==80)
		tay
		txa
		lsr
		bcs +
		sta $c001
		bit $c055
+		tax
		tya
		.fi
		eor #1
		sta on+1
		bne at1
ep		lda #0
		jmp at2

at1		lda scr,x
		sta ep+1
		eor #128
		cmp #64
		blt +
		cmp #96
		bge +
		eor #64
+		ldy tochar.mode+1
		bne +
		.if TARGET==ATARI800
		lda #25+64
		.elsif TARGET==APPLE2
		lda #255
		.else
		lda #97
		.fi
+
size		= *+1
		ldy #128
		bmi at2
		.if TARGET==ATARI800
		lda #21+64
		.elsif TARGET==APPLE2
		lda #255
		.else
		lda #98
		.fi
at2		sta scr,x
		.if (TARGET==APPLE2) && (width==80)
		bcs x
		bit $c054
		sta $c000
		.fi
x		rts

		.pend
