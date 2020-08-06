# Hydrophone calibration routine

This script was created to automate steps the process of hydrophone calibration procedure. Recordings were made (as close as practically possible with the resources available) according to standard IEC 6065. A set of input signals were generated and emmited through an underwater Brüel & Kjaer projector covering the frecuiency range of interest (5-200 kHz) through 19 frequency steps.

The basic measuring methodology consisted on the reference method, using a projector and a known calibrated hydrophone as a reference. Recordings were made in a 4x6x10 m pool, locating the transducers as close to the middle of the pool as possible to avoid wall reflections from interfeering. Transducer positions were calculated acording to the mentioned standard, and by using **echoFreeTimePlot.m** function to look for best combination.

Each input signal consisted on 12 pulses of an aproximate duration of 50 ms separated by variable times of silence while we waited for the reverberations to cease.

