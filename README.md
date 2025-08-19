# SPI UVM
1. This is a miniproject for SPI UVM, culminated from a four-week bootcamp from 21 July, 2025 to 19 August, 2025.
2. This repository serves as a simple and minimal Universal Verification Methodology (UVM) testbench for verifying a basic Serial Peripheral Interface (SPI) design.

## Table of Contents
1. Objectives
2. Navigation
3. Methodology
4. Test Plan
5. Limitation
6. Tool Version

## Objectives
This "Hello World" UVM testbench demonstrates the core components of a UVM environment—such as sequences, drivers, monitors, agents, scoreboards and coverage — applied to a simple SPI Master. The goal is to provide a clean and educational reference for:
1. Getting started with UVM
2. Understanding how to build a UVM testbench for a common protocol
3. Learning how to simulate and debug SPI transactions

## Navigation
```
1. $ROOT
    |_    design/           // Directory that keeps spi design files
    |_    sim/              // Directory for running simulation, it contains makefile for running vcs flow(s)
	|_	  doc/				// Directory storing the test plan and a ppt slide.
	|_ 	  material/			// Directory containing the compressed files for the raw training materials.
    |_    spi.setup         // Setup file that needs to be sourced at the very beginning, setting the environment related to this spi
    |_    README.txt        // This file

2. % cd spi
3. % source spi.setup          // Change $ROOT to your local area

4. % cd sim
5. % make <sim_flow>

// To perform the default vcs 2-step flow, use the following make command: % make dv

// To perform the default vcs 3-step flow, use the following make command:
% export STEP=3
% make dv

```

## Methodology
### UVM Framework
Figure below show the TB environment with a dummy SPI slave communicating with the SPI Master (DUT). In the environment, we utilise two agents: 
1. driver (active) agent;
2. consumer (passive) agent;

where the driver agent is responsible to drive the set of sequences to the DUT via the driver and monitor the DUT input signals; whereas the consumer agent passively monitor the DUT output signals. Both agents will pass the monitored transactions to the scoreboard and coverage board.

### Transaction Packet Definition
The transaction packet is defined in Figure ??


### UVM Scoreboard <-> Monitor Communication



## Test Plan
### Summary

### Test Sequence


## Version
1. VCS: Compiler version W-2024.09-SP2_Full64
2. UVM: uvm-ieee-2020-2.0
