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

exmode		.proc
		lda loading
		beq +
semmi		rts

+		lda #":"
		jsr ex_input
		beq semmi
		lda #0
		sta linebuffer+1,x
		tax
		jsr skipspace
		beq semmi
		ldy linebuffer+1+1,x
		beq +
		cpy #32
		bne ru
+		cmp #"f"
		beq file
		cmp #"e"
		beq edit
		cmp #"w"
		beq write
		cmp #"q"
		beq exit
ru
		ldx #<(notcmd-4)
		lda #>(notcmd-4)
		jmp setstatus

skipspace	inx
		lda linebuffer+1,x
		beq +
		cmp #32
		beq skipspace
+		rts

;n; <h4>:q</h4>

;n; Quit. No question for unsaved changes yet!

exit		pla
		pla
		.if (TARGET==C64) || (TARGET==PLUGIN) || (TARGET==C128) || (TARGET==VIC20) || (TARGET==VIC20BIG) || (TARGET==PLUS4) || (TARGET==C16)
		sei
		#movew irq.old+1, $314
		cli
		.elsif (TARGET==PET40) || (TARGET==PET80)
		sei
		#movew irq.old+1, $90
		cli
		.elsif TARGET==ATARI800
		sei
		#movew irq.old+1, $224
		cli
		.fi
		ldx #zpend-zpstart-1
-		lda zpsave,x
		sta zpstart,x
		dex
		bpl -
		jmp displayexit

;n; <h4>:f [filename]</h4>

;n; Set/print filename

file		jsr skipspace
		beq +
		txa
		eor #255
		sec
		adc linebuffer
		sta filename

		ldy #0
-		iny
		inx
		lda linebuffer,x
		sta filename,y
		bne -
+
		ldx #<(filename-4)
		lda #>(filename-4)
		jmp setstatus

;n; <h4>:e [filename]</h4>

;n; Edit file. File is loaded in the background,
;n; the loaded part can be edited imediately.
;n; Paste register is not cleared!

edit		jsr file
		jmp load

;n; <h4>:w [filename]</h4>

;n; Write file.

write		jsr file
		jmp save

notcmd		.char notcmde-notcmd-1
		.text "not cmd"
notcmde
		.pend

ex_input	.proc
		sta linebuffer+1

		pha column
		ldx #<(linebuffer-4)
		lda #>(linebuffer-4)
		jsr setstatus
		lda #1
		sta linebuffer
		sta column
		inc display.ex+1
		dec tochar.mode+1

-		lsr display.now
		inc paintone.cachel+height-1
		ldx #1
		stx repeat
		dex
		stx repeat+1
		jsr waitkey
		ldx #keylookup.exkeys
		jsr keylookup
		jmp -
		.pend

ex_X		.proc
		ldx column
		dex
		bne +
		ldy linebuffer
		dey
		beq ex_exit
		rts
+
-		inx
		lda linebuffer+1,x
		sta linebuffer,x
		cpx linebuffer
		bne -
		dec linebuffer
		gcs ex_h
		.pend

ex_put		.proc
		.if TARGET==ATARI800
		cpy #32
		blt ex_h.x
		cpy #$7d
		bge ex_h.x
		.else
		tya
		asl
		cmp #$40
		blt ex_h.x
		.fi
		ldx linebuffer
		cpx #width-1
		bge ex_h.x
		inx
		stx linebuffer
-		dex
		lda linebuffer+1,x
		sta linebuffer+2,x
		cpx column
		bne -

		tya
		sta linebuffer+1,x
		.cerror ex_l & 0
		.pend

ex_l		.proc
		inc column
		lda linebuffer
		cmp column
		bge ex_h.x
		glt ex_h
		.pend

ex_h		.proc
		dec column
		beq ex_l
x		rts
		.pend


ex_dollar	.proc
		lda linebuffer
		.byte $2c
		.cerror ex_0 & 0
		.pend

ex_0		.proc
		lda #1
		sta column
		rts
		.pend

ex_exit		.proc
		lda #0
		sta linebuffer
		geq ex_return
		.pend

ex_return	.proc
		pla
		pla
		pla column
		dec display.ex+1
		inc tochar.mode+1
		ldx linebuffer
		rts
		.pend

