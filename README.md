# Play with the Mitsubishi M64283FP sensor
A set of codes to address the Mitsubishi M64283FP artificial retina with Arduino. These codes are compatible with the M64282FP sensor of the Game Boy Camera as well.

## Some history
Mitsubishi created a series of CMOS sensors called “artificial retina”, with the aim of becoming inexpensive, easy-to-program consumer products. The first traces of these sensors in literature date back to 1994, but their commercial boom really began in 1998 with the launch of the Game Boy Camera and the first mass-produced sensor, the M64282FP. The trace of these sensors is then lost in more or less mass-market products, and they have certainly equipped cell phones, consumer multimedia products, fingerprint readers and security cameras, but the reference of the sensors used is lost to this day. It is almost certain that the M64283FP sensor equipped the “LaPochee” module accompanying the [the THZ43 Chiaro cell phone by Mitsubishi](https://time-space.kddi.com/ketaizukan/1999/10.html) and the [PCPICO](https://web.archive.org/web/20020925132513/http://pcpico.com/), a kind of multimedia interface in which the role of the sensor is not clear at all.

The originality (and shortcoming) of these sensors is that they produce an analog output from digital registers that are “relatively” simple to apply and allow real-time image processing with conventional transformations (edge detection, inversion, gain change, etc.). This analog output then has to be converted into a digital signal, byte by byte, to be processeds further, which represents a major bottleneck in terms of data flow rate. The Game Boy Camera deals with this shortcoming by incorporating a very fast analog-to-digital converter in its mapper but is capped to about 12 fps nevertheless.

To overcome this shortcoming, the sensors in the analog series evolved towards random tile addressing and projection to reduce the flow rate of data to convert (M64283FP) and lower definition (M64285FP with 32x32 pixels matrix), but eventually disappeared in favor of faster, fully digital sensors. It is totally unknown now which sensor equipped with apparatus and what the production volume was, except for the Game Boy Camera.

Mitsubishi sensor division was finally incorporated into Renesas in 2003 and the artificial retinas eventually faded into total obscurity. The M642XX sensor series is notorious for the rushed translation of their datasheets which were probably never though to be distributed outside Japan. Hopefully, the M64283FP original datasheet in Japanese is available and the translated version is at least barely understandable.

The M64283FP was probably available for world retail at a certain point as it had a quite successful carreer in labs to tinker augmented vision systems, both in Japanese laboratory and in the West. 

This sensor appears sporadically on Japanese online auction sites for random prices and some Chinese chip dealers claim to have them, but I've never managed to bargain one for less than 60€ (which is a no go for me). I obtained two copies of the M64283FP in the summer 2023 from a generous donor who knew someone who knows someone at Mitsubishi, knowing that these sensors will have a good second home with me.

## Register setting

Understanding the registers system for the first time is not trivial, knowing the sketchy documentation available. Despite everything, through trial and error, datalogging and a bit of educated guess (plus a lot of time), I think I overall understand how to drive them now.

**Register mapping according to the English Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_address_2.png)

The English datasheet gives the whole list of registers. Most of them have no practical use or must be kept at default value, so stay relaxed and focused. TADD is a pin only used to push registers at address ranges not available with the M64282FP sensor (the pin is not connected). It must be always HIGH, except for last two addresses.

**Address 000, TADD HIGH**
**- Register Z1-Z0:** used to set the output voltage of the sensor (VOUT) so that it matches Vref given by register V in dark conditions (other said, it gives the lowest reference voltage). In total darkness, VOUT however shifts a bit with exposure time compared to Vref and can be corrected by activating an auto-calibration circuit (see next). Default values recommended: Z1 = 1 and Z0 = 0.
**- Register O5-O0:** plus or minus voltage (in small increments, 32 steps of 32 mV) added to register Vref given by register V. MSB gives the polarity of the applied voltage.

_**The registers at this address have exactly the same effect with the M64282FP sensor.**_


**Address 001, TADD HIGH**
**- Registers N, VH:** enable image enhancement (N) and choose which convolution kernel to apply among 4 pre-calculated ones (VH0, VH1). Convolution kernels can also be forced via P, M and X registers if you like pain. The formula to force custom kernels is not trivial at all.
**- Registers G:** output gain, see tables in datasheet.

_**The registers at this address have exactly the same effect with the M64282FP sensor.**_


**Address 010 and 011, TADD HIGH**
**- Register C:** Exposure time in 65535 increments of 16 µs. Maximal exposure is 1048 ms if clock is set to 500 Mhz. Downclocking is possible to increase exposure time but overcloking gives image with intense artifacts (top of the image becomes black). Without image enhancement, 0x0010 is the minimal exposure recommended. With image enhancement, 0x0020 is the minimal exposure recommended (0x0030 for the M64283FP). Using values below these creates images with very strong artifacts.

_**The registers at this address have exactly the same effect with the M64282FP sensor.**_


**Address 100, TADD HIGH**
**- Registers SH, AZ** totally confusing role in the English datasheet, not even mentioned in the Japanese datasheet. I guess these are not critical so. Recommended default values: SH = 0, AZ = 0.
**- Register CL:** Enables the auto-calibration circuit and cancels the voltage shift of VOUT with exposure time. Is used in conjonction with OB that outputs a line of dark pixels for reference at the very top of the image. 0 is active.
**- Registers P3-P0** custom convolution kernels. 0x0001 by default.

_**The registers P3-P0 at this address have exactly the same effect with the M64282FP sensor. SH and AZ does not exist in the M64282FP sensor.**_


**Address 101, TADD HIGH**
**- Registers PX, PY:** projection mode when active (vertical, horizontal, none). Recommended values: PX = 0, PY = 0 (no projection).
**- Register MV4:** plus or minus bias for projection mode.
**- Register OB:** Enable to output optical black level (electrical signal of physically masked pixels) as a dark pixel line at the top of the image. Is used in conjonction with CL. 0 is active.
**- Register M3-M0:** custom convolution kernels. 0x0000 by default.

_**These registers differ notably from M64282FP sensor.**_



**Address 110, TADD HIGH**
**- Register MV3-MV0:** voltage bias for the projection mode, 16 steps of 8 mV.
**- Register X3-X0:** custom convolution kernels. 0x0001 by default.

_**These registers differ notably from M64282FP sensor.**_


**Address 111, TADD HIGH**
**- Register E3-E0:** intensity of edge enhancement, from 0% to 87.5%. **With the same registers, the M64282FP sensor goes from 50% to 500%. Only way to remove this effect is so to use register N**
**- Register I:** outputs the image in negative.
**- Registers V2-V0:** reference voltage of the sensor (Vref) from 0.5 to 3.5 Volts by increments of 0.5 Volts, cumulative with O. V = 0x000 is forbidden. The probable reason is that VOUT can easily go negative if Vref = 0 Volts, which means bye bye your precious ADC.

_**The registers at this address have similar, but not identical effect with the M64282FP sensor.**_

Next registers are pushed only if TADD is set LOW when activating the LOAD pin, if not they overwrite registers at the corresping addresses. If these registers are set to 0x00000000, 0x00000000, the whole image is captured. TADD must be kept HIGH by default.

**Address 001, TADD LOW**
**- Register ST7-ST4:** start address in y for random adressing mode in 4 bits (0-15).
**- Register ST7-ST4:** start address in x for random adressing mode in 4 bits (0-15).

_**These registers do not exist in the M64282FP sensor.**_


**Address 010, TADD LOW**
**- Register END7-END4:** ending address in y for random adressing mode in 4 bits (0-15).
**- Register ST7-ST4:** ending address in x for random adressing mode in 4 bits (0-15).

_**These registers do not exist in the M64282FP sensor.**_


The Japanese datatsheet also proposes a table of registers which must be let at their default values, which is VERY practical considering the confusing description of some registers. It typically recommends to let the obscure SH and AZ always at zero and to not try playing with custom kernels unless you know what you are doing (which is not my case).

**Register mapping with recommended values according to the Japanese Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_address.png)

## some notes

Pushing the default Game Boy camera registers to a M64283FP is overall OK: auto-calibration is activated by default, VOUT is set to Vref in the dark (minus the drift), registers ST and END are not sent. The only noticable difference is the table of register E. While the default value in the Game Boy Camera is 0x000 (50% enhancement intensity with the M64282FP), it corresponds to 0% enhancement intensity with the M64283FP. So image appears very soft.

The M64282FP also has masked pixels lines (4 lines at the bottom of image) but they always return Vref + the saturation voltage (like if the sensor was dazzled in full light). I think nothing usefull can be deduced from this signal. On the other hand the masked pixels of the M64283FP really returns a usefull dark signal.

Overall, both sensors are remarquably compatibles. A custom Game Boy Camera rom could perfectly handle the M64283FP with very minimal efforts (like shifting the register E table and that's all).

## The random access mode

The English datasheet is totally confusing (to say the least) about how to activate the random access mode while the Japanese one if perfectly clear: all image enhancement features must be deactivated: both auto-calibration and convolution kernels (N, VH1, VH0 = 0, CL, OB = 1). And it just works.

**Recommended register settings to trigger random access mode according to the Japanese Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_setting_random_access.png)

## Showcase

The M64283FP can be dropped to the Game Boy Camera sensor PCB and works like a charm (except for register E table inconsistency) in a Game Boy Camera. It is anyway recommended to solder this sensor on a [custom PCB giving easy access](https://github.com/HerrZatacke/M64283FP-Camera-PCB) to the TADD pin.

**M64282FP sensor (left) and M64283FP sensor (right) on a Game Boy Camera sensor PCB**
![](/Pictures%20and%20datasheets/Sensor_comparison.png)

## Acknowledgments

- [Andreas Hahn](https://github.com/HerrZatacke) for the [M64283FP/82FP-compatible PCB](https://github.com/HerrZatacke/M64283FP-Camera-PCB). 
- Razole for providing me some M64283FPs.
