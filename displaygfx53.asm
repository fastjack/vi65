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

		.if (TARGET=C64) | (TARGET=PLUGIN)
scr		= $e000
col		= $dc00
width2		= 40
height		= 25
cache		= $334
		.elsif (TARGET=PLUS4)
scr		= $e000
col		= $0c00
width2		= 40
height		= 23
cache		= $333
		.elsif TARGET=C128
scr		= $a000
col		= $8c00
width2		= 40
height		= 25
cache		= $0b00
		.elsif TARGET=VIC20BIG
scr		= $04e0
width2		= 20
height		= 22
cache		= $0334
		.elsif TARGET=ATARI800
width2		= 40
height		= 24
cache		= $0489
		.elsif TARGET=APPLE2
scr		= $2000
width2		= 40
height		= 24
cache		= $0800
		.fi
		.if TARGET=APPLE2
width		= width2*7/6
		.else
width		= width2*8/6
		.fi

gfx		.macro
		sta $ff03
		.endm

displayinit	.proc
		ldx #height-1
		lda #width2
-		sta paintone.caches,x
		dex
		bpl -
		stx paintone.cachec
		lda #8
		sta cursor.size
		ldx #<(banner-4)
		lda #>(banner-4)
		jsr setstatus
		.if (TARGET!=C128) & (TARGET!=ATARI800)
		jsr display
		.fi
		.if (TARGET=C64) | (TARGET=C128) | (TARGET=PLUGIN)
		#kernal
		.if (TARGET=C128)
		lda #$47
		sta $d506
		lda #$7f
		sta $d503
		.fi
		ldx #c2-c1
-		ldy c1-1,x
		lda c2-1,x
		sta $d000,y
		dex
		bne -
		lda #3-(scr >> 14)
		sta $dd00
		.if TARGET=C128
		#gfx
		.else
		#ram
		.fi
		lda #15
cl		sta col,x
		sta col+$100,x
		sta col+$200,x
		sta col+$300,x
		inx
		bne cl
		.if TARGET=C128
		#ram
		.fi
		rts

c1		.byte $15, $20, $11, $16, $18
c2		.byte $00, $06, $3b, $08, ((col >> 6) & $f0)+((scr & $2000) >> 10)
		.elsif (TARGET=PLUS4)
		lda #$06
		sta $ff19
		sta $ff15
		lda #$37
		sta $ff06
		lda $ff07
		and #$40
		ora #$0a
		sta $ff07
		lda #$c3+(scr >> 13)*8
		sta $ff12
		lda #>(col-$400)
		sta $ff14
		ldx #0
		lda #$08
		sta cl+2
		lda #$61
		jsr clr
		lda #$01
		jsr clr
		ldx #79
-		lda #$00
		sta col+23*width2-$400,x
		lda #$66
		sta col+23*width2,x
		dex
		bpl -
		rts

		clr ldy #3
cl		sta $ff00,x
		inx
		bne cl
		inc cl+2
		dey
		bpl cl
		rts
		.elsif TARGET=VIC20BIG
		lda #width2
		sta $9002
		lda #$17
		sta $9003
		lda #$19
		sta $9005
		ldx #0
-		cpx #224
		bge +
		txa
		adc #14
		sta $0400,x
		lda #0
+		sta $9400,x
		sta $9500,x
		inx
		bne -
		rts
		.elsif TARGET=ATARI800
		ldx #$30
		lda #3
		sta iccom,x
		lda #<(dpname)
		sta icba,x
		lda #>(dpname)
		sta icba+1,x
		lda #8
		sta icax1,x
		lda #8
		sta icax2,x
		jsr ciov		;keyboard
		lda #$70
		sta $2c8		;border
		lda #$00
		sta $2c5		;text
		lda #$0a
		sta $2c6		;background
		lda $2e6
		sta alloc.end+1
		rts

dpname		.text "S:",k_return
		.elsif TARGET=APPLE2
		bit $c052		;nomix
		;bit $c055	 ;page2
		bit $c057		;hires
		bit $c050		;graphic
		rts
		.fi
		.pend

displayexit	.proc
		#kernal
		.if (TARGET=C64) | (TARGET=C128) | (TARGET=PLUGIN)
		.if (TARGET=C128)
		lda #$04
		sta $d506
		.fi
		lda #27
		sta $d011
		lda #$14
		sta $d018
		lda #3
		sta $dd00
		lda #147
		jmp chrout
		.elsif (TARGET=C16) | (TARGET=PLUS4)
		lda $ff07
		and #$f8
		sta $ff07
		lda #$1b
		sta $ff06
		lda #$c7
		sta $ff12
		lda #$08
		sta $ff14
		lda #147
		jmp chrout
		.elsif (TARGET=ATARI800)
		ldx #$20
		lda #12
		sta iccom,x
		jsr ciov		;close
		ldx #$10
		lda #12
		sta iccom,x
		jmp ciov		;close
		.elsif (TARGET=APPLE2)
		rts
		.fi
		.pend

displaylow	.proc
p2		= screen
x		= num+2
ln		= num+3
sor		= num+4
p3		= num

		sta paintone.u+1

		.if TARGET=ATARI800
		lda $58
		clc
		adc #<(width2*8-8)
		sta p3
		lda $59
		adc #>(width2*8-8)
		sta p3+1
		.elsif TARGET=APPLE2
		#loadw (scr+8*1024-8), p3
		.else
		#loadw scr, p3
		.fi

		ldx #0
		stx cursor.kk+1
loop		jsr paintone

		.if TARGET=VIC20BIG
		lda p3
		and #8
		beq +
		eor p3
		sta p3
		jmp ek

+		lda p3
		sec
		sbc #<(width2*16-8)
		sta p3
		lda p3+1
		sbc #>(width2*16-8)
		sta p3+1
ek
		.elsif TARGET=ATARI800
		lda p3
		clc
		adc #<(width2*7)
		sta p3
		lda p3+1
		adc #>(width2*7)
		sta p3+1
		.elsif TARGET=APPLE2
		lda p3
		clc
		adc #<(128-40)
		sta p3
		lda p3+1
		adc #>(128-40)
		sta p3+1
		lda p3
		sec
		sbc #<(1024*8-8)
		tay
		lda p3+1
		sbc #>(1024*8-8)
		cpy #128
		rol
		and #7
		bne +
		lda p3
		sec
		sbc #<(1024-40)
		sta p3
		lda p3+1
		sbc #>(1024-40)
		sta p3+1
+
		.fi
		ldy #0
		pha (currentline),y
		iny
		lda (currentline),y
		sta currentline+1
		pla currentline

		inx
		cpx #height-1
		bne loop
		ldy #255
		sty paintone.garbagelow+1
		pha column2
		iny
		sty column2

st1		lda #<(linebuffer-4)
		sta currentline
st2		lda #>(linebuffer-4)
		sta currentline+1
		stx sor
		jsr paintone.in
		pla column2
		sta paintone.cachec
		rts
		.pend

setstatus	.proc
		stx displaylow.st1+1
		sta displaylow.st2+1
		rts
		.pend

		.if (TARGET=APPLE2)
		.cerror *>$2000
		*= $4000
		.fi

paintone	.proc
p2		= screen
x		= num+2
ln		= num+3
sor		= num+4
p3		= num

		stx sor
		lda cachec
		cmp column2
		bne ng
in		lda cachel,x
		cmp currentline
		bne ng
		lda cacheh,x
		cmp currentline+1
		bne ng
garbagelow	cmp #0
		bge ng
		.if TARGET=VIC20BIG
		lda p3
		adc #<(width2*16)
		sta p3
		lda p3+1
		adc #>(width2*16)
		sta p3+1
		.elsif TARGET=ATARI800
		lda p3
		adc #width2
		sta p3
		bcc +
		inc p3+1
+
		.elsif TARGET=APPLE2
		lda p3
		adc #40
		sta p3
		bcc +
		inc p3+1
+
		.else
		lda p3
		adc #<(width2*8)
		sta p3
		lda p3+1
		adc #>(width2*8)
		sta p3+1
		.fi
		jmp jo
ng
		lda caches,x
		sta b+1
		lda currentline
		sta cachel,x
		lda currentline+1
		sta cacheh,x
		txa
		clc
		adc line2
		tay
		.if (TARGET!=ATARI800) & (TARGET!=APPLE2)
		txa
		sei
		tsx
		stx oldsp+1
		tax
		.fi
		lda #0
		sta x
		sta ez+1
		.if TARGET=APPLE2
		sta q+1
		.fi
		adc line2+1
		cpy lines
		sbc lines+1
		bcc +
		cpx #height-1
		beq +
		lda #0
		sta ln
		tay
		lda #"-"
		gne er
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
+		sta ln

		tya
		sec
		adc column2
		adc currentline
		sta currenttext
		lda #0
		adc currentline+1
		sta currenttext+1

lp
		.if TARGET=C128
		#ram
		.fi
ez		ldy #0
		cpy ln
		bge fin

		lda (currenttext),y
er		asl
		rol
		rol
		rol
		tax
		and #$f0
		ror
		adc #<font
		sta p2
		txa
		and #7
		tax
		lda class,x
		adc #0
		sta p2+1

		.if TARGET=C128
		#gfx
		.fi
		inc ez+1

		.if TARGET=APPLE2
		ldy #7
q		lda #0
		inc q+1
		lsr
		bcs k1
		lsr
		bcs k2
		lsr
		bcs k4

		inc x
		lda p2
		sta u1+1
		lda p2+1
		sta u1+2
		gcc lp

k1
		lsr
		bcs k3
		lsr
		bcs k5
-
		lda p3
		sec
		sbc #<1023
		sta p3
		lda p3+1
		sbc #>1023
		sta p3+1
		lda (p2),y
		lsr
		tax
		ror
		lsr
		and #%01000000
u1		ora tmpl,y
		sta (p3),y
		txa
		sta tmpl,y
		dey
		bpl -
		gmi n2
k2
		lsr
		bcs k6
-
		lda p3
		sec
		sbc #<1023
		sta p3
		lda p3+1
		sbc #>1023
		sta p3+1
		lda (p2),y
		lsr
		ror
		tax
		ror
		lsr
		and #%01100000
		ora tmpl,y
		sta (p3),y
		txa
		and #%00001111
		sta tmpl,y
		dey
		bpl -
		gmi n2
k3
-
		lda p3
		sec
		sbc #<1023
		sta p3
		lda p3+1
		sbc #>1023
		sta p3+1
		lda (p2),y
		lsr
		ror
		ror
		tax
		ror
		lsr
		and #%01110000
		ora tmpl,y
		sta (p3),y
		txa
		and #%00000111
		sta tmpl,y
		dey
		bpl -
		gmi n2
k4
-
		lda p3
		sec
		sbc #<1023
		sta p3
		lda p3+1
		sbc #>1023
		sta p3+1
		lda (p2),y
		lsr
		ror
		ror
		ror
		tax
		ror
		lsr
		and #%01111000
		ora tmpl,y
		sta (p3),y
		txa
		and #%00000011
		sta tmpl,y
		dey
		bpl -
		gmi n2
k5
-
		lda p3
		sec
		sbc #<1023
		sta p3
		lda p3+1
		sbc #>1023
		sta p3+1
		lda (p2),y
		asl
		asl
		cmp #$80
		and #%01111100
		ora tmpl,y
		sta (p3),y
		lda #0
		rol
		sta tmpl,y
		dey
		bpl -
		gmi n2

k6		sta q+1
-
		lda p3
		sec
		sbc #<1023
		sta p3
		lda p3+1
		sbc #>1023
		sta p3+1
		lda (p2),y
		asl
		ora tmpl,y
		sta (p3),y
		dey
		bpl -

n2		lda p3
		clc
		adc #<(1024*8-8+1)
		sta p3
		lda p3+1
		adc #>(1024*8-8+1)
		sta p3+1
		jmp lp
		.else
		tya
		.if (TARGET!=ATARI800) & (TARGET!=APPLE2)
		ldx #7
		txs
		.fi
		ldy #7
		lsr
		bcs k1
		lsr
		bcs k2

		inc x
		lda p2
		sta u1+1
		lda p2+1
		sta u1+2
		gcc lp

k1
		lsr
		bcs k3
-
		.if TARGET=ATARI800
		lda p3
		sec
		sbc #width2-1
		sta p3
		bcs +
		dec p3+1
+
		.fi
		lda (p2),y
		asl
		adc #$80
		rol
		tax
		and #%00000011
u1		ora tmpl,y
		sta (p3),y
		txa
		and #%11110000
		.if (TARGET!=ATARI800) & (TARGET!=APPLE2)
		pha
		.else
		sta tmpl,y
		.fi
		dey
		bpl -
		gmi n2
k2
		.if TARGET=ATARI800
		clc
		.fi
-
		.if TARGET=ATARI800
		lda p3
		sbc #width2-1-1
		sta p3
		bcs +
		dec p3+1
+
		.fi
		lda (p2),y
		lsr
		ror
		ror
		ror
		tax
		and #%00001111
		ora tmpl,y
		sta (p3),y
		txa
		and #%10000000
		ror
		.if (TARGET!=ATARI800) & (TARGET!=APPLE2)
		pha
		.else
		sta tmpl,y
		.fi
		dey
		bpl -
		gmi n2
k3
		.if TARGET=ATARI800
		clc
		.fi
-
		.if TARGET=ATARI800
		lda p3
		sbc #width2-1-1
		sta p3
		bcs +
		dec p3+1
+
		.fi
		lda (p2),y
		lsr
		lsr
		ora tmpl,y
		sta (p3),y
		dey
		bpl -

n2		.if TARGET=ATARI800
		lda p3
		clc
		adc #<(width2*8-8+1)
		sta p3
		lda p3+1
		adc #>(width2*8-8+1)
		sta p3+1
		.else
		.if TARGET=VIC20BIG
		lda #16
		.else
		lda #8
		.fi
		clc
		adc p3
		sta p3
		bcc +
		inc p3+1
+
		.fi
		jmp lp
		.fi

fin
		.if (TARGET!=ATARI800) & (TARGET!=APPLE2)
oldsp		ldx #0
		txs
		cli
		.fi
		tya
		sbc x
		sta x
		tax
		.if TARGET=C128
		#gfx
		.fi

		.if TARGET=APPLE2
		ldy #7
		lda q+1
		.else
		tya
		ldy #7
		and #3
		.fi
		beq b
		inc x
		lsr
		bne k
-
		.if TARGET=ATARI800
		lda p3
		sec
		sbc #width2-1
		sta p3
		bcs +
		dec p3+1
+
		.elsif TARGET=APPLE2
		lda p3
		sec
		sbc #<1023
		sta p3
		lda p3+1
		sbc #>1023
		sta p3+1
		.fi
		lda (p2),y
		sta (p3),y
		dey
		bpl -
		gmi l2
k
		.if TARGET=ATARI800
		lda p3
		sec
		sbc #width2-1
		sta p3
		bcs +
		dec p3+1
+
		.elsif TARGET=APPLE2
		lda p3
		sec
		sbc #<1023
		sta p3
		lda p3+1
		sbc #>1023
		sta p3+1
		.fi
		lda tmpl,y
		sta (p3),y
		dey
		bpl k
l2
		.if TARGET=ATARI800
		lda p3
		clc
		adc #<(width2*8-8)
		sta p3
		lda p3+1
		adc #>(width2*8-8)
		sta p3+1
		.elsif TARGET=APPLE2
		lda p3
		clc
		adc #<(1024*8-8)
		sta p3
		lda p3+1
		adc #>(1024*8-8)
		sta p3+1
		.fi
l		ldy #7
		.if (TARGET=ATARI800) | (TARGET=APPLE2)
		inc p3
		bne +
		inc p3+1
+
		.else
		.if TARGET=VIC20BIG
		lda #15
		.else
		tya
		.fi
		sec
		adc p3
		sta p3
		bcc +
		inc p3+1
+
		.fi
		inx
b		cpx #width2
		bge ko
		.if TARGET=ATARI800
-		lda p3
		sec
		sbc #width2-1
		sta p3
		bcs +
		dec p3+1
+		lda #0
		sta (p3),y
		dey
		bpl -
		.elsif TARGET=APPLE2
-		lda p3
		sec
		sbc #<1023
		sta p3
		lda p3+1
		sbc #>1023
		sta p3+1
		lda #0
		sta (p3),y
		dey
		bpl -
		.else
		lda #0
-		sta (p3),y
		dey
		sta (p3),y
		dey
		bpl -
		.fi
		gmi l2

ko		cpx #width2
		blt l

		ldx sor
		lda x
		sta caches,x
jo
		.if TARGET=C128
		#ram
		.fi

u		cpx #0
		bne nc
		.if TARGET=VIC20BIG
		lda p3
		sbc #<(width2*16)
		sta p2
		lda p3+1
		sbc #>(width2*16)
		.elsif TARGET=ATARI800
		lda p3
		sbc #<(width2-8)
		sta p2
		lda p3+1
		sbc #>(width2-8)
		.elsif TARGET=APPLE2
		lda p3
		sbc #<(40-8)
		sta p2
		lda p3+1
		sbc #>(40-8)
		.else
		lda p3
		sbc #<(width2*8)
		sta p2
		lda p3+1
		sbc #>(width2*8)
		.fi
		tax
		lda column
		sbc column2
		sta x
		asl
		adc x
		asl
		.if TARGET=APPLE2
		ldy #255
		bcc +
		ldy #35
		adc #3
+
		sec
-		iny
		sbc #7
		bcs -
		adc #7
		pha
		tya
		clc
		adc p2
		sta cursor.at1+1
		bcc +
		inx
+		stx cursor.at2+1
		pla
		tay
		lda tochar.mode+1
		cmp #1
		lda #%00000011
		blt +
		lda #%00111111
		gne +

-		asl
		cmp #$80
		rol cursor.kk+1
+		dey
		bpl -
		and #$7f
		.else
		tay
		.if TARGET=ATARI800
		ror
		lsr
		lsr
		clc
		.else
		and #$f8
		.if TARGET=VIC20BIG
		asl
		.fi
		bcc +
		clc
		inx
+
		.fi
		adc p2
		sta cursor.at1+1
		bcc +
		inx
+		stx cursor.at2+1
		tya
		and #7
		tay
		lda tochar.mode+1
		cmp #1
		lda #%11000000
		blt +
		lda #%11111100
		gne +

-		lsr
		ror cursor.kk+1
+		dey
		bpl -
		.fi
		sta cursor.k+1

		lda #1
		jsr cursor.in
		ldx u+1
nc		rts

		.if TARGET=ATARI800
class		.byte >(font+2*8*32),>font,>(font+8*32),>(font+3*8*32)
		.byte >(font+2*8*32),>font,>(font+8*32),>(font+3*8*32)
		.elsif TARGET=APPLE2
class		.byte >(font+0*8*32),>(font+8*32),>(font+2*8*32),>(font+3*8*32)
		.byte >(font+0*8*32),>(font+8*32),>(font+2*8*32),>(font+3*8*32)
		.else
class		.byte >font,>(font+8*32),>font,>(font+2*8*32)
		.byte >(font+2*8*32),>(font+3*8*32),>(font+2*8*32),>(font+3*8*32)
		.fi
o

		.logical cache
cachec		.fill 1
		.if (TARGET=ATARI800) | (TARGET=APPLE2)
tmpl		.fill 8
		.else
tmpl		= $100
		.fi
cachel		.fill height
cacheh		.fill height
caches		.fill height
		.here

		*= o

		.if TARGET=ATARI800
font		.binary "atascii6x8.fnt",2,$400
		.elsif TARGET=APPLE2
font		.binary "a2ascii6x8.fnt",2,$400
		.else
font		.binary "petscii6x8.fnt",2,$400
		.fi

		.pend

cursoroff	.proc
		lda cursor.on+1
		beq cursor.x
		gne cursor
		.pend

cursor		.proc
on		lda #0
		eor #1
in		sta on+1

		.if (TARGET=ATARI800) | (TARGET=APPLE2)
at1		lda #0
		sta screen
at2		lda #0
		sta screen+1

size		= *+1
		ldx #8
-
		.if (TARGET=ATARI800)
		lda screen
		sec
		sbc #width2
		sta screen
		bcs +
		dec screen+1
+
		.elsif (TARGET=APPLE2)
		lda screen+1
		sec
		sbc #>1024
		sta screen+1
		.fi
		ldy #0
		lda (screen),y
k		eor #0
		sta (screen),y
		iny
		lda (screen),y
kk		eor #0
		sta (screen),y
		dex
		bne -
		.else
at1		lda #<scr
		sta screen
at2		lda #>scr
		sta screen+1
		.if TARGET=C128
		#gfx
		.fi
size		= *+1
		ldx #8
		ldy #7
-		lda (screen),y
k		eor #0
		sta (screen),y
		dey
		dex
		bne -

		ldx size
		.if TARGET=VIC20BIG
		ldy #23
		.else
		ldy #15
		.fi
-		lda (screen),y
kk		eor #0
		sta (screen),y
		dey
		dex
		bne -
		.if TARGET=C128
		#ram
		.fi
		.fi
x		rts
		.pend
