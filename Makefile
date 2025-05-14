# ==============================================================================
# File originally created by Claude Garrett V.
# Modified by Richard Groves.
# ==============================================================================


# ##############################################################
# Defaults:

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Directories:
BUILD_DIR   ?= build
DOCS_DIR    ?= docs
SCRIPTS_DIR ?= scripts
SOURCE_DIR  ?= source
TEST_DIR    ?= test

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Project Settings:
PROJECT_NAME     ?= uart_16550
CAP_PROJECT_NAME ?= UART_16550
BOARD            ?= NEXYSA7
TOP              ?= $(PROJECT_NAME)
TEST_TOP         ?= $(PROJECT_NAME)_tb
PROJECT_FILE     ?= $(BUILD_DIR)/$(PROJECT_NAME)/$(PROJECT_NAME).xpr

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Common Settings:
VIVADO_VERSION  := $(shell ls ~/.Xilinx/Vivado | grep -E '^[0-9]+\.[0-9]+' | sort -V | uniq -w 5 | tail -n 1)
BOARD_PART_REPO_PATH ?= ~/.Xilinx/Vivado/$(VIVADO_VERSION)/xhub/board_store/xilinx_board_store
IP_PATHS             ?= \
	none

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sources:

# --------------------------------------------------------------
# Synthesis Only:

SYNTH_SOURCES ?= \
	none

# --------------------------------------------------------------
# Synthesis and Simulation:

SOURCES ?= \
	$(SOURCE_DIR)/shift_mult.sv \
	$(SOURCE_DIR)/baud_gen.sv \
	$(SOURCE_DIR)/uart_tx.sv \
	$(SOURCE_DIR)/uart_rx.sv \
	$(SOURCE_DIR)/fifo_lite.sv \
	$(SOURCE_DIR)/uart_top.sv \
	$(SOURCE_DIR)/uart_16550_regs_pkg.sv \
	$(SOURCE_DIR)/axi4_lite_pkg.sv \
	$(SOURCE_DIR)/axi_ui.sv

# --------------------------------------------------------------
# Simulation Only:

TEST_SOURCES ?= \
	$(TEST_DIR)/shift_mult_tb.sv \
	$(TEST_DIR)/baud_gen_tb.sv \
	$(TEST_DIR)/uart_tx_tb.sv \
	$(TEST_DIR)/uart_rx_tb.sv \
	$(TEST_DIR)/uart_loopback_tb.sv \
	$(TEST_DIR)/fifo_lite_tb.sv \
	$(TEST_DIR)/uart_top_tb.sv \
	$(TEST_DIR)/uart_16550_regs_tb.sv \
	$(TEST_DIR)/axi_ui_tb.sv

# --------------------------------------------------------------
# Block Designs:

BLOCK_DESIGNS ?= \
	none

# --------------------------------------------------------------
# Waveforms:

WAVES ?= \
	$(SCRIPTS_DIR)/shift_mult_tb_waves.wcfg \
	$(SCRIPTS_DIR)/baud_gen_tb_waves.wcfg \
	$(SCRIPTS_DIR)/uart_tx_tb_waves.wcfg \
	$(SCRIPTS_DIR)/uart_rx_tb_waves.wcfg \
	$(SCRIPTS_DIR)/uart_loopback_tb_waves.wcfg \
	$(SCRIPTS_DIR)/fifo_lite_tb_waves.wcfg \
	$(SCRIPTS_DIR)/uart_top_tb_waves.wcfg \
	$(SCRIPTS_DIR)/axi_ui_tb_waves.wcfg

# ##############################################################
# Board Selection:

# Nexys A7-100T
ifeq ($(BOARD),NEXYSA7)
CONSTRAINTS ?= ../$(SCRIPTS_DIR)/Nexys_A7_100T_Constraints.xdc
BOARD_PART  ?= digilentinc.com:nexys-a7-100t:part0:1.2
BOARD_ID    ?= nexys-a7-100t
FPGA_PART   ?= xc7a100tcsg324-1
endif

# ##############################################################
# Targets:

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# help:

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo
	@echo "Targets:"
	@echo "  help         : Display this help menu."
	@echo "  docs         : Build all documentation."
	@echo "  docs-verbose : Build all documentation with verbose messages."
	@echo "  project      : Create the Vivado project for this lab."
	@echo "  open         : Open the Vivado project for this lab."
	@echo "  clean-docs   : Remove all temporary documentation artifacts."
	@echo "  clean-vivado : Remove all temporary Vivado artifacts."
	@echo "  clean-all    : Remove all artifacts."
	@echo "  clean        : Remove all temporary artifacts."

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# project:

.PHONY: project
project: $(PROJECT_FILE)
$(PROJECT_FILE):
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) \
		&& vivado -mode tcl -source ../$(SCRIPTS_DIR)/project.tcl \
			-tclargs \
				-project_name          $(PROJECT_NAME) \
				-origin_dir            . \
				-synth_source_list    "$(addprefix ../,$(SYNTH_SOURCES))" \
				-source_list          "$(addprefix ../,$(SOURCES))" \
				-sim_source_list      "$(addprefix ../,$(TEST_SOURCES)) $(addprefix ../,$(WAVES))" \
				-block_designs        "$(BLOCK_DESIGNS)" \
				-constraints           $(CONSTRAINTS) \
				-ip_paths             "$(IP_PATHS)" \
				-top                   $(TOP) \
				-sim_top               $(TEST_TOP) \
				-board_part_repo_path  $(BOARD_PART_REPO_PATH) \
				-board_part            $(BOARD_PART) \
				-board_id              $(BOARD_ID) \
				-part                  $(FPGA_PART)

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# docs:

.PHONY: docs
docs:
	cd $(DOCS_DIR) \
		&& latexmk -f -quiet -pdf -shell-escape *.tex \
		&& latexmk -f -quiet -c \
		&& rm -f *.nav *.snm *.vrb

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# verbose-docs:

.PHONY: docs-verbose
docs-verbose:
	cd $(DOCS_DIR) \
		&& latexmk -f -pdf -shell-escape *.tex \
		&& latexmk -f -quiet -c \
		&& rm -f *.nav *.snm *.vrb

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# clean-docs:

.PHONY: clean-docs
clean-docs:
	cd $(DOCS_DIR) \
		&& latexmk -f -quiet -C \
		&& rm -rf *.nav *.snm *.vrb _minted*
		
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# open:

.PHONY: open
open: $(PROJECT_FILE)
	LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1 vivado $(PROJECT_FILE) &

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# clean-vivado:

.PHONY: clean-vivado
clean-vivado:
	rm -rf *.jou *.log *.str .Xil
	rm -rf $(BUILD_DIR)

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# clean-all

.PHONY: clean-all
clean-all: clean-docs clean-vivado

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# clean:

.PHONY: clean
clean: clean-vivado
