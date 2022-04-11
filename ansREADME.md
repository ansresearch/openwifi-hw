<img src="./images/ans-logo-4x.png" width="250"> &nbsp; &nbsp; &nbsp; <img src="./images/unibs-logo-4x.png" width="400">

# About CSIobfuscation branch

Developed by the [ANS Research Group](https://ans.unibs.it) at the [University of Brescia](https://www.unibs.it/en), Italy

## Short description

We call *obfuscation* the act of hiding non-communication-related
information, distinguishing it from the more common *jamming*,
whose goal is simply destroying the entire communication
capability of the system.

We implemented a CSI fuzzer so to obfuscate those properties of the CSI
that an advanced attacker could use, without authorization, to localize a user in an indoor environment.

In [this fork](https://github.com/ansresearch/openwifi-hw/tree/CSIobfuscation) of the [openwifi-hw project](https://github.com/open-sdr/openwifi-hw) we implemented the FPGA's side of our CSI fuzzer.

## Main modifications compared to the original project

The introduced modifications focus on the Transmission Chain in the FPGA and are the following:

- Introduction of new registers to store obfuscation coefficients generated per-packet by the driver
- Generation of obfuscated 802.11ag Preambles in the Frequency domain
- Distortion of all symbols of a frame according to available obfuscation coefficients
