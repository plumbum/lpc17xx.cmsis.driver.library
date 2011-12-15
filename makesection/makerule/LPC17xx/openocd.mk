OPENOCD=openocd
OPENOCD_DIR=$(PROJ_ROOT)/makesection/makerule/LPC17xx

OPENOCD_IFACE+=-f interface/jlink.cfg -f target/lpc1768.cfg


OPENOCD_LOADFILE+=$(EXECNAME).elf
# debug level
OPENOCD_CMD=-d0
# interface and board/target settings (using the OOCD target-library here)
OPENOCD_CMD+=$(OPENOCD_IFACE)
# initialize
OPENOCD_CMD+=-c init
# show the targets
OPENOCD_CMD+=-c targets

OPENOCD_CMD+= -c "reset_config trst_and_srst separate"
# commands to prepare flash-write
OPENOCD_CMD+= -c "reset halt"

OPENOCD_CMD+= -c "jtag_nsrst_delay 200"
OPENOCD_CMD+= -c "jtag_ntrst_delay 200"
OPENOCD_CMD+= -c "jtag_khz 100"

# flash unprotect & erase
#OPENOCD_CMD+=-c "flash protect 0 0 29 off"
#OPENOCD_CMD+=-c "flash erase_sector 0 0 29"

# flash-write
OPENOCD_CMD+=-c "flash write_image erase unlock $(OPENOCD_LOADFILE)"
# Verify
#OPENOCD_CMD+=-c "verify_image $(OPENOCD_LOADFILE)"
# reset target
OPENOCD_CMD+=-c "reset run"
# terminate OOCD after programming
OPENOCD_CMD+=-c shutdown

openocd:
	$(OPENOCD) $(OPENOCD_IFACE)

load: $(OPENOCD_LOADFILE)
	$(GDB) -x $(OPENOCD_DIR)/fw_load.gdb $<

debug: $(OPENOCD_LOADFILE)
	$(GDB) -x $(OPENOCD_DIR)/fw_debug.gdb $<

prog program: $(OPENOCD_LOADFILE)
	@echo "Programming with OPENOCD"
	$(OPENOCD) $(OPENOCD_CMD)

PHONY: openocd load debug tags prog program

tags: 
	ctags -R --c++-kinds=+p --fields=+iaS --extra=+q . 

