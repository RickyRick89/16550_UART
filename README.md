# 16550 Compatible AXI4-Lite UART Controller

## Overview

This project implements a 16550-compatible UART core with AXI4-Lite interface support. The design includes:
- 16-byte transmit and receive FIFOs
- Programmable baud rate
- Full register compatibility with the 16550 UART standard
- AXI4-Lite accessible memory-mapped registers
- Interrupt output for TX/RX/line status events
- Portable C driver for bare-metal environments

## Included Features

- 16550 UART register set:
  - THR, RHR, DLL, DLM, LCR, IER, IIR, LSR, MCR, FCR, SPR
- 16-byte FIFOs (TX and RX)
- Programmable baud rate via divisor latch
- Interrupt enable and identification
- AXI4-Lite interface for SoC integration
- Minimal C driver with init, read, write, and IRQ handler

## Omitted Features
- Modem control
- DMA
- general-purpose outputs

## Directory Structure

├── source/ # Verilog RTL files
├── test/ # Testbenches
├── scripts/ # Waveforms, Contraints and TCL files
├── driver/ # C BSP driver files
├── docs/ # Datasheets, specs, block diagrams
├── README.md # This file