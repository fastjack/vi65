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
width		= 80
height		= 25
scr		= $400
cache		= $334
		.elsif TARGET==C128
width		= 80
height		= 25
scr		= $400
cache		= $0b00
		.fi

displayinit	.proc
		lda #statusmsg.banner
		jsr setstatusmsg
		jsr display
		#kernal
		ldx #height
		lda #255
-		sta paintone.cachec-1,x
		dex
		bne -
		stx $d015
		stx $d020
		lda #$0b
		sta $d011
		lda #128
		sta cursor.size
		jmp crtc_init
		.pend

displayexit	.proc
		#kernal
		lda #$1b
		sta $d011
		lda #147
		jmp chrout
		.pend

displaylowinit	.proc
		#loadw $1000, screen
		rts
		.pend

displaylow	.proc
sor		= num+4

		stx paintone.ao+1
		sta paintone.cursorcol+1

		ldx windows.start,y
		lda windows.end,y
		sta leng+1		;length of window

loop		jsr paintone
		ldy #0
		pha (currentline),y
		iny
		lda (currentline),y
		sta currentline+1
		pla currentline

		inx
leng		cpx #height-1
		bne loop
		rts
		.pend

paintone	.proc
sor		= num+4

		stx sor
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
		txa
		pha

		ldx #$13
		lda screen
		jsr setcrtcreg
		dex
		lda screen+1
		jsr setcrtcreg

		pla
		tax
		ldy activewin
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
		ldy #1
		ldx #$1f
		lda #"-"
		jsr setcrtcreg
		jmp er
+
		ldy #4
		lda (currentline),y
		sec
		sbc column2
		bge +
		lda #0
+		cmp #width+1
		blt +
		lda #width
+		sta m1+1

		tya
		sec
		adc column2
		adc currentline
		sta currenttext
		lda #0
		adc currentline+1
		sta currenttext+1

		ldy #0
m1		cpy #0
		bge er
		lda (currenttext),y
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
		ldx #$1f
		jsr setcrtcreg
		iny
		gne m1

er		cpy #width
		bge jo
		lda #32
		ldx #$1f
		jsr setcrtcreg
		cpy #width-1
		bge jo
		tya
		eor #255
		adc #width
		ldx #$1e
		jsr setcrtcreg

jo
		ldx sor
ln		lda activewin
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
		clc
		adc screen
		ldx #$0f
		jsr setcrtcreg
		dex
		lda screen+1
		adc #$f0
		jsr setcrtcreg
		lda #$20
		jsr cursor.in
		ldx sor

nc		lda screen
		clc
		adc #width
		sta screen
		bcc +
		inc screen+1
+
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
		beq cursor
		rts
		.pend

cursor		.proc
on		lda #0
in		ldx #$0a
		eor #$20
		sta on+1
size		= *+1
		ldy #128
		bmi +
		ora #4
+		gne setcrtcreg
		.pend

setcrtcreg	.proc
		#kernal
		stx $d600
in		bit $d600
		bpl *-3
		sta $d601
		#ram
		rts
		.pend

crtc_init	.proc
		lda #0
		pha
		ldx #crtcdefault
		jsr setupcrtcregisters	;C128 crtc init
		lda $d600
		and #7
		beq nv1
		ldx #crtcdefaultv1
		jsr setupcrtcregisters	;version 1/2 init
nv1		pla
		beq npal
		ldx #crtcpal
		jsr setupcrtcregisters
npal
		#ram
		lda #<$d800
		sta screen
		lda #>$d800
		sta screen+1

nu
		ldy #0
-
		.if (TARGET==C64) || (TARGET==PLUGIN)
		inc $01
		.elsif TARGET==C128
		lda #$0f
		sta $ff00
		.fi
		lda (screen),y
		.if (TARGET==C64) || (TARGET==PLUGIN)
		dec $01
		.elsif TARGET==C128
		#ram
		.fi
		ldx #$1f
		jsr setcrtcreg
		iny
		cpy #8
		bne -
		ldx #$1e
		tya
		jsr setcrtcreg
		lda screen
		adc #7
		sta screen
		bcc nu
		inc screen+1
		lda screen+1
		and #7
		bne nu
		rts

setupcrtcregisters
lp		ldy const,x
		bmi end
		inx
		lda const,x
		inx
		sty $d600
		sta $d601
		bpl lp
end		rts

const
		.logical 0
crtcdefault	.byte $00,$7E,$01,width,$02,$66,$03,$49
		.byte $04,$20,$05,$00,$06,height,$07,$1D
		.byte $08,$00,$09,$07,$0A,$20,$0B,$08
		.byte $0C,$10,$0D,$00,$0E,$00,$0F,$00
		.byte $17,$08,$18,$20
		.byte $19,$00,$1A,$0e,$1B,$00,$1C,$00
		.byte $1D,$07,$22,$7D,$23,$64,$24,$05
		.byte $16,$78,$13,$00,$12,$00,$FF
crtcdefaultv1	.byte $19,$07,$FF
crtcpal		.byte $04,$26,$07,$20,$FF
		.here

		.pend
