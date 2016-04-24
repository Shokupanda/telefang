.PHONY: all compare clean

.SUFFIXES:
.SUFFIXES: .asm .o .gbc .png
.SECONDEXPANSION:

# Build Telefang.
ROMS := telefang.gbc
BASEROM := baserom.gbc
OBJS := main.o wram.o components/compression/malias.o \
	  components/lcdc/vblank_irq.o components/lcdc/hblank_irq.o \
	  components/lcdc/oam_dma.o components/lcdc/shadow_regs.o \
	  components/system/main.o components/system/state_machine.o \
	  components/system/rst.o components/mainscript/state_machine.o

# If your default python is 3, you may want to change this to python27.
PYTHON := python
PRET := pokemon-reverse-engineering-tools/pokemontools

$(foreach obj, $(OBJS), \
	$(eval $(obj:.o=)_dep := $(shell $(PYTHON) $(PRET)/scan_includes.py $(obj:.o=.asm))) \
)

# Link objects together to build a rom.
all: $(ROMS) compare

# Assemble source files into objects.
# Use rgbasm -h to use halts without nops.
$(OBJS): $$*.asm $$($$*_dep)
	@$(PYTHON) $(PRET)/gfx.py 2bpp $(2bppq)
	@$(PYTHON) $(PRET)/gfx.py 1bpp $(1bppq)
	@$(PYTHON) $(PRET)/pcm.py pcm $(pcmq)
	rgbasm -h -o $@ $<

$(ROMS): $(OBJS)
	rgblink -n $(ROMS:.gbc=.sym) -m $(ROMS:.gbc=.map) -O $(BASEROM) -o $@ $^
	rgbfix -v -c -i BXTJ -k 2N -l 0x33 -m 0x10 -p 0 -r 3 -t "TELEFANG PW" $@

# The compare target is a shortcut to check that the build matches the original roms exactly.
# This is for contributors to make sure a change didn't affect the contents of the rom.
# More thorough comparison can be made by diffing the output of hexdump -C against both roms.
compare: $(ROMS) $(BASEROM)
	cmp $^

# Remove files generated by the build process.
clean:
	rm -f $(ROMS) $(OBJS) $(ROMS:.gbc=.sym)
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.pcm' \) -exec rm {} +

%.2bpp: %.png
	$(eval 2bppq += $<)
	@rm -f $@

%.1bpp: %.png
	$(eval 1bppq += $<)
	@rm -f $@

%.pcm: %.wav
	$(eval pcmq += $<)
	@rm -f $@

