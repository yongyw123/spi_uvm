# SPI UVM
1. This is a miniproject for SPI UVM, culminated from a one-week bootcamp.

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

## Version
1. VCS: Compiler version W-2024.09-SP2_Full64
2. UVM: uvm-ieee-2020-2.0
