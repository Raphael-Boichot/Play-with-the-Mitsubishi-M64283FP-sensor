# Play with the Mitsubishi M64283FP sensor and Arduino Uno
A set of codes to address the Mitsubishi M64283FP artificial retina with Arduino. These codes are [compatible with the M64282FP sensor](https://github.com/Raphael-Boichot/Play-with-the-Game-Boy-Camera-Mitsubishi-M64282FP-sensor) of the Game Boy Camera as well. Codes proposed here are just working concepts but they can easily be adapted to ESP32 or [Raspberry Pi Pico](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam), just follow the comments in code. The image decoder is a Matlab code but the text format output by the Arduino is simple enough to be interpreted in whatever langage eating the serial flux.

**Prerequite:** a minimal knowledge of the Game Boy Camera sensor and what pin does what. You can refer to this [other project](https://github.com/Raphael-Boichot/Play-with-the-Game-Boy-Camera-Mitsubishi-M64282FP-sensor) to start.

## Some history
The documents used for this literature review about the artificial retina series can be found in [this repository](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam/tree/main/Docs%20and%20research/Bibliography)

Mitsubishi created a series of CMOS sensors called “artificial retina”, with the aim of flooding the market with low cost, low power and easy-to-program devices. It was marketed as mimicking the behavior of a biological retina (!) and be able to take place in domains as broad as safety, health, education, automation and industry in general. The first traces of these sensors in literature date back to 1994, but their commercial boom really began in 1998 with the launch of the Game Boy Camera and the first mass-produced sensor, the M64282FP. The trace of these sensors is then lost in more or less mass-market products, and they have certainly equipped cell phones, consumer multimedia products, fingerprint readers and security cameras. It is almost certain that the M64283FP sensor equipped the [“LaPochee” module](https://time-space.kddi.com/ketaizukan/1999/11.html) accompanying [the THZ43 Chiaro cell phone by Mitsubishi](https://time-space.kddi.com/ketaizukan/1999/10.html) and the [PCPICO](https://web.archive.org/web/20020925132513/http://pcpico.com/), a kind of multimedia interface in which the function of the sensor by itself is not clear. Some sensors from that series come in K (industrial, ceramic) as well as FP (home, plastic) packaging.

The M64283FP also existed as a [development/evaluation kit](https://nfbcal.org/nfb-rd/1505.html) consisting of a sensor unit comprising lens, the sensor itself and a board with an ADC, an FPGA controller and working on a Windows 95 PC through the ISA bus. A development library ic C/C++ was offered with. 

The originality (and shortcoming) of these sensors is that they produce an analog output while using digital commands (registers) that are “relatively” simple to calculate. The artificial retinas are able to perform internal real-time image processing with very basic kernels (edge detection, edge enhancement, inversion) and transformation (cropping, projection), called "LSI" (Large Scale Integration). These features were intended to make image post-processing easier/faster with the limited microprocessors of the mid 90s. The analog output then has to be converted into a digital signal, byte by byte, to be processed further, which represents the major bottleneck in terms of data flow rate (plus a non negligible additional cost, a flash ADC being quite expensive). The Game Boy Camera deals with this shortcoming by incorporating a very fast analog-to-digital converter in its mapper but is capped to about 12 fps nevertheless. Enough for a toy, not for real time applications. Sensors by themselves can _theoretically_ spit 30 fps at 500 kHz in 128x128 pixels if the ADC follows.

To overcome this slow data transmission rate, the sensors in the artificial retina series evolved towards random tile addressing and projection to reduce the flow rate of pixels to convert (M64283FP) and lower definition (the M64285FP with 32x32 pixels matrix, is able to output 5000 fps), but eventually disappeared in favor of faster, fully digital sensors. It is totally unknown to this date which artificial retina equipped with apparatus and what the production volume was, except for the Game Boy Camera that reaches the West market.

Mitsubishi sensor division was finally incorporated into Renesas in 2003 and the artificial retinas eventually faded into total obscurity. The M64282-83 sensor series is notorious for the rushed translation of their datasheets which were probably never though to be understood outside Japan. Hopefully, the M64283FP original datasheet in Japanese is available and the translated version is at least barely understandable.

The M64283FP was probably available for retail at a certain point as it had a quite successful carreer in labs to tinker augmented vision systems, both in Japanese laboratory and in the West. 

This sensor appears sporadically on Japanese online auction sites for random prices and some Chinese chip dealers claim to have some, but I've never managed to bargain one for less than 60€ (which is a no go for me). I finally obtained two copies of the M64283FP in the summer 2023 from a generous donator who knew someone who knew someone at Mitsubishi, knowing that these sensors will have a good second home with me.

## Register setting, the comprehensive explanation

Understanding the registers system for the first time is not trivial, knowing the sketchy documentation available. Despite everything, through trial and error, datalogging and a bit of educated guess (plus quite a lot of time), I think I overall understand how to drive them now.

**Register mapping according to the English Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_address_2.png)

The English datasheet gives the whole list of registers. Most of them have no practical use or must be kept at default value, so stay relaxed and focused. TADD is a sensor pin used to push registers at high address ranges, exclusive to the M64283FP. It is pulled HIGH by default, except for last two addresses, where it must be set LOW at precise moments. The equivalent pin called TSW on the M64282FP is pulled HIGH by default and has the following comment: _**NOTE: don't connect this pin**_, So _of course_ I've tried to connect it because I love the thrill of danger, but without any clear result, the M64282FP sensor just goes crazy (but still alive after this).

Most of the registers acts the same with the Game Boy Camera, so these explanations can be used as reference for it. The registers have no particular order, they can be pushed at any address one after the other per packets of 11 bits (3 bits address + 8 bits registers), address first. When the 8 first addresses are validated (TADD HIGH), the sensor is ready and can start without the 2 additionnal registers.

**Address 000, TADD HIGH** (The registers at this address have exactly the same effect with the M64282FP sensor)
- **Register Z1-Z0:** used to force the output voltage of the sensor (VOUT) to match Vref given by register V, in dark conditions (other said, it fixes the lowest possible voltage). In total darkness, Vref however shifts a bit with exposure time compared to value given by register V and can be corrected by activating an auto-calibration circuit (see next addresses). Default values recommended: Z1 = 1 and Z0 = 0.
- **Register O5-O0:** plus or minus voltage (in small increments, 32 steps of 32 mV) added to Vref given by register V. MSB gives the polarity (plus or minus) of the applied voltage. Its relevancy with the M64283FP sensor is debatable as this sensor can self calibrate. But it's there anyway. On the M64282FP, using O is the only way to fine tune Vref when it drifts with exposure time or between sensors.

**Effect of registers V and O translated from the original Japanese datasheet**
![](/Pictures%20and%20datasheets/Bias_registers.png)

Even by translating the original datasheet, this is a bit confusing. What is depicted as VOffset is effect of register O for me, unless the two upper curves are from two different sensors. But you get the idea: always set Z1 to 1 and you'll get a dark signal approximately equal to voltage given by register V, called Vref. This Vref varies between sensors for a same set of registers, but also with exposure time. This variation/drift is called VOffset. VOffset can be cancelled automatically by putting register CL = 0 and OB = 0 with the M64283FP sensor. Vref itself is the sum of V (raw tuning) and O (fine tuning). On the M64282FP sensor, CL and OB registers do not exist, so the only way to cancel Voffset is to pre-calculate a lookup table of register O to apply for each sensor and each exposure time. This is basically what the [Game Boy Camera calibration procedure](https://github.com/Raphael-Boichot/Inject-pictures-in-your-Game-Boy-Camera-saves?tab=readme-ov-file#part-3-calibrating-the-sensor) does. So putting register CL = 1 and OB = 1 with the M64283FP sensor basically turns it into a M64282FP regarding Vref management.


**Address 001, TADD HIGH** (The registers at this address have exactly the same effect with the M64282FP sensor)
- **Registers N, VH:** enable image enhancement (N) and choose which convolution kernel to apply among 4 pre-calculated ones (VH0, VH1). Convolution kernels can also be forced via P, M and X registers if you like pain. The formula to force custom kernels is not trivial at all.
- **Registers G:** output gain, see tables in datasheet.


**Address 010 and 011, TADD HIGH** (The registers at this address have exactly the same effect with the M64282FP sensor)
- **Register C:** Exposure time in 65535 (0xFFFF, 2x8 bits) increments of 16 µs. Maximal exposure is 1048 ms if the clock signal is set to 500 khz, recommend frequency. Downclocking is possible to increase exposure time but overcloking gives image with artifacts (top of the image becomes more and more dark with increasing frequency). Without image enhancement, 0x0010 is the minimal exposure recommended. With image enhancement, 0x0020 is the minimal exposure recommended (0x0030 for the M64283FP). Using values below these creates images with very strong artifacts. C = 0x0000 is forbidden.


**Address 100, TADD HIGH** (The registers P3-P0 at this address have exactly the same effect with the M64282FP sensor. SH and AZ does not exist in the M64282FP sensor)
- **Registers SH, AZ** totally confusing role in the English datasheet, not even mentioned in the Japanese datasheet. I guess these are not critical so. Recommended default values: SH = 0, AZ = 0. **Forget them basically.**
- **Register CL:** Enables the auto-calibration circuit and cancels the voltage shift of Vref with exposure time. Is used in conjonction with OB that outputs the signal from a line of masked pixels for reference in the dark at the very top of the image. 0 is active.
- **Registers P3-P0** custom convolution kernels. 0b0001 by default.


**Address 101, TADD HIGH** (These registers differ notably from M64282FP sensor)
- **Registers PX, PY:** projection mode when active (vertical, horizontal, none). Recommended values: PX = 0, PY = 0 (no projection). This mode seems dismissed in the Japanese datasheet as no typical set of registers are provided to activate it.
- **Register MV4:** plus or minus bias for projection mode.
- **Register OB:** Enable to output optical black level (electrical signal of physically masked pixels) as a dark pixel line at the top of the image. Is used in conjonction with CL. 0 is active.
- **Register M3-M0:** custom convolution kernels. 0b0000 by default.


**Address 110, TADD HIGH** (These registers differ notably from M64282FP sensor)
- **Register MV3-MV0:** voltage bias for the projection mode, 16 steps of 8 mV.
- **Register X3-X0:** custom convolution kernels. 0b0001 by default.


**Address 111, TADD HIGH** (The registers at this address have similar, but not identical effect with the M64282FP sensor)
- **Register E3-E0:** intensity of edge enhancement, from 0% to 87.5%. **With the same registers, the M64282FP sensor goes from 50% to 500%. Only way to cancel this effect is so to use register N**
- **Register I:** outputs the image in negative, but messes the voltage range too.
- **Registers V2-V0:** reference voltage of the sensor (Vref) from 0.5 to 3.5 Volts by increments of 0.5 Volts, cumulative with O. V = 0b000 is a forbidden state. The probable reason is that VOUT can easily go negative if Vref = 0 Volts, which means bye bye your precious ADC (or MAC-GBD).


Next registers are pushed only if TADD is set LOW when activating the LOAD pin, if not they overwrite registers at the corresping addresses. If these registers are set to 0b00000000, 0b00000000, the whole image is captured. TADD must be kept HIGH by default. The image is splitted in 16x16 tiles and you have to draw a rectangle into that. Analog image data are spit in reading order like a regular image, but with new dimensions. STRB pin repeats the CLOCK signal as long as data are available on pin VOUT but counting CLOCK cycles from READ rising front is enough to collect all pixels according to my own tests.

**Address 001, TADD LOW (optional registers)** (These registers do not exist in the M64282FP sensor)
- **Register ST7-ST4:** start address in y for random adressing mode in 4 bits (range 0-15).
- **Register ST3-ST0:** start address in x for random adressing mode in 4 bits (range 0-15).
If ending address is lower that starting address, the whole register is set to 0b00000000 (whole image capture).


**Address 010, TADD LOW (optional registers)** (These registers do not exist in the M64282FP sensor)
- **Register END7-END4:** ending address in y for random adressing mode in 4 bits (range 0-15).
- **Register END3-END0:** ending address in x for random adressing mode in 4 bits (range 0-15).
If ending address is lower that starting address, the whole register is set to 0b00000000 (whole image capture).


The Japanese datatsheet also proposes a table of registers which must be let at their default values, which is VERY practical considering the confusing description of some registers in English. It typically recommends to let the obscure SH and AZ always at zero and to not try playing with custom kernels unless you know what you are doing (which is not my case).

**Register mapping with recommended values according to the Japanese Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_address.png)

Even if it doesn't appear so at first glance, this simple table clarifies all the issues raised by the poorly translated English datasheet. Obscure/unknown/ill documented registers are all set to zero !

## Some additional notes

Pushing the default Game Boy camera registers to a M64283FP is overall OK: auto-calibration is activated by default, VOUT is set to Vref in the dark (minus the drift), registers ST and END are not sent. The only noticable difference is the table of register E. While the default value in the Game Boy Camera is 0b000 (50% enhancement intensity with the M64282FP), it corresponds to 0% enhancement intensity with the M64283FP. So image appears very soft.

The M64282FP has also masked pixels lines (4 lines at the bottom of image) but they always return Vref + the saturation voltage (like if the sensor was dazzled in full light). I think nothing usefull can be deduced from this signal, I do not understand their purpose at first glance. On the other hand the masked pixels of the M64283FP really returns a usefull dark signal.

Overall, both sensors are remarquably compatibles. A custom Game Boy Camera rom could perfectly handle the M64283FP with very minimal efforts (like shifting the register E table).

**As The Arduino Uno is totally unable to drive the clock at 500 kHz, the device is very severely underclocked here and exposure is always too long by a factor of 4 at least. Images in full daylight are always white for this reason.**

## The random access mode

The English datasheet is totally confusing about how to activate the random access mode while the Japanese one if perfectly clear: all image enhancement features must be deactivated: both auto-calibration and convolution kernels (N, VH1, VH0 = 0, CL, OB = 1). My own tests show that CL and OB = 1 are mandatory, not N, VH1, VH0 = 0.

**Recommended register settings to trigger random access mode according to the Japanese Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_setting_random_access.png)

## The projection mode - is it real ?

Based on the English datasheet instructions (which are totally confusing and contradictory), I'm not able to get other than noise or very faint signal variations with this mode. I've tried many random variations of the recommended registers. I got things. There is not a single mention of projection mode in the Japanese datasheet. I guess this isn't the device most prominent feature. Only benefit: outputing only 128 bytes of crap data per image is ultra fast (theoretically about 4000 "f"ps).

## Showcase

The M64283FP can be dropped to the Game Boy Camera sensor PCB and works like a charm (except for register E table inconsistency) in a Game Boy Camera. It is anyway recommended to solder this sensor on a [custom PCB giving easy access](https://github.com/HerrZatacke/M64283FP-Camera-PCB) to the TADD pin. The project can also use the PCB proposed here.

**M64282FP sensor (left) and M64283FP sensor (right) mounted on a Game Boy Camera sensor PCB**
![](/Pictures%20and%20datasheets/Sensor_comparison.png)

The Game Boy Camera sensor board is compatible with the M64283FP but does not give easy access to the TADD pin. The M64282FP itself is yellowish while the M64283FP is more grayish. I suspect a better light sensivity of the 83FP compared to the 82FP.

**Image taken without (left) and with (right) image enhancement at 50% intensity, Game Boy Camera plastic lens**
![](/Pictures%20and%20datasheets/Image_enhancement.png)

The effect of image enhancement is a little bit less aesthetic than with the M64282FP but does the job anyway.

**Image taken strip by strip (32x128 pixels) with random access mode, Game Boy Camera plastic lens**
![](/Pictures%20and%20datasheets/Random_access.png)

The random access to sensor surface increases very efficiently the frame rate, in particular with the sluggish Arduino Uno.

**96x96 pixels image, hardware cropped by random access mode, format of the [LaPochee module](https://time-space.kddi.com/ketaizukan/1999/11.html) on top of a full frame 128x128 pixels image, Game Boy Camera plastic lens**
![](/Pictures%20and%20datasheets/LaPochee.png)

The dark halo on top of the image is due to timing inconsistencies when using the Arduino Uno during image acquisition. Basically both the CLOCK and the ADC are too slow and the voltage drifts (image is red from bottom to top). Using a device with a decently fast ADC like the Raspberry Pi Pico allows bitbanging the CLOCK at nearly 500kHz while converting VOUT, what fixes this issue. Surprisingly, the ESP32 produces [images with same kind of artifacts](https://github.com/Raphael-Boichot/Play-with-the-Game-Boy-Camera-Mitsubishi-M64282FP-sensor/blob/main/ESP32_version_beta/Image_taken_with_ESP32.png) due to its surprisingly slow as shit ADC.

**The setup used, Arduino Uno and custom sensor board to ease access to TADD pin**
![](/Pictures%20and%20datasheets/Setup.png)

I did use here my janky prototyping board but it would be easier for you to [directly order the custom PCB](/PCB).

Final words: soldering/desoldering these sensors with such fragile front acrylic window is a bit stressful. I recommend covering the window with tape and working fast with a good soldering iron set at 300°C. For desoldering, carefully lift one side while heating all the pins on this side at once to detach them from the PCB. Adding extra fresh solder first very eases the process. Let cool down before dealing with the other side. Try not bending pins. No need for low temperature solder, just be quick. **No heat gun or the epoxy casing will delaminate from the sensor surface, ruining the optical properties.** For soldering, I recommend to gently push with the finger when soldering to ensure that optical plane is parallel to the PCB and drain as much heat as possible by thermal conduction. Do some pins to secure the sensor first, let cool down, continue with other pins, and so on.

## Acknowledgments

- [Andreas Hahn](https://github.com/HerrZatacke) for the [M64283FP/82FP-compatible PCB](https://github.com/HerrZatacke/M64283FP-Camera-PCB). 
- Razole for providing me some M64283FPs. I've done my homeworks now, Mr Razole.
