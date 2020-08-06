# Hydrophone calibration routine

This script was created to automate steps the process of hydrophone calibration procedure. Recordings were made (as close as practically possible with the resources available) according to standard IEC 6065. A set of input sinusoidal signals were generated and emmited through an underwater Brüel & Kjaer projector covering the frecuiency range of interest (5-200 kHz) in 19 frequency steps.

The basic measuring methodology consisted on the reference method, using a projector and a known calibrated hydrophone as a reference. Recordings were made in a 4x6x10 m pool, locating the transducers as close to the middle of the pool as possible to avoid wall reflections from interfeering. Transducer positions were calculated acording to the mentioned standard, and by using **echoFreeTimePlot.m** function to look for best combination.

Each input signal consisted on 12 pulses of an aproximate duration of 50 ms separated by variable times of silence while we waited for the reverberations to cease. Beginning and ending of each pulse was computed through a SNR threshold set through visual inspection.

![Pulses](/example-40khz-pulses.jpg)

From each of the separate pulses at least 7 cycles of the waveform are further extraxted for analysis. A time offset was established for the extraction of the cycles in order to avoid initial peak crated by the signal generator.

![Cycles](/example-cycles-extraction.jpg)

RMS values are calculated for each signal fragment and averagaed over the 12 pulses. Output voltage values are caclulated according to ADC volts-to-counts conversion rate and compared to the reference hydrophone. Hydrophone sensityvity and transfer functions are stored. 

![Sensitivity](/example-output-sensitivity.jpg)
