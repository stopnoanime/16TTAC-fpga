# vhdl files
FILES = $(filter-out src/package.vhdl, $(wildcard src/*.vhdl))
PACKAGE_FILE = src/package.vhdl

# testbench
TESTBENCHPATH = test/${TESTBENCHFILE}*
TESTBENCHFILE = ${TESTBENCH}_tb
WORKDIR = build

#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS  = --std=08 --workdir=$(WORKDIR)

STOP_TIME = 500ns
# Simulation break condition
GHDL_SIM_OPT = --assert-level=error
#GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

# WAVEFORM_VIEWER = flatpak run io.github.gtkwave.GTKWave
WAVEFORM_VIEWER = gtkwave

.PHONY: clean

all: clean make run view

make:
ifeq ($(strip $(TESTBENCH)),)
	@echo "TESTBENCH not set. Use TESTBENCH=<value> to set it."
	@exit 1
endif

	@mkdir -p $(WORKDIR)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(PACKAGE_FILE)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(FILES)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(TESTBENCHPATH)
	@$(GHDL_CMD) -e $(GHDL_FLAGS) $(TESTBENCHFILE)

run:
	@$(GHDL_CMD) -r $(GHDL_FLAGS) --workdir=$(WORKDIR) $(TESTBENCHFILE) --vcd=$(TESTBENCHFILE).vcd $(GHDL_SIM_OPT)
	@mv $(TESTBENCHFILE).vcd $(WORKDIR)/

view:
	@$(WAVEFORM_VIEWER) --dump=$(WORKDIR)/$(TESTBENCHFILE).vcd

clean:
	@rm -rf $(WORKDIR)
	@rm -rf *.area *.db *.exe *.vcd *.o *.log *.bit