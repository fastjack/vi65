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

instxt		.char instxte-instxt-1
		.text "-- insert --"
instxte
;n; <h4>A</h4>

;n; Append text at the end of the line.

kA		.proc
		jsr lastchar
		.cerror ka & 0
		.pend
;n; <h4>a</h4>

;n; Append text after the cursor times.  If the
;n; cursor is in the first column of an empty line Insert
;n; starts there.

ka		.proc
		lda #1
		sta repeat
		dec tochar.mode+1
		jsr motion_l
		jmp insertmode2
		.pend
;n; <h4>I</h4>

;n; Insert text before the first non-blank in the line

kI		.proc
		dec tochar.mode+1
		jsr motion_uparrow
		.cerror insertmode2 & 0
		.pend

insertmode2	.proc
		inc tochar.mode+1
		.cerror insertmode & 0
		.pend

insertmode	.proc
		dec tochar.mode+1
		ldx #<(instxt-4)
		lda #>(instxt-4)
		jsr setstatus
		ldx #marks.start
		jsr setmark
		;ldx #references.start
		;jsr insertref2
		;ldx #references.end
		;jsr insertref
loop		lsr display.now
		ldx #1
		stx repeat
		dex
		stx repeat+1
		jsr waitkey
		ldx #keylookup.insertkeys
		jsr keylookup
		jmp loop

exit		pla
		pla
		ldx #<(notxt-4)
		lda #>(notxt-4)
		jsr setstatus
		inc tochar.mode+1
		;ldx #references.end
		;jsr deleteref
		;ldx #references.start
		;jsr deleteref2
		jmp motion_h

notxt		.text 0

put		tya
		ldx #keylookup.motionkeys2
		jsr keylookup
		.if TARGET=ATARI800
		cpy #$7d
		bge baj
		cpy #32
		blt baj
		.else
		tya
		asl
		cmp #64
		blt baj			;no control chars
		.fi
put2
		sty ichar
		#loadw fakeinsert, currenttext
		gge inserttext

baj		rts

kreturn		jsr split
		bcs baj
		lda #1
		sta repeat
		lsr
		sta repeat+1
		jsr motion_j
		jmp motion_0

fakeinsert	= *-4
		.byte 1
ichar		.byte 0
		.pend

;i; CTRL-Y
;i;
;i; Insert the character which is above the cursor.
;i;
insert_ctrl_y	.proc
		ldy #2
		.byte $2c
		.cerror insert_ctrl_e & 0
		.pend
;i; CTRL-E
;i;
;i; Insert the character which is below the cursor.
;i;
insert_ctrl_e	.proc
		ldy #0
		lda (cursorline),y
		sta currenttext
		iny
		lda (cursorline),y
		sta currenttext+1
		ldy #4
		lda column
		cmp (currenttext),y
		bcc +
		rts

+		adc #5
		tay
		lda (currenttext),y
		tay
		sec
		gcs insertmode.put2
		.pend

append_c	.proc
		pha
		ldy #4
		lda (cursorline),y
		clc
		adc #1
		jsr modline
		pla
		bcs e
		pha
		ldy #4
		lda (currentline),y
		beq +
		tax

-		iny
		lda (currentline),y
		sta (cursorline),y
		dex
		bne -
+		iny
		pla
		sta (cursorline),y
e		rts
		.pend

inserttext	.proc
		ldy #4
		lda (currenttext),y
		sta il+1
		clc
		adc (cursorline),y
		clc
		bcs baj
		jsr linemod
		bcc +
baj		rts

+		ldy #4
		lda (currentline),y
		sec
		sbc column
		sta en+1

		ldx column
		beq +

-		iny
		lda (currentline),y
		sta (allocline),y
		dex
		bne -
+
		lda currenttext
		sec
		sbc column
		sta currenttext
		bcs +
		dec currenttext+1
+

il		ldx #0
		beq +
		txa
		clc
		adc column
		sta column
		lda currentline
		sec
		sbc il+1
		sta currentline
		bcs y
		dec currentline+1
y

-		iny
		lda (currenttext),y
		sta (allocline),y
		dex
		bne -
+

en		ldx #0
		beq +
-		iny
		lda (currentline),y
		sta (allocline),y
		dex
		bne -
+		clc
		rts
		.pend

linemod		.proc
		jsr alloc
		bcs err

		ldy #0
		lda (cursorline),y
		sta (allocline),y
		sta currentline
		iny
		lda (cursorline),y
		sta (allocline),y
		sta currentline+1
		iny
		lda allocline
		sta (currentline),y
		iny
		lda allocline+1
		sta (currentline),y

		lda (cursorline),y
		sta (allocline),y
		sta currentline+1
		lda #1
		sta (cursorline),y
		dey
		lda (cursorline),y
		sta (allocline),y
		sta currentline
		dey
		lda allocline+1
		sta (currentline),y
		dey
		lda allocline
		sta (currentline),y

		#movew cursorline, currentline
		#movew allocline, cursorline
err		rts
		.pend
;
; cursor+ to X ref
;
insertref	.proc
		lda cursorline+1
		sta references.prev+1,x
		lda cursorline
		sta references.prev,x
		ldy #0
		lda (cursorline),y
		sta currentline
		sta references.next,x
		txa
		clc
		adc #<references
		pha
		sta (cursorline),y
		iny
		lda (cursorline),y
		sta currentline+1
		sta references.next+1,x
		lda #0
		adc #>references
		sta (cursorline),y
		ldy #3
		gne insertref2.common
		geq insertref2
		.pend
;
; cursor- to X ref
;
insertref2	.proc
		lda cursorline+1
		sta references.next+1,x
		lda cursorline
		sta references.next,x
		ldy #2
		lda (cursorline),y
		sta currentline
		sta references.prev,x
		txa
		clc
		adc #<references
		pha
		sta (cursorline),y
		iny
		lda (cursorline),y
		sta currentline+1
		sta references.prev+1,x
		lda #0
		adc #>references
		sta (cursorline),y
		ldy #1
common		sta (currentline),y
		dey
		pla
		sta (currentline),y
		lda #255
		sta references.len,x
		rts
		.pend

deleteref	.proc
		tax
		tay
		.cerror borona & 0
		.pend

borona		.proc
		lda references.prev,y
		sta currentline
		lda references.prev+1,y
		sta currentline+1
		ldy #0
		lda references.next,x
		sta allocline
		sta (currentline),y
		iny
		lda references.next+1,x
		sta allocline+1
		sta (currentline),y
		iny
		lda currentline
		sta (allocline),y
		iny
		lda currentline+1
		sta (allocline),y
		rts
		.pend

reftocursor	.proc
		lda references,x
		sta cursorline
		lda references+1,x
		sta cursorline+1
		rts
		.pend
