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

		.if TARGET==ATARI800
ciov		= $e456
iccom		= $342
icba		= $344
icbl		= $348
icax1		= $34a
icax2		= $34b

critical	.byte 0
		.elsif TARGET==APPLE2
moncout		= $fded
moncin		= $fd0c
		.fi

		.if TARGET==ATARI800
open		.proc
		ldx #$20
		sta icax1,x
		lda #3
		sta iccom,x
		ldy filename
		lda #k_return
		sta filename+1,y
		lda #<(filename+1)
		sta icba,x
		lda #>(filename+1)
		sta icba+1,x
		lda #0
		sta icax2,x
		jmp ciov		;open
		.pend
		.elsif TARGET==APPLE2
open		.proc
		pha
		ldy #close.op
		jsr do
		pla
		tay
do		jsr close.in
		ldy #0
-		lda filename+1,y
		eor #$80
		jsr moncout
		iny
		cpy filename
		blt -
		lda #$8d
		jmp moncout
		.pend
		.elsif (TARGET==PET40) || (TARGET==PET80)
open		.proc
		lda #1
		;ldx drive
		sta $d2
		;stx $d4
		sty $d3
		lsr
		sta linebuffer
		dey
		bne an
		lda #":"
-		cmp filename+1,x
		beq +
		dex
		bne -
		clc
+		lda #"@"
		jsr lb_append_char
		bcs an
		lda #":"
		jsr lb_append_char
an		ldx #<(filename-4)
		lda #>(filename-4)
		jsr lb_append_str

		lda linebuffer
		ldx #<(linebuffer+1)
		ldy #>(linebuffer+1)
		sta $d1
		stx $da
		sty $db
		ldx #0
		geq close.in
		.pend
		.else
open		.proc
		lda #1
		ldx drive
		jsr $ffba
		#ram
		lsr
		sta linebuffer
		dey
		bne an
		lda #":"
-		cmp filename+1,x
		beq +
		dex
		bne -
		clc
+		lda #"@"
		jsr lb_append_char
		bcs an
		lda #":"
		jsr lb_append_char
an		ldx #<(filename-4)
		lda #>(filename-4)
		jsr lb_append_str

		ldx linebuffer
		beq +
-		lda linebuffer,x
		sta $200-1,x
		dex
		bne -
+		lda linebuffer
		#kernal
		ldx #<$200
		ldy #>$200
		jsr $ffbd
		.if TARGET==C128
		stx $ae
		sty $af
		tay
-		lda ($bb),y
		ldx #%01000000
		jsr $2af
		dey
		bpl -
		.fi
		jmp $ffc0
		.pend
		.fi

		.if TARGET==ATARI800
close		.proc
		ldx #$20
		lda #12
		sta iccom,x
		jmp ciov		;close
		.pend
		.elsif TARGET==APPLE2
close		.proc
		ldy #cl
in		lda #$84
		jsr moncout
-		lda consts,y
		beq +
		jsr moncout
		iny
		bne -
+		rts
consts
		.logical 0
op		.null "O"+128, "P"+128, "E"+128, "N"+128, " "+128
rd		.null "R"+128, "E"+128, "A"+128, "D"+128, " "+128
wr		.null "W"+128, "R"+128, "I"+128, "T"+128, "E"+128, " "+128
cl		.null "C"+128, "L"+128, "O"+128, "S"+128, "E"+128,$8d
		.here
		.pend
		.elsif (TARGET==PET40) || (TARGET==PET80)
close		.proc
		jsr clrchn
		ldx #3
in		lda $ffc1,x
		clc
		adc #3
		sta cl+1
		lda $ffc2,x
		adc #0
		sta cl+2
		lda #1
cl		jmp $f2e0
		.pend
		.else
close		.proc
		#kernal
		jsr clrchn
		lda #1
		jsr $ffc3
		#ram
		rts
		.pend
		.fi

chkin		= $ffc6
chkout		= $ffc9
clrchn		= $ffcc
chrin		= $ffcf
chrout		= $ffd2
