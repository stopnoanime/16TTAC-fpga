# vhdl files
PACKAGE_FILE = src/package.vhdl
TOP_FILE = src/top.vhdl
FILES = $(filter-out $(PACKAGE_FILE) $(TOP_FILE), $(wildcard src/*.vhdl))

# testbench
TESTBENCHPATH = test/${TESTBENCHFILE}*
TESTBENCHFILE = ${TESTBENCH}_tb
WORKDIR = build

#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS  = --std=08 --workdir=$(WORKDIR)

STOP_TIME = 500ns
# Simulation break condition
GHDL_SIM_OPT = --assert-level=error --max-stack-alloc=0
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
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(TOP_FILE)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(TESTBENCHPATH)
	@$(GHDL_CMD) -e $(GHDL_FLAGS) $(TESTBENCHFILE)

run:
	@$(GHDL_CMD) -r $(GHDL_FLAGS) --workdir=$(WORKDIR) $(TESTBENCHFILE) --wave=$(TESTBENCHFILE).ghw $(GHDL_SIM_OPT)
	@mv $(TESTBENCHFILE).ghw $(WORKDIR)/

view:
	@$(WAVEFORM_VIEWER) --dump=$(WORKDIR)/$(TESTBENCHFILE).ghw

clean:
	@rm -rf $(WORKDIR)
	@rm -rf *.area *.db *.exe *.vcd *.ghw *.o *.log *.bit