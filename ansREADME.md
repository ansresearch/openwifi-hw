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

## Build FPGA with obfuscation

As all our modification focus on the Transmission side, our contributions are implemented as modifications
to the *openofdm_tx* IP core which is part of the main FPGA design of openwifi. 

The user must therefore keep following the original [openwifi-hw BUILD guide](https://github.com/open-sdr/openwifi-hw#Build-FPGA)
just taking care of updating the *openofdm_tx* component before the generation of the final openwifi bitstream.

The instructions on [how to update an IP core](https://github.com/open-sdr/openwifi-hw#modify-ip-cores)
are available on the main GitHub project and here we report only the steps necessary to
update the *openofdm_tx* IP core to include our modifications:

* Open Vivado, then in Vivado Tcl Console:

```console        
cd ip/openofdm_tx
source ./ans_openofdm.tcl
```

* In Vivado:
```
Tools --> Create and Package New IP --> Next --> "Package your current project" --> Next
--> set "openwifi-hw/ip_repo/common/openofdm_tx" as IP Location (this way the main openwifi FPGA project will find
our modified version of openofdm_tx available) --> OK --> (Overwrite Existing IP definition if requested) --> Finish

In new opened temporary project: Review and Package --> Package IP --> Yes
```

At this stage, the user can go back to the [openwifi-hw BUILD guide](https://github.com/open-sdr/openwifi-hw#Build-FPGA) and resume the guide from this particular step:

* In Vivado:
```
source ./openwifi.tcl
Open Block Design
Tools --> Report --> Report IP Status
Generate Bitstream
(Will take a while)
File --> Export --> Export Hardware... --> Include bitstream --> OK
File --> Launch SDK --> OK, then close SDK
```


