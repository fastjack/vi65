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

;m; <h4>j or &lt;Right&gt;</h4>

;m; [count] characters to the right. exclusive motion.

motion_l	.proc
		jsr normcolumn
		tax
		clc
		adc oneless
		bcs +
		cmp (cursorline),y
		blt +
err		lsr error
		rts

+		stx column
		txa
		ldx repeat+1
		bne tolastchar
		clc
		adc repeat
		bcc tochar
		gcs tolastchar
		.pend

tolastchar	.proc
		lda #255
		gne tochar
		.pend

tochar		.proc
		jsr normcolumn2
in2		sta column
		rts

mode		= *-1
		.byte 1
		.pend

;m; <h4>h or &lt;Left&gt; or CTRL-H</h4>

;m; [count] characters to the left. exclusive motion.

motion_h	.proc
		jsr normcolumn
		cmp #0
		beq motion_l.err
		ldx repeat+1
		bne motion_0
		sec
		sbc repeat
		bcs tochar.in2
		gcc motion_0
		.pend

;m; <h4>0 or &lt;Home&gt;</h4>

;m; To the first character of the line. exclusive
;m; motion.

motion_0	.proc
		lda #0
		geq tochar.in2
		.pend

;m; <h4>g$ or g&lt;End&gt;</h4>

;m; To the rightmost
;m; character of the current line that is visible on the
;m; screen.  Differs from "$" when the last character of
;m; the line is not on the screen.

;m; Additionally, vertical movements keep the column,
;m; instead of going to the end of the line. inclusive.

motion_gdollar	.proc
		inc inclusive
		lda #width-1
		.byte $2c
		.cerror motion_g0 & 0
		.pend

;m; <h4>g0 or g&lt;Home&gt;</h4>

;m; To the leftmost
;m; character of the current line that is on the screen.
;m; Differs from "0" when the first character of the line
;m; is not on the screen. exclusive motion.

motion_g0	.proc
		lda #0
		.byte $2c
		.cerror motion_gm & 0
		.pend
;m; <h4>gm</h4>

;m; Like "g0", but half a screenwidth to the right (or as
;m; much as possible). exclusive.

motion_gm	.proc
		lda #width/2-1
		clc
		adc column2
		bcs tolastchar
		gcc tochar
		.pend
;m; <h4>^</h4>

;m; To the first non-blank character of the line. exclusive.

motion_uparrow	.proc
		ldy #4
		lda (cursorline),y
		tax
		inx
		lda #32

-		iny
		dex
		beq +
		cmp (cursorline),y
		beq -
+		tya
		sec
		sbc #5
		gcs tochar
		.pend

;m; <h4>|</h4>

;m; To screen column [count] in the current line.
;m; exclusive motion.

motion_bar	.proc
		lda repeat+1
		bne line_end
		ldx repeat
		dex
		.byte $2c
		.cerror line_end & 0
		.pend

line_end	.proc
		ldx #255
		stx column
		rts
		.pend

		.if SIMPLE
motion_dollar	= line_end
		.else
;m; <h4>$ or &lt;End&gt;</h4>

;m; To the end of the line.  When a count is given also go
;m; [count - 1] lines downward inclusive.

motion_dollar	.proc
		inc inclusive
		jsr line_end
		lda #0
		jsr sbcrepeat
		ora repeat
		bne motion_j
		rts
		.pend
;m; <h4>t{char}</h4>

;m; Till before [count]'th occurrence of {char} to the
;m; right.  The cursor is placed on the character left of
;m; {char}. inclusive.

motion_t	.proc
		clc
		.byte $a9
		.pend
;m; <h4>f{char}</h4>

;m; To [count]'th occurrence of {char} to the right.  The
;m; cursor is placed on {char}. inclusive.

motion_f	.proc
		sec
in		php
		jsr waitkey
		tax
		lda repeat+1
		bne x2
		ldy #4
		tya
		sec
		adc (cursorline),y
		sta m+1
		tya
		sec
		adc column
		tay
		txa

-		iny
m		cpy #0
		bge x2
		cmp (cursorline),y
		bne -
		dec repeat
		bne -
		tya
		plp
		sbc #5
		inc inclusive
		gcs tochar

x2		lsr error
		plp
		rts
		.pend
		.fi

		.if !SIMPLE
;m; <h4>T</h4>

;m; Till after [count]'th occurrence of {char} to the
;m; left.  The cursor is placed on the character right of
;m; {char} exclusive.

motion_T	.proc
		sec
		.byte $a9
		.pend
;m; <h4>F</h4>

;m; To the [count]'th occurrence of {char} to the left.
;m; The cursor is placed on {char} exclusive.

motion_F	.proc
		clc
in		php
		jsr waitkey
		tax
		lda repeat+1
		bne motion_f.x2
		lda column
		clc
		adc #5
		tay
		txa

-		dey
		cpy #5
		blt motion_f.x2
		cmp (cursorline),y
		bne -
		dec repeat
		bne -
		tya
		plp
		sbc #4
		gcs tochar
		.pend
		.fi

		.if !SIMPLE
;m; <h4>L</h4>

;m; To line [count] from bottom of window (default: Last
;m; line on the window) on the first non-blank character
;m; linewise.

motion_L	.proc
		lda repeat+1
		bne +
		lda #height-1
		sec
		sbc repeat
		bcs motion_M.in
+		lda #0
		geq motion_M.in
		.pend
;m; <h4>H</h4>

;m; To line [count] from top (Home) of window (default:
;m; first line on the window) on the first non-blank
;m; character linewise.

motion_H	.proc
		lda repeat+1
		bne j
		lda repeat
		cmp #height
		blt +
j		lda #height-2
+		sbc #0
		.byte $2c
		.cerror motion_M & 0
		.pend
;m; <h4>M</h4>

;m; To Middle line of window, on the first non-blank
;m; character linewise.

motion_M	.proc
		lda #height/2-1
in		inc linewise
		clc
		adc line2
		tax
		lda #0
		adc line2+1
		jsr tolineadd
		jmp motion_uparrow
		.pend
		.fi
;m; <h4>G</h4>

;m; Goto line [count], default last line, on the first
;m; non-blank character linewise.

motion_G	.proc
		ldx waitkeyrepeat.norepeat
		beq motion_gg
		ldx lines
		lda lines+1
		jmp motion_gg.in
		.pend
;m; <h4>gg</h4>

;m; Goto line [count], default first line, on the first
;m; non-blank character linewise.

motion_gg	.proc
		ldx repeat
		lda repeat+1
in		cpx #1
		dex
		sbc #0
		jsr toline
		inc linewise
		jmp motion_uparrow
		.pend

tolinesub	bge toline
		lda #0
		tax
tolineadd	bge toline.max

toline		.proc
		tay
		cpx lines
		sbc lines+1
		blt +
max		ldy lines+1
		ldx lines
		bne r
		tya
		beq +
		dey
r		dex
+		stx l1+1
		sty l2+1

-		lda line
		sec
l1		sbc #0
		tax
		lda line+1
l2		sbc #0
		blt f
		bne b
		txa
		bne b
err		rts

b		jsr cursorprev
		jmp -
f		jsr cursornext
		jmp -
		.pend

cursorprev	.proc
		lda line
		bne +
		dec line+1
+		dec line
-		ldy #2
		lda (cursorline),y
		tax
		iny
		lda (cursorline),y
		sta cursorline+1
		stx cursorline
		iny
		lda (cursorline),y
		cmp #255		;reference? skip
		beq -
		rts
		.pend

cursornext	.proc
		inc line
		bne +
		inc line+1
+
-		ldy #1
		lda (cursorline),y
		tax
		dey
		lda (cursorline),y
		sta cursorline
		stx cursorline+1
		ldy #4
		lda (cursorline),y
		cmp #255		;reference? skip
		beq -
		rts
		.pend

islastline	.proc
		lda lines
		clc
		sbc line
		bne +
		lda lines+1
		sbc line+1
+		rts
		.pend

;m; <h4>j or &lt;Down&gt; or CTRL-J or CTRL-N or &lt;NL&gt;</h4>

;m; [count] lines downward linewise.

motion_j	.proc
		jsr islastline
		bne +
err		lsr error
		rts

+		lda line
		clc
		adc repeat
		tax
		lda line+1
		adc repeat+1
		jsr tolineadd
		inc linewise
		rts
		.pend

;m; <h4>k or &lt;Up&gt; or CTRL-P</h4>

;m; [count] lines upward linewise.

motion_k	.proc
		lda line
		ora line+1
		beq motion_j.err

		inc linewise
		lda line
		sec
		sbc repeat
		tax
		lda line+1
		sbc repeat+1
		jsr tolinesub
		inc linewise
		rts
		.pend

;m; <h4>- &lt;minus&gt;</h4>

;m; [count] lines upward, on the first non-blank
;m; character linewise.

motion_minus	.proc
		jsr motion_k
		jmp motion_plus.in
		.pend

;m; <h4>+ or CTRL-M or &lt;CR&gt;</h4>

;m; [count] lines downward, on the first non-blank
;m; character linewise.

motion_plus	.proc
		jsr motion_j
in		bit error
		bmi motion_uparrow
		rts
		.pend
;n; <h4>m{a-z}</h4>

;n; Set mark {a-z} at cursor position

motion_m	.proc			;A-Z?
		jsr waitkey
		sec
		sbc #"a"
		blt setmark.x
		cmp #"z"-"a"+1
		bge setmark.x
		sta r+1
		asl
r		adc #0
		tax
		.cerror setmark & 0
		.pend

setmark		.proc
		lda line
		sta marks,x
		lda line+1
		sta marks+1,x
		jsr normcolumn
		sta marks+2,x
x		rts
		.pend
;m; <h4>'{a-z}</h4>

;m; The cursor is positioned on the first non-blank
;m; character in the line of the specified location and
;m; the motion is linewise.

motion_tick	.proc
		inc linewise
		.cerror motion_backtick & 0
		.pend

;m; <h4>`{a-z[]} or <-{a-z[]}</h4>

;m; The cursor is positioned at the specified location
;m; and the motion is exclusive.

motion_backtick .proc
		jsr waitkey
		cmp #"["
		beq st
		cmp #"]"
		beq en
+		sec
		sbc #"a"
		blt baj
		cmp #"z"-"a"+1
		bge baj
		sta r+1
		asl
r		adc #0
		tay
		.byte $2c
st		ldy #marks.start
		.byte $2c
en		ldy #marks.end
		lda marks+2,y
		cmp #255
		beq baj
		pha
		ldx marks,y
		lda marks+1,y
		jsr toline
		pla
		jmp tochar

baj		rts
		.pend

;n; <h4>&lt;backspace&gt;</h4>

;n; Move backward.

motion_backspace .proc
		jsr normcolumn
		ora line
		ora line+1
		bne do
		lsr error
		rts

-		lda line
		ora line+1
		beq veg
		jsr cursorprev
		jsr tolastchar

do		pha column
		jsr motion_h
		pla
		sec
		sbc column
		jsr sbcrepeat
		bge -
veg		sec
		ror error
		rts
		.pend

sbcrepeat	.proc
		eor #255
		clc
		adc repeat
		sta repeat
		lda #255
		adc repeat+1
		sta repeat+1
		rts
		.pend

;n; <h4>&lt;space&gt;</h4>

;n; Move forward.

motion_space	.proc
		jsr normcolumn
		tax
		clc
		adc oneless
		bcs do
		cmp (cursorline),y
		blt do
		jsr islastline
		bne do
		lsr error
		rts

-		jsr islastline
		beq veg
		jsr cursornext
		jsr motion_0

do		pha column
		jsr motion_l
		pla
		eor #255
		sec
		adc column
		jsr sbcrepeat
		bge -
veg		sec
		ror error
		rts
		.pend
