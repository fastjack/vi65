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

;h; <html><head><title>VI65 text editor home</title>
;h; <style>img {margin:0.5ex} h1, h3, h4 {font-family:sans-serif;} h1, h3 {font-variant:small-caps} body {width:80ex;font-family:serif}</style>
;h; </head><body>
;h; <h1>VI65 text editor</h1>
;h; <p>A VI implementation for 6502 machines.</p>

;h; <p>This is the "manual" of the multi platform VI65 0.2 editor.</p>

;h; <p>The editor (and the documentation) is far from finished, and there are
;h; a lots of bugs. Maybe the next version will be better ;)</p>

;h; <h3>Supported platforms:</h3>

;h; <p>Commodore 64, 128, 16, Plus 4, VIC20 (expanded), PET 40/80.
;h; Atari 8bit, Apple II.
;h; There's a plugin version for the <a href="http://ide64.org">IDE64</a> filemanager too.</p>

;h; <h3>Supported text modes:</h3>

;h; <ul>
;h; <li>C64 - 40/53/64/80x25 (VDC 80x25 on C128)
;h; <li>C128 - 40/53/64/80x25, VDC 80x25
;h; <li>+4 - 40x25, 53/64/80x23
;h; <li>C16 - 40x25
;h; <li>VIC20 - 22x23, 26/35/40x22
;h; <li>PET - 40/80x25
;h; <li>ATARI - 40/53/64/80x24
;h; <li>APPLE II - 40/46/56/80x24
;h; </ul>
;h; <p>Some text modes use custom 4x8, 5x8 and 6x8 charsets on graphic screen.</p>

;h; <h3>Screenshots:</h3>
;h; <a href="pic/c128vdc.png"><img src="pic/c128vdc.png" width=200 border=0 alt="C128 VDC" align="center" title="C128 in VDC 80x25"></a>
;h; <a href="pic/c64.png"><img src="pic/c64.png" width=200 border=0 alt="C64" align="center" title="C64 in 64x25"></a>
;h; <a href="pic/c16.png"><img src="pic/c16.png" width=200 border=0 alt="C16" align="center" title="C16 in 40x25"></a>
;h; <a href="pic/vic20.png"><img src="pic/vic20.png" width=200 border=0 alt="VIC20" align="center" title="VIC20 in 40x22"></a>
;h; <a href="pic/apple.png"><img src="pic/apple.png" width=200 border=0 alt="APPLE II" align="center" title="Apple II in 80x24"></a>
;h; <a href="pic/atari.png"><img src="pic/atari.png" width=200 border=0 alt="ATARI 800" align="center" title="Atari 800 in 53x24"></a>
;h; <a href="pic/pet.png"><img src="pic/pet.png" width=200 border=0 alt="PET" align="center" title="PET in 80x25"></a>
;h; <a href="pic/plus4.png"><img src="pic/plus4.png" width=200 border=0 alt="+4" align="center" title="Plus4 in 80x23"></a>

;h; <h3>Limitations:</h3>

;h; <ul>
;h; <li>251 characters in a line
;h; <li>65535 lines of text (memory runs out faster...)
;h; <li>65535 maximum count
;h; <li>Platform native text format only
;h; <li>Paste register only limited by the amount of memory
;h; <li>No extra memory support yet
;h; <li>Single buffer editing for now
;h; </ul>

;h; <p>The following key description was mostly copied from the
;h; VIM 7.2 manual.</p>

;t; <h3>Download</h3>
;t; <p><a href="vi65_v0.1.zip">VI65 v0.1</a></p>
;t; <p><a href="vi65_v0.2.zip">VI65 v0.2</a></p>
;t; <p>That's all for now.</p>
;t; <p>VI65 (C) 2010-2011 Soci/Singular &lt;soci at server c64.rulez.org&gt;</p>
;t; </body></html>

;m; <h3>Motion keys</h3>

;n; <h3>Normal mode keys</h3>

SIMPLE		= 0

C16		= 16
C64		= 64
C128		= 128
PLUS4		= 4
VIC20		= 20
VIC20BIG	= 21
PET80		= 8
PET40		= 7
ATARI800	= 800
APPLE2		= 2

PLUGIN		= 65

;TARGET		 = VIC20BIG
;GFX		 = 2

loadw		.macro
		lda #<\1
		sta \2
		lda #>\1
		sta \2+1
		.endm

movew		.macro
		lda \1
		sta \2
		lda \1+1
		sta \2+1
		.endm

pha:		.macro
		lda \@
		pha
		.endm

pla:		.macro
		pla
		sta \@
		.endm

		.if TARGET==ATARI800
zpstart		= $80
		.elsif TARGET==APPLE2
zpstart		= $77
		.else
zpstart		= $11
		.fi

		.logical zpstart
freehelps	.fill 2			;free memory list
freehelpd	.fill 2
freehelp	.fill 2

memtop		.fill 2

allocline	.fill 2

currentline	.fill 2

cursorline	.fill 2

screen		.fill 2

currenttext	.fill 2

line		.fill 2			;cursor line
column		.fill 1			;cursor column

line2		.fill 2			;top line
lines		.fill 2			;number of lines
column2		.fill 1			;left column

repeat		.fill 2
inclusive	.fill 1
linewise	.fill 1
register	.fill 1
error		.fill 1
oneless		.fill 1
activewin	.fill 1

num		.fill 3+2
zpend
		.here

		.if (TARGET==C64) || (TARGET==PLUGIN)
		*= $801-2

		.if (GFX==1) || (GFX==2) || (GFX==3)
memoryend	= $dc00
		.else
memoryend	= $ff00
		.fi

status		= $90
time		= $a2
keybuffer	= 631
keyrepeatdelay	= 651
drive		= $ba
zpsave		= $02c0
		.if GFX==0
linebuffer	= $ff00
		.else
linebuffer	= $0400
		.fi
virq		= $314
kernal		.macro
		dec $01
		.endm
ram		.macro
		inc $01
		.endm
		.elsif TARGET==VIC20BIG
		*= $1201-2

memoryend	= $8000
status		= $90
time		= $a2
keybuffer	= 631
keyrepeatdelay	= 651
drive		= $ba
linebuffer	= $150
virq		= $314
kernal		.macro
		.endm
ram		.macro
		.endm
		.elsif TARGET==VIC20
		*= $1001-2

memoryend	= $1e00
status		= $90
time		= $a2
keybuffer	= 631
keyrepeatdelay	= 651
drive		= $ba
linebuffer	= $0150
virq		= $314
kernal		.macro
		.endm
ram		.macro
		.endm
		.elsif TARGET==C16
		*= $1001-2

memoryend	= $4000
status		= $90
time		= $a5
keybuffer	= $527
keyrepeatdelay	= 1345
drive		= $ae
linebuffer	= $065e
virq		= $314
kernal		.macro
		.endm
ram		.macro
		.endm
		.elsif TARGET==PLUS4
		*= $1001-2

		.if GFX
memoryend	= $e000
		.else
memoryend	= $fd00
		.fi
status		= $90
time		= $a5
keybuffer	= $527
keyrepeatdelay	= 1345
drive		= $ae
linebuffer	= $065e
virq		= $314
kernal		.macro
		sta $ff3e
		.endm
ram		.macro
		sta $ff3f
		.endm
		.elsif (TARGET==PET40) || (TARGET==PET80)
		*= $401-2

memoryend	= $8000
status		= $96
time		= $8f
keybuffer	= 623
		.if TARGET==PET80
keyrepeatdelay	= $e5
		.elsif TARGET==PET40
keyrepeatdelay	= 1002
		.fi
drive		= $d4
linebuffer	= $0150
virq		= $90
kernal		.macro
		.endm
ram		.macro
		.endm
		.elsif TARGET==C128
		*= $1c01-2

memoryend	= $ff00
status		= $90
time		= $a2
keybuffer	= $34a
keyrepeatdelay	= 2595
drive		= $ba
linebuffer	= $0c00
virq		= $314
kernal		.macro
		sta $ff02
		.endm
ram		.macro
		sta $ff01
		.endm
		.elsif TARGET==ATARI800
		*= $0800-6

memoryend	= $bc00
linebuffer	= $0600
time		= $14
keybuffer	= $480-1
virq		= $224
kernal		.macro
		.endm
ram		.macro
		.endm
		.elsif TARGET==APPLE2
		*= $0c00-4

memoryend	= $bc00
linebuffer	= $0900
status		= 2
drive		= 2
kernal		.macro
		.endm
ram		.macro
		.endm
		.fi

		.if TARGET==ATARI800
k_cursorup	= 28
k_cursordown	= 29
k_cursorleft	= 30
k_cursorright	= 31
k_del		= 126
k_return	= 155
k_ins		= 255
k_control	= -128
		.elsif TARGET==APPLE2
k_cursordown	= 10
k_cursorup	= 11
k_cursorleft	= 255
k_cursorright	= 21
k_del		= 8
k_return	= 13
k_ins		= 255
k_control	= 64
		.else
k_cursordown	= 17
k_cursorup	= 145
k_cursorleft	= 157
k_cursorright	= 29
k_del		= 20
k_return	= 13
k_ins		= 148
k_control	= 64
		.fi

		.if TARGET==PLUGIN
		*= $1000-2

		.word $1000
		rts
		rts
		rts
		jsr $ffbd
		jmp start
		.elsif TARGET==ATARI800
		.word $ffff
		.word *+4
		.word prgend-1
		jmp start
		.elsif TARGET==APPLE2
		.word *+4
		.word prgend-*-2
		jmp start
		.else
		.word *+2
		.word ss, 2010
		.null $9e,^start
ss		.word 0
		.fi

		.if (TARGET==VIC20BIG) && (GFX!=0)
		*= $12a0		;gfxhez!
		.fi

		.if TARGET==C128
fkeys		.byte $85, $89, $86, $8a, $87, $8b, $88, $8c, $83, $84
		.elsif (TARGET==PLUS4) || (TARGET==C16)
fkeys		.byte $85, $86, $87, $89, $8a, $8b, $8c, $88
		.elsif TARGET==ATARI800
kbname		.text "K:",k_return
		.fi

		.if (TARGET==C64) || (TARGET==PLUGIN)
nmiram		sec
		.byte $90
irqram		clc
		pha
		pha $01
		lda #$37
		sta $01

		pha #>irq_return
		pha #<irq_return
		pha #$28
		bcs +
		jmp ($fffe)
+		jmp ($fffa)

irq_return	pla $01
		pla
		rti

irq		.proc
		lsr $c6
		bcc +
		ldx waitkey.write+1
		dex
		bpl e
		ldx #8
e		cpx waitkey.read+1
		beq +
		lda keybuffer
		sta keybuffer+1,x
		stx waitkey.write+1
+
old		jmp $ffff
		.pend

		.elsif (TARGET==VIC20) || (TARGET==VIC20BIG)

irq		.proc
		lsr $c6
		bcc +
		ldx waitkey.write+1
		dex
		bpl e
		ldx #8
e		cpx waitkey.read+1
		beq +
		lda keybuffer
		sta keybuffer+1,x
		stx waitkey.write+1
+
old		jmp $ffff
		.pend

		.elsif (TARGET==PET40) || (TARGET==PET80)

irq		.proc
		lsr $9e
		bcc +
		ldx waitkey.write+1
		dex
		bpl e
		ldx #8
e		cpx waitkey.read+1
		beq +
		lda keybuffer
		sta keybuffer+1,x
		stx waitkey.write+1
+
old		jmp $ffff
		.pend

		.elsif TARGET==C128
irq		.proc
		ldx $d2
		lda $100a,x
		lsr $d1
		bcs u
		lsr $d0
		bcc +
		lda keybuffer
u		ldx waitkey.write+1
		dex
		bpl e
		ldx #8
e		cpx waitkey.read+1
		beq +
		sta keybuffer+1,x
		stx waitkey.write+1
+
old		jmp $ffff
		.pend
		.elsif TARGET==ATARI800
irq		.proc
		bit critical
		bmi +
		ldx 764
		inx
		beq +
		dex
		lda #255
		sta 764
		txa

		ldx waitkey.write+1
		dex
		bpl e
		ldx #8
e		cpx waitkey.read+1
		beq +
		sta keybuffer+1,x
		stx waitkey.write+1
+
old		jmp $ffff
		.pend
		.elsif (TARGET==PLUS4) || (TARGET==C16)
		.if TARGET==PLUS4
irqram		pha
		sta $ff3e

		pha #>irq_return
		pha #<irq_return
		pha #$28
		jmp ($fffe)

irq_return	sta $ff3f
		pla
		rti
		.fi

irq		.proc
		ldx $55e
		lda $567,x
		lsr $55d
		bcs u
		lsr $ef
		bcc +
		lda keybuffer
u		ldx waitkey.write+1
		dex
		bpl e
		ldx #8
e		cpx waitkey.read+1
		beq +
		sta keybuffer+1,x
		stx waitkey.write+1
+
old		jmp $ffff
		.pend

		.fi

start
		ldx #zpend-zpstart-1
-		lda zpstart,x
		sta zpsave,x
		dex
		bpl -
		.if (TARGET==C64) || (TARGET==PLUGIN)
		#loadw irqram, $fffe
		#loadw nmiram, $fffa
		sei
		#movew virq, irq.old+1
		#loadw irq, virq
		cli
		lda #128
		sta 650
		lda #$37
		sta $01
		lda #>memoryend
		sta alloc.end+1
		.elsif TARGET==C128
		sei
		#movew virq, irq.old+1
		#loadw irq, virq
		ldx #9
-		lda #1
		sta $1000,x
		lda fkeys,x
		sta $100a,x
		dex
		bpl -
		stx $d8
		lda #$3f
		sta $d501		;kernal
		lda #$00
		sta $d502		;ram
		cli
		sta $ff00
		lda #>memoryend
		sta alloc.end+1
		.elsif (TARGET==VIC20) || (TARGET==VIC20BIG)
		lda $38
		sta alloc.end+1
		sei
		ldx #$40
		txs
		#movew virq, irq.old+1
		#loadw irq, virq
		cli
		lda #128
		sta 650
		.elsif (TARGET==PLUS4) || (TARGET==C16)
		.if TARGET==C16
		lda $38
		bpl +
		lda #$80
+		sta alloc.end+1
		.elsif TARGET==PLUS4
		.if GFX==0
		lda $38
		sta alloc.end+1
		.fi

		#loadw irqram, $fffe
		.fi
		#kernal
		sei
		#movew virq, irq.old+1
		#loadw irq, virq
		ldx #7
-		lda #1
		sta $55f,x
		lda fkeys,x
		sta $567,x
		dex
		bpl -
		cli
		.elsif (TARGET==PET40) || (TARGET==PET80)
		sei
		#movew virq, irq.old+1
		#loadw irq, virq
		cli
		lda $35
		sta alloc.end+1
		ldx #$40
		txs
		lda #14
		jsr $ffd2
		.elsif TARGET==ATARI800
		sei
		#movew virq, irq.old+1
		#loadw irq, virq
		cli
		lda $2e6
		sta alloc.end+1
		lda #20
		sta 729			;repeat wait
		lda #3
		sta 730			;repeat speed
		lda #0
		sta 702			;shift lock
		lda #255
		sta 731			;noclick
		ldx #$10
		lda #3
		sta iccom,x
		lda #<(kbname)
		sta icba,x
		lda #>(kbname)
		sta icba+1,x
		lda #4
		sta icax1,x
		lda #0
		sta icax2,x
		jsr ciov		;keyboard
		.elsif TARGET==APPLE2
		lda $74
		sta alloc.end+1
		lda #1
		sta $aab6		;dos language flag
		sta $76			;current line number
		sta $33			;prompt char
		.fi
		dec alloc.end+1
		jsr clearmem

		lda #windows.status
		jsr setwin
		jsr clearwin
		lda #windows.main
		jsr selectwin

		.comment
		.if TARGET!=PLUGIN
		ldy #7
		cpy #width-3
		blt +
		ldy #width-3
+		sty filename
		iny
-		dey
		lda nu,y
		sta filename+1,y
		tya
		bne -
		jsr load
		jmp +
nu		.text "doc.seq"
+
		.fi
		.endc
		.if TARGET==PLUGIN
		ldy $b7
		cpy #width-3
		blt +
		ldy #width-3
+		sty filename
		iny
-		dey
		lda ($bb),y
		sta filename+1,y
		tya
		bne -
		jsr load
+		.else
		lda #0
		sta filename
		.fi
		jsr displayinit

		.if SIMPLE
		jsr waitkey
-		jsr insertmode
		jsr cmdmode
		jmp -
		.else
kloop2		lsr display.now

		ldx #1
		stx oneless
		stx repeat
		stx waitkeyrepeat.norepeat
		dex
		stx repeat+1
		stx linewise
		ldx #registers.unnamed
		stx register
		jsr waitkeyrepeat

		sec
		ror error
		ldx #keylookup.normalkeys
		jsr keylookup
		bit error
		bmi kloop2
	    ;	 dec 1
	   ;	 inc $d020
	  ;	 inc 1
		jmp kloop2

motiontry	tya
		ldx #keylookup.motionkeys
		.fi
keylookup	.proc
		tay
		sta j+1
-		inx
		lda keys-1,x
		beq +
j		cmp #0
		bne -
+		txa
		asl
		tax
		pha keyroutines-1,x
		pha keyroutines-2,x
rrts		rts

keys
		.logical 0
		.if !SIMPLE
normalkeys	.byte "x", "X", "D", "C", "s", "S"
		.byte "y", "p", "P"
		.byte "o", "O"
		.byte "i", k_ins, "I"
		.byte "a", "A"
		.byte "J"
		.byte "d", "g", "z", "c"
		.byte "m"
		.byte "g"-k_control, ":", "/"
		.byte "e"-k_control, "y"-k_control
		.byte "f"-k_control
		.byte "b"-k_control
		.byte 0
		.fi

insertkeys	.byte k_del
		.byte 27, 3
		.byte k_return
		.byte "e"-k_control, "y"-k_control
		.byte 0

motionkeys
		.byte "h"
		.if !SIMPLE
		.byte 8
		.byte "j", 10, 14
		.byte "k", 16
		.byte "l"
		.byte k_del, 32
		.byte "0"
		.byte "f", "t"
		.byte "F", "T"
		.byte "$"
		.byte 94, 169
		.byte "H", "M", "L"
		.byte "G"
		.byte 95, "'"
		.byte "+", k_return
		.byte "-"
		.fi
motionkeys2	.byte k_cursordown
		.byte k_cursorup
		.byte k_cursorright
		.byte k_cursorleft
		.byte 19, 147
		.byte 136
		.byte 133
		.byte 0

		.if !SIMPLE
gkeys		.byte "g"
		.byte "I"
		.byte "m"
		.byte "0", 19
		.byte "$", 147
		.byte 0

zkeys		.byte "h", k_cursorleft
		.byte "l", k_cursorright
		.byte "H", "L"
		.byte "s", "e"
		.byte 0
		.fi

cmdkeys		.byte k_cursorright
		.byte k_cursorleft
		.byte 19, 147
		.byte "b"-k_control, "e"-k_control
		.byte 27, 3
		.byte k_del, k_return
		.byte 0
		.here

keyroutines
		.if !SIMPLE
		.rta kx, kX, kD, kC, ks, kS
		.rta ky, kp, kP
		.rta ko, kO
		.rta insertmode, insertmode, kI
		.rta ka, kA
		.rta kJ
		.rta kd, kg, kz, kc
		.rta motion_m
		.rta ctrlg, cmdmode, searchmode
		.rta scroll_ctrl_e, scroll_ctrl_y
		.rta scroll_ctrl_f
		.rta scroll_ctrl_b
		.rta motiontry
		.fi

		.rta kX
		.rta insertmode.exit, insertmode.exit
		.rta insertmode.kreturn
		.rta insert_ctrl_e, insert_ctrl_y
		.rta insertmode.put

		.rta motion_h
		.if !SIMPLE
		.rta motion_h
		.rta motion_j, motion_j, motion_j
		.rta motion_k, motion_k
		.rta motion_l
		.rta motion_backspace, motion_space
		.rta motion_0
		.rta motion_f, motion_t
		.rta motion_F, motion_T
		.rta motion_dollar
		.rta motion_uparrow, motion_bar
		.rta motion_H, motion_M, motion_L
		.rta motion_G
		.rta motion_backtick, motion_tick
		.rta motion_plus, motion_plus
		.rta motion_minus
		.fi
		.rta motion_j
		.rta motion_k
		.if SIMPLE
		.rta motion_space
		.rta motion_backspace
		.else
		.rta motion_l
		.rta motion_h
		.fi
		.rta motion_0, motion_dollar
		.rta scroll_ctrl_f
		.rta scroll_ctrl_b
		.rta rrts

		.if !SIMPLE
		.rta motion_gg
		.rta kgI
		.rta motion_gm
		.rta motion_g0, motion_g0
		.rta motion_gdollar, motion_gdollar
		.rta rrts

		.rta scroll_zh, scroll_zh
		.rta scroll_zl, scroll_zl
		.rta scroll_zH, scroll_zL
		.rta scroll_zs, scroll_ze
		.rta rrts
		.fi

		.rta motion_l
		.rta cmd_h
		.rta cmd_0, motion_dollar
		.rta cmd_0, motion_dollar
		.rta cmd_exit, cmd_exit
		.rta cmd_X, cmd_return
		.rta cmd_put
		.pend

waitkey		.proc
-
		.if TARGET==APPLE2
		lda $c000
		bmi +
		jsr display
		jsr cursorup
		jmp -

+		and #$7f
		sta $c010
		.else
read		ldx #0
write		cpx #0
		bne +
		jsr display
		jsr cursorup
		jmp -

+		dex
		bpl +
		ldx #8
+		lda keybuffer+1,x
		stx read+1
		.fi
		.if TARGET==ATARI800
		sec
		ror critical
		sta 764
		ldx #$10
		lda #7
		sta iccom,x
		lda #<(ej+1)
		sta icba,x
		lda #>(ej+1)
		sta icba+1,x
		lda #1
		sta icbl,x
		lsr
		sta icbl+1,x
		jsr ciov
		lsr critical
ej		lda #0
		.fi
		pha
		jsr cursoroff

		.if (TARGET!=ATARI800) && (TARGET!=APPLE2)
		lda keyrepeatdelay
		lsr
		beq +
		lda #2
		sta keyrepeatdelay
+
		.fi
		pla
		rts
		.pend

cursorup	.proc
		.if TARGET==APPLE2
		lda #0
		inc *-1
		bne +
		.else
		lda time
		and #$f0
cp		cmp #0
		beq +
		sta cp+1
		.fi
		jmp cursor
+		rts
		.pend

		.if !SIMPLE
waitkeyrepeat	.proc
		jsr waitkey
		cmp #"1"
		blt ik
		cmp #"9"+1
		blt +
ik		rts

+		and #15
		ldx repeat+1
		stx a2+1
		ldx repeat
		stx a1+1
		ldx #0
		stx repeat+1
		stx norepeat
-		sta repeat
		jsr waitkey
		cmp #"0"
		blt ik2
		cmp #"9"+1
		bge ik2
		and #15
		pha
		ldx #10
		jsr mulrepeatl
		pla
		clc
		adc repeat
		bcc -
		inc repeat+1
		bne -
		lda #255
		sta repeat+1
		gne -

ik2		pha
a1		ldx #0
a2		lda #0
		jsr mulrepeat
		pla
		rts

norepeat	.byte 1
		.pend
		.fi

display		.proc
now		= *+1
		lda #0
		beq +
		lda loading
		bne load.part
		geq garbageone
+
		jsr cursoroff
		jsr displaylowinit
		inc now

		pha activewin
		sta oa+1
		tay

		lda #windows.main
		jsr doit
		lda #windows.status
		jsr doit

		lda #255
		sta paintone.garbagelow+1

		pla
		jmp selectwin

doit		jsr selectwin

		jsr normcolumn
		pha
		sec
		sbc column2
		blt +
		cmp #width
		blt ok
+		pla
		pha
		sec
		sbc #width/2
		bcs +
		lda #0
+		sta column2

ok		lda line
		sec
		sbc line2
		tax
		lda line+1
		sbc line2+1
		blt +
		cpx #height-1
		sbc #0
		blt ok2
+		lda line
		sec
		sbc #height/2
		tax
		lda line+1
		sbc #0
		bcs +
		lda #0
		tax
+		sta line2+1
		stx line2
ok2
		lda line
		sec
		sbc line2
		tax
		pha cursorline+1
		lda cursorline
		jmp +

-		ldy #3
		pha (currentline),y
		dey
		lda (currentline),y
+		sta currentline
		pla currentline+1
		dex
		bpl -
		.comment
		lda tochar.mode+1
		beq +
		ldx line
		lda line+1
		ldy #0
		jsr ctrlg.tst
		lda #"-"
		sta linebuffer+1,y
		iny
		ldx lines
		lda lines+1
		jsr ctrlg.tst
		lda #"-"
		sta linebuffer+1,y
		iny
		sty t+1
		ldy #2
		lda (cursorline),y
		tax
		iny
		lda (cursorline),y
t		ldy #0
		jsr ctrlg.tst
		lda #"-"
		sta linebuffer+1,y
		iny
		ldx cursorline
		lda cursorline+1
		jsr ctrlg.tst
		lda #"-"
		sta linebuffer+1,y
		iny
		sty t2+1
		ldy #0
		lda (cursorline),y
		tax
		iny
		lda (cursorline),y
t2		ldy #0
		jsr ctrlg.tst
+
		;lda #"-"
		;sta linebuffer+1,y
		;iny
		;ldx line0
		;lda line0+1
		;jsr ctrlg.tst
		.endc
		pla
oa		ldx #0
		ldy activewin
		jmp displaylow
		.pend

normcolumn	.proc			;C=1 if last char or over
		lda column
		.cerror normcolumn2 & 0
		.pend

normcolumn2	.proc
		ldy #4
		cmp (cursorline),y
		blt +
		lda (cursorline),y
		beq +
		sbc oneless
+		rts
		.pend

kg		.proc
		jsr waitkey
		ldx #keylookup.gkeys
		jmp keylookup
		.pend

;n; <h4>gI</h4>

;n; Insert text in column 1.

kgI		.proc
		jsr motion_0
		jmp insertmode
		.pend

;n; <h4>c{motion}</h4>

;n; Delete {motion} text <!--[into register x]--> and start
;n; insert.

kc		.proc
		lsr cursor.size
		jsr waitkeyrepeat
		asl cursor.size
		.byte $2c
		.cerror kC & 0
		.pend
;n; <h4>C</h4>

;n; Delete from the cursor position to the end of the
;n; line and [count]-1 more lines <!--[into register x]-->, and
;n; start insert. Synonym for c$

kC		.proc
		lda #"$"
		.byte $2c
		.cerror ks & 0
		.pend
;n; <h4>s</h4>

;n; Delete [count] characters <!--[into register x]--> and start
;n; insert (s stands for Substitute).  Synonym for "cl"

ks		.proc
		lda #"l"
		.byte $2c
		.cerror kS & 0
		.pend
;n; <h4>S</h4>

;n; Delete [count] lines <!--[into register x]--> and start
;n; insert.  Synonym for "cc" linewise.

kS		.proc
		lda #"c"

		lsr cursor.size
		cmp #"c"
		jsr kd.in
		asl cursor.size
		lda linewise
		bne kO
		geq insertmode
		.pend

;n; <h4>y{motion}</h4>

;n; Yank {motion} text <!--[into register x]-->.

ky		.proc
		pha column
		lsr cursor.size
		jsr waitkeyrepeat
		cmp #"y"
		jsr kd.in
		asl cursor.size
		ldx #1
		stx repeat
		dex
		stx repeat+1
		jsr kP
		pla
		jmp tochar
		.pend

;n; <h4>d{motion}</h4>

;n; Delete text that {motion} moves over <!--[into register
;n; x]-->.

kd		.proc
		lsr cursor.size
		jsr waitkeyrepeat
		cmp #"d"
		jsr in
		asl cursor.size
		lda column
		jmp tochar

in		bne +
		lda #0
		jsr sbcrepeat
		lda #"j"

+		.byte $2c
		.cerror kD & 0
		.pend
;n; <h4>D</h4>

;n; Delete the characters under the cursor until the end
;n; of the line and [count]-1 more lines <!--[into register
;n; x];--> synonym for "d$".

kD		.proc
		lda #"$"
		.byte $2c
		.cerror kx & 0
		.pend
;n; <h4>x</h4>

;n; Delete [count] characters under and after the cursor
;n; <!--[into register x]--> (not linewise).  Does the same as
;n; "dl".

kx		.proc
		lda #"l"
		.byte $2c
		.cerror kX & 0
		.pend
;n; <h4>X</h4>

;n; Delete [count] characters before the cursor <!--[into
;n; register x]--> (not linewise).  Does the same as "dh".

kX		.proc
		lda #"h"
		pha
		lda #0
		sta inclusive
		sta linewise
		ldx #marks.end
		jsr setmark
		ldx #references.temp
		jsr insertref
		pla
		lsr oneless
		php
		ldx #keylookup.motionkeys
		jsr keylookup
		plp
		rol oneless

		lda marks.line+marks.end
		cmp line
		lda marks.line+1+marks.end
		sbc line+1
		bge +
		ldx #2
-		lda line,x
		ldy marks+marks.end,x
		sta marks+marks.end,x
		tya
		sta marks+marks.start,x
		sta line,x
		dex
		bpl -

		ldx #references.end
		jsr insertref
		ldx #references.temp+2
		jsr reftocursor
		lda #references.temp
		jsr deleteref
		ldx #references.start
		jsr insertref2
		jmp ti
+
		ldx #marks.start
		jsr setmark
		ldx #references.start
		jsr insertref2
		ldx #references.temp+2
		jsr reftocursor
		lda #references.temp
		jsr deleteref
		ldx #references.end
		jsr insertref
ti
		lda register
		jsr free_register
		lda register
		clc
		adc #<registers
		sta cursorline
		lda #0
		adc #>registers
		sta cursorline+1
		ldx #references.insert
		lda register
		sta references.reg,x
		jsr insertref

		ldx register
		lda linewise
		sta registers.linewise,x
		beq noline

		lda marks.line+marks.end
		sec
		sbc line
		tay
		lda marks.line+1+marks.end
		sbc line+1
		iny
		sty repeat
		bne +
		adc #0
+		sta repeat+1

		ldx register
		lda repeat
		sta registers.lines,x
		lda repeat+1
		sta registers.lines+1,x

		ldx #references.end
		jsr reftocursor

		ldy #references.insert
		ldx #references.start
		jsr borona
		ldy #references.end
		ldx #references.insert
		jsr borona
		ldy #references.start
		ldx #references.end
		jsr borona

		jsr deleteline

		ldx line
		lda line+1
		jsr toline
		jmp motion_uparrow

noline		lda #0
		sta registers.lines,x
		sta registers.lines+1,x
		lda marks.column+marks.end
		cmp column
		bge +
		ldx column
		sta column
		txa
		sec
+		sbc column
		clc
		adc inclusive
		blt +
		lda #255
+		beq ur
		sta repeat

		ldx #references.start
		jsr reftocursor

		ldy #4
		lda (cursorline),y
		sec
		sbc column
		blt ur
		beq ur
		cmp repeat
		bge +
		sec
		sta repeat
+
		lda cursorline
		clc
		adc column
		sta cursorline
		bcc +
		inc cursorline+1
+		ldx repeat
		lda #references.insert
		jsr append_regref
		bcs +
		jsr copy_cursor_to_alloc

+		ldx #references.start
		jsr reftocursor

		ldy #4
		lda (cursorline),y
		sec
		sbc repeat
		jsr linemod
		bcs ur

		ldy #4
		tya
		sec
		adc (allocline),y
		sta en+1

		ldx column
		inx

		iny
		gne en

-		dex
		bne +
		lda repeat
		clc
		adc currentline
		sta currentline
		bcc +
		inc currentline+1

+		lda (currentline),y
		sta (allocline),y
		iny
		bne en
		inc currentline+1
		inc allocline+1
en		cpy #0
		bne -

ur		lda #references.insert
		jsr deleteref
		lda #references.end
		jsr deleteref
		ldx #references.start
		jsr reftocursor
		lda #references.start
		jmp deleteref
		.pend
;n; <h4>O</h4>

;n; Begin a new line above the cursor and insert text

kO		.proc
		clc
		.byte $a9
		.pend
;n; <h4>o</h4>

;n; Begin a new line below the cursor and insert text

ko		.proc
		sec
in		ldx #1
		stx repeat
		dex
		stx repeat+1
		lda #registers.nl
		sta register
		jsr do
		jmp insertmode

do		bcc kP
		gcs kp
		.pend
;n; <h4>p</h4>

;n; Put the text <!--[from register x]--> after the cursor
;n; [count] times.

kp		.proc
		ldy register
		lda registers.linewise,y
		beq +
		jsr cursornext
		jmp kP
+		lsr oneless
		jsr motion_l
		inc oneless
		.cerror kP & 0
		.pend
;n; <h4>P</h4>

;n; Put the text <!--[from register x]--> before the cursor
;n; [count] times.

kP		.proc

		ldy register
		lda registers.linewise,y
		bne nl
		lda registers.first,y
		ldx registers.first+1,y
		sta currenttext
		stx currenttext+1
		ldy #4
		lda (currenttext),y
		clc
		adc column
		pha
		jsr inserttext
		pla
		bcc +
		rts
+		sbc #1-1
		jmp tochar
nl
		ldx #references.temp
		jsr insertref2
		ldx #references.insert
		lda #registers.file
		sta references.reg,x
		jsr insertref2
		jsr doit
		ldx line
		lda line+1
		jsr toline
		jmp motion_uparrow

doit		jsr savebuffer
		ldx #marks.start
		jsr setmark

lp
		ldy register
		ldx #endmarks-marks
-		lda line
		cmp marks-3,x
		lda line+1
		sbc marks-2,x
		bge +
		lda marks-3,x
		adc registers.lines,y
		sta marks-3,x
		lda marks-2,x
		adc registers.lines+1,y
		sta marks-2,x
+		dex
		dex
		dex
		bne -

		lda registers.lines,y
		eor #255
		sta screen
		lda registers.lines+1,y
		eor #255
		sta screen+1
		lda registers.first,y
		ldx registers.first+1,y
		gne +

-		ldy #4
		lda (cursorline),y
		tax
		lda #references.insert
		jsr append_regref
		bcs ejj
		jsr copy_cursor_to_alloc
		ldy #1
		lda (cursorline),y
		tax
		dey
		lda (cursorline),y
+		sta cursorline
		stx cursorline+1

		inc screen
		bne -
		inc screen+1
		bne -

		lda repeat
		bne +
		dec repeat+1
+		dec repeat
		bne lp
		lda repeat+1
		bne lp
ejj
		jsr loadbuffer

		lda #references.insert
		jsr deleteref
		ldx #references.temp
		jsr reftocursor
		lda #references.temp
		jmp deleteref
		.pend

free_register	.proc
		pha
		tay
		lda registers.last,y
		ldx registers.last+1,y

-		sta currentline
		stx currentline+1
		ldy #3
		lda (currentline),y
		tax
		lda #1
		sta (currentline),y
		dey
		lda (currentline),y
		cpx #1
		bne -
		pla
		.cerror clear_register & 0
		.pend

clear_register	.proc
		tax
		clc
		adc #<registers
		sta registers.last,x
		sta registers.first,x
		lda #0
		sta registers.len,x
		sta registers.lines,x
		sta registers.lines+1,x
		adc #>registers
		sta registers.last+1,x
		sta registers.first+1,x
		rts
		.pend

append_regref	.proc
		pha
		txa
		jsr alloc
		pla
		bcs e
		tay
		ldx references.reg,y
		inc registers.lines,x
		bne +
		inc registers.lines+1,x
+		tax
		ldy #3
		lda references.prev+1,x
		sta currentline+1
		sta (allocline),y
		dey
		lda references.prev,x
		sta currentline
		sta (allocline),y
		dey
		lda (currentline),y
		sta (allocline),y
		lda allocline+1
		sta references.prev+1,x
		sta (currentline),y
		dey
		lda (currentline),y
		sta (allocline),y
		lda allocline
		sta references.prev,x
		sta (currentline),y
e		rts
		.pend

copy_cursor_to_alloc .proc
		ldy #4
		lda (cursorline),y
		beq e
		tax
-		iny
		lda (cursorline),y
		sta (allocline),y
		dex
		bne -
e		rts
		.pend

deleteline	.proc
		ldx #endmarks-marks
-		ldy marks-3,x
		cpy line
		lda marks-2,x
		sbc line+1
		blt +
		tya
		sbc repeat
		sta marks-3,x
		tay
		lda marks-2,x
		sbc repeat+1
		sta marks-2,x
		blt b
		cpy line
		sbc line+1
		bge +
b		lda #255
		sta marks-1,x
+		dex
		dex
		dex
		bne -

		lda lines
		sec
		sbc repeat
		sta lines
		lda lines+1
		sbc repeat+1
		sta lines+1
		ora lines
		bne emptybuf.x
		lda #statusmsg.noline
		jsr setstatusmsg
		.cerror emptybuf & 0
		.pend

emptybuf	.proc
		lda #0
		jsr alloc
		bcs x
		ldx activewin
		ldy windows.curref,x
		ldx references.reg,y
		lda allocline
		sta cursorline
		sta registers.first,x
		sta registers.last,x
		lda allocline+1
		sta cursorline+1
		sta registers.first+1,x
		sta registers.last+1,x
		txa
		ldy #0
		sty lines+1
		clc
		adc #<registers
		sta (allocline),y
		ldy #2
		sta (allocline),y
		iny
		lda #0
		adc #>registers
		sta (allocline),y
		ldy #1
		sty lines
		sta (allocline),y
x		rts
		.pend
;n; <h4>J</h4>

;n; Join 2 lines.

kJ		.proc
		ldy #1
		lda (cursorline),y
		beq j
		sta currentline+1
		dey
		lda (cursorline),y
		sta currentline
		ldy #4
		clc
		lda (cursorline),y
		beq +
		adc #4
		tay
		lda (cursorline),y
		ldy #4
		eor #32
		beq +
		lda #1
+		sta ej+1
		lsr
		lda (cursorline),y
		adc (currentline),y
		bcs j
		jsr linemod
		bcc +
j		rts

+		ldy #4
		lda (currentline),y
		sta u+1
		pha
		iny
		tax
		beq +
-		lda (currentline),y
		sta (allocline),y
		iny
		dex
		bne -
+		lda ej+1
		beq +
		lda #32
		sta (allocline),y
+
		ldy #1
		lda (allocline),y
		sta currentline+1
		dey
		lda (allocline),y
		sta currentline
		lda (currentline),y
		sta (allocline),y
		iny
		lda (currentline),y
		sta (allocline),y
		ldy #3
		lda #1
		sta (currentline),y
		pla
		clc
ej		adc #0
		adc allocline
		sta allocline
		bcc +
		inc allocline+1
+		ldy #4
		lda (currentline),y
		iny
		tax
		beq +

-		lda (currentline),y
		sta (allocline),y
		iny
		dex
		bne -

+		ldy #1
		lda (cursorline),y
		sta currentline+1
		dey
		lda (cursorline),y
		sta currentline
		ldy #3
		lda cursorline+1
		sta (currentline),y
		dey
		lda cursorline
		sta (currentline),y

u		lda #0
		jmp tochar
		.pend

split		.proc
		ldy #4
		lda (cursorline),y
		sec
		sbc column
		jsr alloc
		bcs baj
		ldy #1
		lda #0
		sta (allocline),y
		iny
		lda #<fakelist
		sta (allocline),y
		iny
		lda #>fakelist
		sta (allocline),y
		lda allocline
		sta fakelist
		lda allocline+1
		sta fakelist+1

		lda column
		jsr linemod
		lda fakelist
		sta allocline
		lda fakelist+1
		sta allocline+1
		bcc +
		ldy #3
		lda #1
		sta (allocline),y
baj		rts

+		inc lines
		bne +
		inc lines+1
+		ldx column
		beq +
		ldy #4
-		iny
		lda (currentline),y
		sta (cursorline),y
		dex
		bne -
+
		ldy #4
		lda (allocline),y
		beq +
		tax

		lda currentline
		clc
		adc column
		sta currentline
		bcc e
		inc currentline+1
e

-		iny
		lda (currentline),y
		sta (allocline),y
		dex
		bne -
+
		ldy #0
		lda (cursorline),y
		sta (allocline),y
		sta currentline
		lda allocline
		sta (cursorline),y
		iny
		lda (cursorline),y
		sta (allocline),y
		sta currentline+1
		lda allocline+1
		sta (cursorline),y
		iny
		lda cursorline
		sta (allocline),y
		iny
		lda cursorline+1
		sta (allocline),y

		lda allocline+1
		sta (currentline),y
		dey
		lda allocline
		sta (currentline),y
		clc
		rts
		.pend

fakelist	.word 0

alloc		.proc
		pha
		clc
		adc #5
		bcs +
		adc memtop
		tay
		lda memtop+1
		adc #0
end		cmp #>memoryend
		blt fits
		jsr garbage
		jsr garbage
+		pla
		bcc alloc
		lda #statusmsg.nomem
		jsr setstatusmsg
		sec
		rts

fits		ldx memtop
		stx allocline
		ldx memtop+1
		stx allocline+1

		sta memtop+1
		sty memtop
		ldy #4
		pla (allocline),y	;size
		;clc
		rts
		.pend

garbage		.proc
-		jsr garbageone
		bne -
		rts
		.pend

garbageone	.proc
		lda freehelps
		cmp memtop
		lda freehelps+1
		sbc memtop+1
		bcc +
		lda freehelpd+1
		beq baj
		sta memtop+1
		lda freehelpd
		sta memtop
		clc
baj
		lda #<memory
		sta freehelps
		lda #>memory
		sta freehelps+1
		lda #0
		sta freehelpd+1
		rts

+		ldy #3
		lda (freehelps),y
		cmp #1
		beq free
		ldx freehelpd+1
		beq skip

		sta freehelp+1
		dey
		lda (freehelps),y
		sta freehelp
		dey
		txa
		sta (freehelp),y
		dey
		lda freehelpd
		sta (freehelp),y

		lda (freehelps),y
		sta freehelp
		iny
		lda (freehelps),y
		sta freehelp+1
		iny
		lda freehelpd
		sta (freehelp),y
		iny
		txa
		sta (freehelp),y

		iny
		tya
		sec
		adc (freehelps),y
		lsr
		tax

		lda freehelps
		eor cursorline
		bne +
		lda freehelps+1
		eor cursorline+1
		bne +
		#movew freehelpd, cursorline
+		ldy #0
-		lda (freehelps),y
		sta (freehelpd),y
		iny
		lda (freehelps),y
		sta (freehelpd),y
		iny
		dex
		bne -
		bcc +
		lda (freehelps),y
		sta (freehelpd),y
		iny
		clc
+		tya
		adc freehelpd
		sta freehelpd
		tya
		bcc n
		clc
		inc freehelpd+1
		gcc n

free		lda freehelpd+1
		bne skip
		#movew freehelps, freehelpd
		sta paintone.garbagelow+1
skip		ldy #4
		tya
		sec
		adc (freehelps),y
n		adc freehelps
		sta freehelps
		bcc +
		inc freehelps+1
+		ora #1			;z=1
		rts
		.pend
; CTRL-G
;
; free memory

ctrlg		.proc
		jsr garbage
		ldy #0
-		lda freetxt,y
		sta linebuffer+1,y
		iny
		cpy #5
		blt -
		lda #0
		sec
		sbc memtop
		tax
		lda alloc.end+1
		sbc memtop+1
		jsr tst
		ldx #<(linebuffer-4)
		lda #>(linebuffer-4)
		jmp setstatus

tst		jsr konv
		ldx #253
-		lda num+3,x
		jsr hex
		inx
		bne -
		lda hex.e+1
		bne +
		iny
+		sty linebuffer
		rts

konv		stx num+3
		sta num+4
		lda #0
		sta num
		sta num+1
		sta num+2
		sta hex.e+1
		php
		sei
		sed
		sec

-		rol num+3
		rol num+4
		bne +
		lda num+3
		bne +
		plp
		rts

+		ldx #2
-		lda num,x
		adc num,x
		sta num,x
		dex
		bpl -
		gmi --

freetxt		.text "free:"
		.pend

hex		.proc
		pha
		lsr
		lsr
		lsr
		lsr
		jsr o
		pla
o		and #15
		cmp #10
		blt +
		adc #$26
+
		eor #$30
		sta linebuffer+1,y
		eor #$30
e		ora #0
		beq +
		sta e+1
		iny
+		rts
		.pend

clearmem	.proc
		#ram
		lda #registersend-registers-(registers.file-registers.nl)
-		pha
		jsr clear_register
		pla
		sec
		sbc #registers.file-registers.nl
		bne -			;skip newline
		sta activewin
		sta paintone.garbagelow+1
		ldx #endmarks-marks
		lda #255
-		sta marks,x
		dex
		bpl -
		jsr garbageone.baj
		#loadw memory, memtop
		.cerror clearwin & 0
		.pend

clearwin	.proc
		jsr emptybuf
		jsr motion_0
		sta line2
		sta line2+1
		sta line
		sta line+1
		sta column2
		rts
		.pend

setwin		.proc
		pha

		ldx #0
		ldy activewin
-		lda line,x
		sta windows,y
		iny
		inx
		cpx #windows.start-windows
		blt -

		ldy activewin
		ldx windows.curref,y
		jsr insertref2

		pla activewin
		rts
		.pend

selectwin	.proc
		cmp activewin
		beq +
		jsr setwin
		tay

		ldx #0
-		lda windows,y
		sta line,x
		iny
		inx
		cpx #windows.start-windows
		blt -

		ldy activewin
		ldx windows.curref,y
		jsr reftocursor
		txa
		jmp deleteref

+		rts
		.pend

statusmsg	.proc
		.logical 0
noname		.ptext "-- no file name --"
nomem		.ptext "-- out of memory --"
noline		.ptext "-- empty --"
insert		.ptext "-- insert --"
notfound	.ptext "-- not found --"
notcmd		.ptext "-- not a command --"
ioerr		.ptext "-- i/o error --"
banner		.ptext "vi65 0.2 soci/singular"
		.here
		.pend

setstatusmsg	.proc
		clc
		adc #<(statusmsg-4)
		tax
		lda #>(statusmsg-4)
		adc #0
		.cerror setstatus & 0
		.pend

setstatus	.proc
		stx currenttext
		sta currenttext+1
		pha activewin
		lda #windows.status
		jsr selectwin

		ldy #4
		lda (currenttext),y
		pha
		inc alloc.end+1
		jsr linemod
		dec alloc.end+1
		pla
		bcs +
		beq +
		tax
		ldy #5
-		lda (currenttext),y
		sta (cursorline),y
		iny
		dex
		bne -

+		pla
		jmp selectwin
		.pend

load		.proc
		jsr checkname
		lda #registers.file
		jsr free_register
		#loadw (registers+registers.file), cursorline
		lda #0
		sta column
		sta line
		sta line+1
		sta line2
		sta line2+1
		sta lines
		sta lines+1
		ldx #references.load
		lda #registers.file
		sta references.reg,x
		jsr insertref
		.if TARGET==ATARI800
		lda #4
		jsr open
		.elsif TARGET==APPLE2
		lda #255
		sta $d8			;onerr flag
		lda #<nomem
		sta $9d5a
		lda #>nomem
		sta $9d5b
		tsx
		stx oldsp+1
		lda #close.rd
		jsr open
		.else
		#kernal
		ldy #0
		jsr open
		ldx #1
		jsr chkin
		#ram
		.fi
		lda #1
		sta loading

		.if (TARGET!=ATARI800) && (TARGET!=APPLE2)
		ldx #k_return
		lda filename+1
		cmp #"$"
		bne +
		#kernal
		jsr chrin
		jsr chrin
		#ram
		ldx #0
+		stx eol+1
		.fi

part		jsr savebuffer

loop		.if TARGET==ATARI800
		ldx #$20
		lda #5
		sta iccom,x
		lda #<(linebuffer+1)
		sta icba,x
		lda #>(linebuffer+1)
		sta icba+1,x
		lda #255
		sta icbl,x
		lda #0
		sta icbl+1,x
		jsr ciov		;input
		bmi nomem
		ldx icbl+$20
		dex
		.elsif TARGET==APPLE2
		ldx #0
-		jsr moncin
		and #$7f
		cmp #k_return
		beq +
		sta linebuffer+1,x
		inx
		cpx #250
		blt -
+
		.else
		ldx #0
		lda filename+1
		cmp #"$"
		bne ndir
		#kernal
		jsr chrin
		jsr chrin
		jsr chrin
		tax
		jsr chrin
		#ram
		ldy #0
		jsr ctrlg.tst
		lda status
		bne nomem
		lda #32
		sta linebuffer+1,y
		iny
		tya
		tax
		#kernal
		jsr chrin
		#ram
		cmp #32
		bge eol
ndir
-		#kernal
		jsr chrin
		#ram
eol		cmp #k_return
		beq +
		sta linebuffer+1,x
		inx
		cpx #250
		bge +
		lda status
		beq -
		eor #$40
		beq +
		dex
		beq nomem
+
		.fi

		stx linebuffer

		lda #references.load
		jsr append_regref
		bcs +

		ldy #4
		ldx linebuffer-4,y
		beq +
-		iny
		lda linebuffer-4,y
		sta (allocline),y
		dex
		bne -
+
		.if (TARGET==ATARI800) || (TARGET==APPLE2)
		bcc j
		.else
		bcs nomem
		lda status
		beq j
		.fi

nomem
		.if TARGET==APPLE2
oldsp		ldx #0
		txs
		.fi

		jsr close

		.if (TARGET!=ATARI800) && (TARGET!=APPLE2)
		lda status
		and #$bf
		beq +
		lda #statusmsg.ioerr
		jsr setstatusmsg
+
		.fi

		lda #references.load
		jsr deleteref
		lda #0
		sta loading
		geq +

j
		.if TARGET==APPLE2
		lda $c000
		bmi +
		.else
		lda waitkey.read+1
		eor waitkey.write+1
		bne +
		.fi
		jsr cursorup
		lda line2
		clc
		adc #height
		eor registers.lines+registers.file
		bne loop
		lda line2+1
		adc #0
		eor registers.lines+1+registers.file
		bne loop
+		lsr display.now
		lda cursorline
		cmp #<(registers+registers.file)
		bne +
		lda cursorline+1
		cmp #>(registers+registers.file)
		bne +
		#movew registers.first+registers.file, cursorline

+		jsr loadbuffer
		ora lines
		bne +
		jmp emptybuf
+		rts
		.pend

loadbuffer	.proc
		lda registers.lines+registers.file
		sta lines
		lda registers.lines+registers.file+1
		sta lines+1
		rts
		.pend

savebuffer	.proc
		lda lines
		sta registers.lines+registers.file
		lda lines+1
		sta registers.lines+registers.file+1
		rts
		.pend

loading		.byte 0

checkname	.proc
		lda filename
		bne +
		pla
		pla
		lda #statusmsg.noname
		jmp setstatusmsg
+		rts
		.pend

save		.proc
		jsr checkname
		.if TARGET==ATARI800
		lda #8
		jsr open
		.elsif TARGET==APPLE2
		lda #255
		sta $d8			;onerr flag
		lda #<ki
		sta $9d5a
		lda #>ki
		sta $9d5b
		tsx
		stx oldsp+1
		lda #close.wr
		jsr open
		.else
		#kernal
		ldy #1
		jsr open
		ldx #1
		jsr chkout
		#ram
		.fi

		lda line
		sta old1+1
		lda line+1
		sta old2+1

		clc
		jsr tolinesub
		lda lines
		ora lines+1
		beq ki

loop
		.if TARGET==ATARI800
		ldx #$20
		lda #9
		sta iccom,x
		lda cursorline
		clc
		adc #5
		sta icba,x
		lda cursorline+1
		adc #0
		sta icba+1,x
		ldy #4
		lda (cursorline),y
		bne +
		lda #11
		sta iccom,x
		lda #<(kbname+2)
		sta icba,x
		lda #>(kbname+2)
		sta icba+1,x
		lda #1
+		sta icbl,x
		lda #0
		sta icbl+1,x
		jsr ciov		;output
		.elsif TARGET==APPLE2
		ldy #4
		lda (cursorline),y
		beq +
		tax
-		iny
		lda (cursorline),y
		eor #$80
		cmp #$84
		beq +
		jsr moncout
+		dex
		bne -
+		lda #k_return^$80
		jsr moncout
		.else
		ldy #4
		lda (cursorline),y
		beq +
		tax
-		iny
		lda (cursorline),y
		#kernal
		jsr chrout
		#ram
		dex
		bne -
+		lda #k_return
		#kernal
		jsr chrout
		#ram
		lda status
		bne ki
		.fi

		lda lines
		clc
		sbc line
		tax
		lda lines+1
		sbc line+1
		bcc ki
		bne +
		txa
		beq ki
+
		jsr cursornext
		jmp loop
ki
		.if TARGET==APPLE2
oldsp		ldx #0
		txs
		.fi

		jsr close

		.if (TARGET!=ATARI800) && (TARGET!=APPLE2)
		lda status
		beq +
		lda #statusmsg.ioerr
		jsr setstatusmsg
+
		.fi

old1		ldx #0
old2		lda #0
		jmp toline
		.pend

mulrepeatl	.proc
		lda #0
		.cerror mulrepeat & 0
		.pend

mulrepeat	.proc
		stx num
		sta num+1
		ldx #0
		ldy #0

-		lsr num+1
		ror num
		bcc paros
		tya
		clc
		adc repeat
		tay
		txa
		adc repeat+1
		tax
		bcc paros
		ldx #255
		ldy #255
paros
		asl repeat
		rol repeat+1
		bne -
		lda repeat
		bne -
		sty repeat
		stx repeat+1
		rts
		.pend

		.include "motion.asm"
		.include "scroll.asm"
		.include "insert.asm"
		.include "cmdline.asm"
		.include "io.asm"
		.if GFX==1
		.include "displaygfx53.asm"
		.elsif GFX==2
		.include "displaygfx64.asm"
		.elsif (GFX==3) && (TARGET!=APPLE2)
		.include "displaygfx80.asm"
		.elsif GFX==4
		.include "displayvdc.asm"
		.else
		.include "displaytxt.asm"
		.fi
newline		.word registers.nl
		.word registers.nl
		.byte 0
prgend		= registers+registers.file

windows		.proc
line		= *			;cursor line
column		= *+2			;cursor column

line2		= *+3			;top line
lines		= *+5			;number of lines
column2		= *+7			;left column
start		= *+8
end		= *+9
curref		= *+10
		.logical 0
main		.fill 8
		.byte 0
		.byte height-1
		.byte references.file

status		.word 0
		.byte 0
		.word 0
		.word 1
		.byte 0
		.byte height-1
		.byte height
		.byte references.status
		.here
		.pend

registers	.proc
first		= *+0
last		= *+2
len		= *+4
lines		= *+5
linewise	= *+7
		.logical 0
nl		.word newline
		.word newline
		.byte 0
		.word 1
		.byte 1
file		.fill 8
unnamed		.fill 8
status		.fill 8
		.here
		.pend
registersend

marks		.proc
line		= *
column		= *+2
		.logical 0
		.fill 3*26		;a-z
start		.fill 3
end		.fill 3
		.here
		.pend
endmarks

references	.proc
next		= *+0
prev		= *+2
len		= *+4
reg		= *+5
		.logical 0
load		.fill 6
temp		.fill 6
start		.fill 6
end		.fill 6
insert		.fill 6
file		.fill 5
		.byte registers.file
status		.fill 5
		.byte registers.status
		.here
		.pend

filename	.fill width-2

		.if (TARGET!=C64) && (TARGET!=PLUGIN)
zpsave		.fill zpend-zpstart
		.fi
memory
