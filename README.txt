TELECOMMUNICATION ENGINEERING LAB — MATLAB SIMULATIONS
======================================================

Included standalone MATLAB scripts
----------------------------------
1. pcm_simulation.m
   Sampling, uniform quantization, binary encoding, and reconstruction.

2. dsss_simulation.m
   Baseband BPSK DSSS spreading/despreading with AWGN and a narrowband
   interference component.

3. fhss_simulation.m
   Frequency-hopping BPSK waveform with a shared hopping pattern, AWGN,
   and synchronized per-hop correlation detection.

4. convolutional_code_simulation.m
   Rate-1/2 convolutional encoder (K=3, generators 111 and 101), random
   bit-flip channel, and a hard-decision Viterbi decoder.

How to run
----------
1. Extract the ZIP file.
2. Open MATLAB.
3. Set MATLAB's Current Folder to the extracted folder.
4. Open one .m file and click Run, or type the script name in the Command
   Window (without .m), e.g.:
       pcm_simulation
       dsss_simulation
       fhss_simulation
       convolutional_code_simulation

Requirements
------------
These scripts are written to use core MATLAB functions and do not require
Communications Toolbox or Signal Processing Toolbox. Local functions are
not required by these scripts. They are intended as teaching simulations,
not standards-compliant radio implementations.

Notes
-----
- All parameter values are illustrative and can be edited near the top of
  each script.
- DSSS is modeled at baseband using bipolar chips.
- FHSS uses one data bit per hop and a known hop sequence to keep the
  demonstration easy to follow.
- The convolutional-code script appends two zero tail bits and uses hard
  decisions. The random channel can occasionally produce decoding errors.
- In a real lab, use your instructor's generator polynomials, sampling
  rates, code lengths, and experiment procedure when they differ.
