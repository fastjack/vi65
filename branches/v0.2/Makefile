
TASS=~/work/tass64/trunk/64tass

a: a.asm insert.asm cmdline.asm motion.asm scroll.asm displaytxt.asm displaygfx64.asm displaygfx80.asm displayvdc.asm displaygfx53.asm io.asm Makefile doc.txt \
        petscii6x8.fnt atascii6x8.fnt a2ascii6x8.fnt \
	petscii5x8.fnt atascii5x8.fnt a2ascii5x8.fnt \
	petscii4x8.fnt atascii4x8.fnt
	#$(TASS) -b -B -C a.asm -o a -La.dasm -DTARGET=800 -DGFX=1
	$(TASS) -a -b -B -C a.asm -o a -La.dasm -DTARGET=64 -DGFX=2
	x64 a
	#atari800.x11 a
	#$(TASS) -b -B -C a.asm -o a -La.dasm -DTARGET=2 -DGFX=3
	#cat b.dsk >a.dsk
	#./dos33 a.dsk DELETE A
	#./dos33 a.dsk SAVE B A
	#./dos33 a.dsk SAVE T doc.atx
	xset r rate 250 30
	
doc.html doc.txt doc.seq doc.atx DOC.TXT: a.asm motion.asm scroll.asm insert.asm cmdline.asm
	grep -h "^;h;" $^ |sed -e "s/^;.; *//" >doc.html
	grep -h "^;m;" $^ |sed -e "s/^;.; *//" >>doc.html
	grep -h "^;n;" $^ |sed -e "s/^;.; *//" >>doc.html
	grep -h "^;t;" $^ |sed -e "s/^;.; *//" >>doc.html
	cat doc.html |w3m -dump -cols 64 -T text/html >doc.txt
	cat doc.txt |tr "\n" "›" >DOC.TXT
	cat doc.txt |tr "\n[:lower:]ABCDEFGHIJKLMNOPQRSTUVWXYZ{}" "\r[:upper:]ÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚ[]" >doc.seq
	cat doc.txt |tr "\n -~" " ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþ" >doc.atx

all: a.asm insert.asm cmdline.asm motion.asm scroll.asm displaytxt.asm displaygfx64.asm displaygfx80.asm displayvdc.asm displaygfx53.asm io.asm doc.txt \
	petscii6x8.fnt atascii6x8.fnt a2ascii6x8.fnt \
	petscii5x8.fnt atascii5x8.fnt a2ascii5x8.fnt \
	petscii4x8.fnt atascii4x8.fnt
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c64_40 -DTARGET=64 -DGFX=0 && exomizer -s sys -n bin/vi65_c64_40 -o bin/vi65_c64_40 && addcopyr bin/vi65_c64_40
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c64_53 -DTARGET=64 -DGFX=1 && exomizer -s sys -n bin/vi65_c64_53 -o bin/vi65_c64_53 && addcopyr bin/vi65_c64_53
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c64_64 -DTARGET=64 -DGFX=2 && exomizer -s sys -n bin/vi65_c64_64 -o bin/vi65_c64_64 && addcopyr bin/vi65_c64_64
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c64_80 -DTARGET=64 -DGFX=3 && exomizer -s sys -n bin/vi65_c64_80 -o bin/vi65_c64_80 && addcopyr bin/vi65_c64_80
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c64_vdc -DTARGET=64 -DGFX=4 && exomizer -s sys -n bin/vi65_c64_vdc -o bin/vi65_c64_vdc && addcopyr bin/vi65_c64_vdc
	$(TASS) -b -a -B -C a.asm -o bin/vi65_plugin_40 -DTARGET=65 -DGFX=0
	$(TASS) -b -a -B -C a.asm -o bin/vi65_plugin_53 -DTARGET=65 -DGFX=1
	$(TASS) -b -a -B -C a.asm -o bin/vi65_plugin_64 -DTARGET=65 -DGFX=2
	$(TASS) -b -a -B -C a.asm -o bin/vi65_plugin_80 -DTARGET=65 -DGFX=3
	$(TASS) -b -a -B -C a.asm -o bin/vi65_plugin_vdc -DTARGET=65 -DGFX=4
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c128_40 -DTARGET=128 -DGFX=0 && exomizer2 sfx sys -t128 -n bin/vi65_c128_40 -o bin/vi65_c128_40
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c128_53 -DTARGET=128 -DGFX=1 && exomizer2 sfx sys -t128 -n bin/vi65_c128_53 -o bin/vi65_c128_53
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c128_64 -DTARGET=128 -DGFX=2 && exomizer2 sfx sys -t128 -n bin/vi65_c128_64 -o bin/vi65_c128_64
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c128_80 -DTARGET=128 -DGFX=3 && exomizer2 sfx sys -t128 -n bin/vi65_c128_80 -o bin/vi65_c128_80
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c128_vdc -DTARGET=128 -DGFX=4 && exomizer2 sfx sys -t128 -n bin/vi65_c128_vdc -o bin/vi65_c128_vdc
	$(TASS) -b -a -B -C a.asm -o bin/vi65_vic20_22 -DTARGET=21 -DGFX=0
	$(TASS) -b -a -B -C a.asm -o bin/vi65_vic20_26 -DTARGET=21 -DGFX=1
	$(TASS) -b -a -B -C a.asm -o bin/vi65_vic20_32 -DTARGET=21 -DGFX=2
	$(TASS) -b -a -B -C a.asm -o bin/vi65_vic20_40 -DTARGET=21 -DGFX=3
	$(TASS) -b -a -B -C a.asm -o bin/vi65_c16_40 -DTARGET=16 -DGFX=0 && exomizer -4 -s sys -n bin/vi65_c16_40 -o bin/vi65_c16_40
	$(TASS) -b -a -B -C a.asm -o bin/vi65_plus4_40 -DTARGET=4 -DGFX=0 && exomizer -4 -s sys -n bin/vi65_plus4_40 -o bin/vi65_plus4_40
	$(TASS) -b -a -B -C a.asm -o bin/vi65_plus4_53 -DTARGET=4 -DGFX=1 && exomizer -4 -s sys -n bin/vi65_plus4_53 -o bin/vi65_plus4_53
	$(TASS) -b -a -B -C a.asm -o bin/vi65_plus4_64 -DTARGET=4 -DGFX=2 && exomizer -4 -s sys -n bin/vi65_plus4_64 -o bin/vi65_plus4_64
	$(TASS) -b -a -B -C a.asm -o bin/vi65_plus4_80 -DTARGET=4 -DGFX=3 && exomizer -4 -s sys -n bin/vi65_plus4_80 -o bin/vi65_plus4_80
	$(TASS) -b -a -B -C a.asm -o bin/vi65_pet_80 -DTARGET=8 -DGFX=0
	$(TASS) -b -a -B -C a.asm -o bin/vi65_pet_40 -DTARGET=7 -DGFX=0
	$(TASS) -b -B -C a.asm -o bin/vi65_atari800_40 -DTARGET=800 -DGFX=0
	$(TASS) -b -B -C a.asm -o bin/vi65_atari800_53 -DTARGET=800 -DGFX=1
	$(TASS) -b -B -C a.asm -o bin/vi65_atari800_64 -DTARGET=800 -DGFX=2
	$(TASS) -b -B -C a.asm -o bin/vi65_atari800_80 -DTARGET=800 -DGFX=3
	cp doc.txt doc.seq doc.atx bin/
	cp DOC.TXT bin/doc.ata

petscii6x8.fnt: font6x8.fnt createfont
	./createfont 6x8 petscii

atascii6x8.fnt: font6x8.fnt createfont
	./createfont 6x8 atascii

a2ascii6x8.fnt: font6x8.fnt createfont
	./createfont 6x8 a2ascii

petscii5x8.fnt: font5x8.fnt createfont
	./createfont 5x8 petscii

atascii5x8.fnt: font5x8.fnt createfont
	./createfont 5x8 atascii

a2ascii5x8.fnt: font5x8.fnt createfont
	./createfont 5x8 a2ascii

petscii4x8.fnt: font4x8.fnt createfont
	./createfont 4x8 petscii

atascii4x8.fnt: font4x8.fnt createfont
	./createfont 4x8 atascii

a2ascii4x8.fnt: font4x8.fnt createfont
	./createfont 4x8 a2ascii

.PHONY: clean

clean:
	rm -f petscii6x8.fnt atascii6x8.fnt a2ascii6x8.fnt \
	petscii5x8.fnt atascii5x8.fnt a2ascii5x8.fnt \
	petscii4x8.fnt atascii4x8.fnt a.dasm doc.html doc.txt \
	doc.seq doc.atx DOC.TXT a a.dsk
