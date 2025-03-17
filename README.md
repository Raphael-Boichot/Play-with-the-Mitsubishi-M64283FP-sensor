# Play with the Mitsubishi M64283FP sensor and Arduino Uno
A set of codes to address the Mitsubishi M64283FP artificial retina with Arduino. These codes are [compatible with the M64282FP sensor](https://github.com/Raphael-Boichot/Play-with-the-Game-Boy-Camera-Mitsubishi-M64282FP-sensor) of the Game Boy Camera as well. Codes proposed here are just working concepts but they can easily be adapted to ESP32 or Raspberry Pi Pico, just follow the comments in code. The image decoder is a Matlab code but the text format output by the Arduino is simple enough to be interpreted in whatever langage able to eat the serial flux. The Matlab decoder may be ported to GNU Octave without much efforts (I guess).

I've decided to use an Arduino Uno to avoid the hassle of using level shifters. Levels are all 5V here, ADC included, easy way to make tests without a mess of wires. Pixel data are output in 8-bit hexadecimal ASCII text to the serial, which is slow but easy to grasp for human mind. You're free to output raw data and adapt your own decoder to go faster.

Complementary informations about the M64283FP sensor can be found in the [DashBoy Camera project page](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam?tab=readme-ov-file#some-random-informations-for-you-game-boy-camera-nerd-). The present project aims to be a knowledge repo for all the possible features of the sensor. Some of them are yet included in the [DashBoy Camera core](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam), some will stay in this repo for history as some leading features of the M64283FP, random access and projection modes, are very easy and fast to do in software in 2024. The DashBoy Camera is anyway by far the best way to experience this sensor.

**Prerequite:** a minimal knowledge of the Game Boy Camera sensor and what pin does what. You can refer to this [other project](https://github.com/Raphael-Boichot/Play-with-the-Game-Boy-Camera-Mitsubishi-M64282FP-sensor) to start.

## A bit of history to set the context
The documents used for this literature review about the artificial retina series can be found in [this repository](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam/tree/main/Docs%20and%20research/Bibliography). It contains most of the relevant references I've found to date. Technical details about how CMOS sensors work can be found in these excellent [lectures](https://isl.stanford.edu/~abbas/aeglect392b.php).

The very first commercial "solid state camera", the [Cromemco Cyclops](https://en.wikipedia.org/wiki/Cromemco_Cyclops), was issued in 1975 equipped with a [32x32 pixels MOS image sensor](/Pictures%20and%20datasheets/Popular%20Electronics-1975-02.pdf) tinkered from a [1024 bits memory chip](http://wsudbrink.dyndns.org:8080/cyclops/index.html). The chip was retrofitted with a transparent window instead of its usual metal protecting lid to take advantage of the adverse effect of light on stored bits (light depolarise them). Surprisingly, the concept was not really followed by any active development, despite being simple and fun.

The Charge Coupled Device or [CCD](https://en.wikipedia.org/wiki/Charge-coupled_device), very different technology (in short an array of photo-electrons accumulators) developped at about the [same time](https://archive.nytimes.com/lens.blogs.nytimes.com/2015/08/12/kodaks-first-digital-moment/) for image sensors, took anyway the lead of the 80s digital photography niche. CCD sensors were power hungry due to the way the pixels are extracted from the sensor surface by successive jumps. They were also expensive to produce (due to dedicated manufacturing lines) but able to capture images with a good signal to noise ratio, making them relevant for high end market like scientific imaging, despite a high sensitivity to dazzling.

This hasn't stopped tinkerers from [continuing to play](/Pictures%20and%20datasheets/BYTE%20(1983)%20Build%20the%20Micro%20D-Cam%20Solid-State%20Video%20Camera%20-%20Part%20I.pdf) with modified MOS ram chips as affordable alternatives to the expensive CCD sensors. Yet, the demand was there. Not any memory chip was however compatible as allowing to capture a usefull image required a particular gates configuration on silicon (basically an ordered array of transistors not buried below layers of interconnects) and very few manufacturers maintained this kind of odd hardware design on purpose.

The Complementary Metal–Oxide–Semiconductor or [CMOS](https://en.wikipedia.org/wiki/Active-pixel_sensor), alternative image sensing technology at least as old as CCD and based on simple arrays of amplified photodiodes, was relegated to the background all these years due to sensors plagued with critical image artifacts, despite being much cheaper to produce due to straightforward integration to existing memory/chip manufacturing lines (So the "LSI" sometimes used with sensor designation, for "Large Scale Integration"). The development of CMOS-based image sensors for viable commercial applications only took off in the early 90s, impulsed by the [NASA Jet Propulsion Laboratory](https://spinoff.nasa.gov/Spinoff2017/cg_1.html), with the aim of attacking the low end market with cheap and very low power sensors. "Good enough" images were considered as acceptable for this market. The JPL design natively did integrate automatic calibration for each pixel of a sensor to reduce noise.

## From high expectations to death in oblivion: a 5 years arduous journey
Mitsubishi company decided to develop independently its own line of CMOS sensors called “artificial retina” (AR). These sensors were (over)marketed as mimicking the behavior of a biological retina (concept probably inspired by this [American Scientist](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam/blob/main/Docs%20and%20research/Bibliography/Mahowald%20(1991)%20The%20Silicon%20Retina.pdf) article from 1991) and be able to take place in domains as broad as safety, health, education, automation, industry and even defense. The first traces of these sensors in Mitsubishi communication [date back to 1994](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam/blob/main/Docs%20and%20research/Bibliography/Kyuma%20(1994)%20Artificial%20retinas%20-%20fast%2C%20versatile%20image%20processing.pdf), with planned features like hardware coupling to neural networks, Fast Fourier Transform, pattern recognition and 1000x1000 pixels resolution at 1000 fps. What I would summarize as a quite ambitious roadmap. We were at this time in the first A.I. hype and "neural networks" in 1994 had the same impact than "machine learning" in 2024 to get juicy grant and public fascination.

The commercial boom of these "artificial retinas" however only began in 1998 with a much less ambitious application: the Game Boy Camera, equipped with the first (and probably last) mass-produced unit, the M64282FP sensor. The fate of the artificial retina series (M6428X) is then lost in more or less mass-marketed products, and they have _probably_ equipped Japanese cell phones, consumer multimedia products, fingerprint readers and [security cameras](https://ascii.jp/elem/000/000/304/304438/). The M64283FP sensor equipped for sure the [“LaPochee” camera module](https://github.com/Raphael-Boichot/Teardown-of-the-LaPochee-digital-camera-module) accompanying [the THZ43 Chiaro cell phone by Mitsubishi](https://time-space.kddi.com/ketaizukan/1999/10.html), which is technically the first mobile phone with (nearly an embedded) camera. Two capture modes were proposed: [1bpp "manga mode" or 4bbp "real mode", 96x96 pixels](https://pc.watch.impress.co.jp/docs/article/990413/tu_ka.htm). According to Mitsubishi, the M64283FP also probably equipped the [PCPICO](https://web.archive.org/web/20020925132513/http://pcpico.com/), a kind of easy-to-use-for-kids-and-elders multimedia interface in which the sensor was probably used as cheap digital camera (the scarse online documentation is all but clear about what the retina was used for, it's not really advertised). A [2003 US patent](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam/blob/main/Docs%20and%20research/Bibliography/Yerazumis%20(2003)%20ACCESSORY%20ADAPTED%20FOR%20DIGITAL%20PERSONAL%20ASSISTANT.pdf) also claims the possible use of the M64283FP in the [EyeModule digital camera](https://web.archive.org/web/20030601225744/http://eyemodule.com/splash.asp) but seeing the actual resolution (320x240), it was equipped at the end with another sensor.

The M64283FP sensor existed as a [development/evaluation kit](https://nfbcal.org/nfb-rd/1505.html) consisting of a sensor unit comprising lens, the sensor itself and a board with an ADC, an FPGA controller and working on a Windows 95 PC through the ISA bus. A development library in C/C++ was offered with. A [Super Cheap Artificial Retina Evaluation Board](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam/blob/main/Docs%20and%20research/Bibliography/MERL%20annual%20report%201999-2000_extract.pdf) was even planned, but probably never sold. A [sensor integrated on PCB, called "AR module"](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam/blob/main/Docs%20and%20research/Bibliography/Mitsubishi%20Electric%20Technical%20Journal%20(1999)%20Artificial%20retina%20with%20image%20detection%20and%20image%20processing%20functions%20LSI%20and%20modules%20with%20image%20detection%20and%20processing.pdf) with lens and a 14 pins connector, close to the Game Boy Camera sensor board, was also advertised. These prototypes probably lead to the [CamConnect](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam/blob/main/Docs%20and%20research/Bibliography/Mitsubishi%20(2000)%20CamConnect%20A%20USB%20Enabled%2C%20Embedded%20Internet%20Reference%20Design.pdf), a motorized webcam featuring the M64283FP (once again, it is unclear wether or not it reached the consumer market).

Some sensors from that series come in K (industrial, ceramic) as well as FP (home, plastic) packaging. No clear image of the M64283K or specific datasheet exists online (it is just mentioned as possible package in the M64283FP datasheet and this is the [best image](/Pictures%20and%20datasheets/M64283K.png) I've ever found). Package dimensions are unknown, but probably similar to the [M64285K](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam/blob/main/Docs%20and%20research/Bibliography/Mitsubishi%20Integrated%20Circuit%20M64285K%20Image%20Sensor.PDF) to ensure hardware back compatibility. At least an industrial infrared camera, the [FarStar F I-100](/Docs%20and%20research/Bibliography/Farstar%20F%20I-100_M64283FP_infrared_sensor.pdf), was equipped with the M64283FP sensor (not the K version surprisingly). As industrial products have completely separated and even more obscure markets, it is not excluded that they were common in industry at some point without letting a single trace today.

Technically speaking, the artificial retinas were able to perform internal real-time image processing with very basic kernels (edge detection, edge enhancement, inversion) and simple transformation (cropping, projection). These features were intended to make image post-processing easier/faster with the limited microprocessors of the mid 90s. The analog output then has to be converted into a digital signal, one pixel after the other in series, to be processed further, which represents the major bottleneck in terms of data flow rate (plus the non negligible additional cost of a fast analog to digital converter or ADC). The Game Boy Camera deals with this shortcoming by incorporating a flash ADC in its mapper but is capped to about 12 fps nevertheless (which is a _tour de force_ by itself considering the obsolete technology involved in the Game Boy, even by 1998 standard). Enough for a toy, probably not for real time applications. Sensors by themselves could _theoretically_ spit 30 fps at 500 kHz in 128x128 pixels if the ADC converting pixels and embedded memory would be fast enough (about 500k conversions per seconds with margin + about 500 kB/s of data to handle). The initial target of the retinas was maybe pure composite video but it anyway requires another signal processor on top. The analog output finally quickly relegated these shaky sensors to the status of digital history curiosity.

To overcome the weakness of pixels conversion rate, the sensors in the artificial retina series evolved towards random tile addressing and projection to reduce the flow rate of pixels to convert (M64283FP) and lower definition (the M64285FP with 32x32 pixels matrix, is _theoretically_ able to output 5000 fps...), but eventually disappeared in favor of faster, fully digital and color image sensors (M64287U and M64270G with internal 8-bit ADC for example).

Mitsubishi sensor division was finally incorporated into Renesas in 2003 and the artificial retina series eventually faded into total darkness. The M64282-83 sensors are notorious for the confusing translation of their respective datasheets which were probably never though to be used outside Japan, without dev kits and without libraries. Hopefully, the M64283FP original datasheet in Japanese is still available online and the translated version is at least _barely_ understandable. On the other hand, the original version of the M64282FP datasheet is probably forever lost / Nintendo exclusive property (which is about the same).

The M64283FP was anyway probably available for world retail at a certain point as it had a short carreer in scientific laboratories around the 2000s to tinker augmented vision systems, both in Japanese laboratory and in the West. It was never indicated if the sensor was used with pre-existing libraries or if researchers had to work with the confusing datasheets we know today. But the M64283FP was yet in competition with much faster full digital sensors, and was rapidely dismissed. From 2000, there is no mention of this sensor or any other from the artificial retina series left into any Mitsubishi official communications. The hyped concept of artificial retina was probably yet dead and gone.

## I'm a real nerd, where can I find one ?!
This sensor appears sporadically on Japanese online auction sites for random prices (from "cheap for a complete tray in its original packaging" to "total scam for one loose unit") and some Chinese chip dealers claim to have some, but I've never managed to bargain one for less than 60€ (so typically high on the scam side) nor to get a single proof that they have this sensor in stock for real (I mean at least a single image not stolen from elsewhere for example...). I finally obtained three units of the M64283FP in 2023 from a generous donator who know someone who knew someone at Mitsubishi, knowing that these sensors will have a good second home with me.

Other source is of course the quite elusive PDZ43 Lapochée camera module which appears sometimes on local auctions as electronic junk, for cheap. As the sensor is solid and electronic junk not that desirable in Japan compared to West, this can be a reliable source. I got one in 2025 like this. There was another unit on sale at the same time.

In brief, to get some, be patient and very stubborn (and a bit lucky).

Early CMOS based sensors have some particular "image signatures". The use of a fix amplifier assigned to each pixel creates images with a fixed-pattern noise, they cannot simultaneously transfer all the pixels of an image at once, which leads to image distorsion with moving objects (rolling shutter effect) and their dynamic range is rather poor compared to CCD sensors. Also, these sensors are not at all sensitive to dazzling. The images produced by the M64283FP have all of these signatures.

## Project pinout but you may use the [dedicated PCB](/PCB) and [sensor board](https://github.com/HerrZatacke/M64283FP-Camera-PCB)

| Arduino Pin |          M64283FP Sensor pin           |           Comment             |
|-------------|----------------------------------------|-------------------------------|
|  A3         | VOUT, analog signal from sensor        | uses regular GB camera ribbon |
|  D4         | Some green LED, indicates exposure     | not mandatory but cool        |
|  D5         | Some red LED, indicates serial transfer| not mandatory but cool        |
|  D6         | STRB (echo of CLOCK when VOUT active)  | not used at all               |
|  D7         | TADD (default HIGH, extra regsisters)  | has to use an external wire   |
|  D8         | READ (image ready to transfer)         | uses regular GB camera ribbon |
|  D9         | CLOCK (self explanatory)               | uses regular GB camera ribbon |
|  D10        | RESET (self explanatory                | uses regular GB camera ribbon |
|  D11        | LOAD (enable register)                 | uses regular GB camera ribbon |
|  D12        | SIN (register channel)                 | uses regular GB camera ribbon |
|  D13        | START (exposure trigger)               | uses regular GB camera ribbon |
|  GND        | GND                                    | uses regular GB camera ribbon |
|  +5V        | +5V                                    | uses regular GB camera ribbon |

The Arduino codes comprises an auto-exposure routine, so it may give something interesting at first try.


**The PCB you can order to play with the sensor**
![](/PCB/PCB.png)

## Register setting, the comprehensive explanation

Understanding the registers system for the first time is not trivial, knowing the sketchy documentation available. Despite everything, through trial and error, datalogging and a bit of educated guess (plus quite a lot of time), I think I overall understand how to drive them now.

**Register mapping according to the English Datasheet of the M64283FP sensor**
![M64283FP](/Pictures%20and%20datasheets/Registers_address_M64283FP_2.png)

The English datasheet gives the whole list of registers. Most of them have no practical use or must be kept at default value, so stay relaxed and focused. TADD is a sensor pin used to push registers at other address ranges, exclusive to the M64283FP. It is pulled HIGH by default, except for last two addresses, where it must be set LOW at precise moments. The equivalent pin called TSW on the M64282FP is pulled HIGH by default and has the following comment: _**NOTE: don't connect this pin**_, So _**of course I've tried to connect it**_, but without gaining any clear knowledge, the M64282FP sensor just goes crazy (but still alive after this). Don't try this at home kids.

Most of the registers acts the same with the Game Boy Camera, so these explanations can be used as reference for it. The registers have no particular order, they can be pushed at any address one after the other per packets of 11 bits (3 bits address + 8 bits registers), address first. When the 8 first addresses are validated (TADD HIGH), the sensor is ready and can start without the 2 additionnal registers.

**Address 000, TADD HIGH** (The registers at this address have exactly the same effect with the M64282FP sensor)
- **Register Z1-Z0:** used to force the output voltage of the sensor (VOUT) to match Vref given by register V, in dark conditions (other said, it fixes the lowest possible voltage). In total darkness, Vref however shifts a bit with exposure time compared to value given by register V and can be corrected by activating an auto-calibration circuit (see next addresses). Default values recommended: Z1 = 1 and Z0 = 0. Honestly I do not even understand why users have access to these registers. VOUT should be always tied to register V by default without doing anything.
- **Register O5-O0:** plus or minus voltage (in small increments, 32 steps of 32 mV) added to Vref given by register V. MSB gives the polarity (plus or minus) of the applied voltage. Its relevancy with the M64283FP sensor is debatable as this sensor can self calibrate. But it's there anyway. On the M64282FP, using O is the only way to fine tune Vref when it drifts with exposure time or between sensors.

**Effect of registers Z, V and O translated from the original Japanese datasheet (Note that STRB and XCK are inverted, like if it was not yet confusing enough...)**
![M64283FP](/Pictures%20and%20datasheets/Bias_registers.png)

Even by translating the original datasheet, this is a bit confusing. What is depicted as VOffset is effect of register O for me, unless the two upper curves are from two different sensors. But you get the idea: always set Z1 to 1 and you'll get a dark signal approximately equal to voltage given by register V, called Vref. This Vref varies between sensors for a same set of registers, but also with exposure time. This variation/drift is called VOffset. VOffset can be cancelled automatically by putting register CL = 0 and OB = 0 with the M64283FP sensor. Vref itself is the sum of V (raw tuning) and O (fine tuning). On the M64282FP sensor, CL and OB registers do not exist, so the only way to cancel Voffset is to pre-calculate a lookup table of register O to apply for each sensor and each exposure time. This is basically what the [Game Boy Camera calibration procedure](https://github.com/Raphael-Boichot/Inject-pictures-in-your-Game-Boy-Camera-saves?tab=readme-ov-file#part-3-calibrating-the-sensor) does. So putting register CL = 1 and OB = 1 with the M64283FP sensor basically turns it into a M64282FP regarding Vref management.


**Address 001, TADD HIGH** (The registers at this address have exactly the same effect with the M64282FP sensor)
- **Registers N, VH1, VH0:** playing with these 3 registers enable image enhancement and choose which convolution kernel to apply among 4 pre-calculated ones. Convolution kernels can also be forced via P, M and X registers if you like pain. The formula to force custom kernels is not trivial at all. All 3 must be set to 0 to disable safely border enhancements. The English datasheet has vertical and horizontal enhancements inversed in the register array. 
- **Registers G:** output gain, see tables in datasheet.

**Effect of N, VH1 and VH0 at 87.5% enhancement intensity**
![M64283FP](/Pictures%20and%20datasheets/Enhancement.png)

**Address 010 and 011, TADD HIGH** (The registers at this address have exactly the same effect with the M64282FP sensor)
- **Register C:** Exposure time in 65535 (0xFFFF, 2x8 bits) increments of 16 µs. Maximal exposure is 1048 ms if the clock signal is set to 500 khz, recommended frequency. Downclocking is possible to increase exposure time but overcloking gives image with artifacts (top of the image becomes more and more dark with increasing frequency). Without image enhancement, 0x0010 is the minimal exposure recommended. With border enhancement, 0x0021 is the minimal exposure recommended (0x0030 for the M64282FP). Using values below these creates images with very strong artifacts. C = 0x0000 is a forbidden state.


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
- **Register E3-E0:** intensity of edge enhancement, from 0% to 87.5% (E2-E1-E0). **With the same registers, the M64282FP sensor goes from 50% to 500%.** MSB (E3) allows switching between edge enhancement and edge detection modes. 
- **Register I:** outputs the image in negative, but flips the whole voltage scale too.
- **Registers V2-V0:** reference voltage of the sensor (Vref) from 0.5 to 3.5 Volts by increments of 0.5 Volts, cumulative with O. V = 0b000 is a forbidden state. The probable reason is that VOUT can easily go negative if Vref = 0 Volts, which means bye bye your precious ADC (or MAC-GBD).

**Comparison of register E effect on the M64282FP and M64283FP, 128x128 pixels area captured**
![M64283FP](/Pictures%20and%20datasheets/Edge_comparison.png)

The images clearly show the 4 lines of saturated pixels at the bottom of the M64282FP sensor (effective resolution is only 128x123 pixels). On the other hand, the M64283FP is a real 128x128 sensor. How to take advantage of the saturated pixel lines of the 82FP for anything usefull is unknown to me. In case of edge enhancement, both sensors output images with artifacted edging.

**In similar conditions of indoor light, with adapted registers, the two sensors give remarkably similar images.** Do not mind the constrast difference between sensors, it is just due to my post-processing code.

Next registers are pushed only if TADD is set LOW when activating the LOAD pin, if not they overwrite registers at the corresponding addresses. If these registers are set to 0b00000000, 0b00000000, the whole image is captured. TADD must be kept HIGH by default. The image is splitted in 16x16 tiles and you have to draw a rectangle into that. Analog image pixels are spit in reading order like a regular image, but with new dimensions. STRB pin repeats the CLOCK signal as long as data are available on pin VOUT but counting CLOCK cycles from READ rising front is enough to collect all pixels according to my own tests.

**Address 001, TADD LOW (optional registers)** (These registers do not exist in the M64282FP sensor)
- **Register ST7-ST4:** start address in y for random adressing mode in 4 bits (range 0-15).
- **Register ST3-ST0:** start address in x for random adressing mode in 4 bits (range 0-15).
If ending address is lower that starting address, the whole register is set to 0b00000000 (whole image capture).


**Address 010, TADD LOW (optional registers)** (These registers do not exist in the M64282FP sensor)
- **Register END7-END4:** ending address in y for random adressing mode in 4 bits (range 0-15).
- **Register END3-END0:** ending address in x for random adressing mode in 4 bits (range 0-15).
If ending address is lower that starting address, the whole register is set to 0b00000000 (whole image capture).


The Japanese datatsheet also proposes a table of registers which must be let at their default values, which is VERY practical considering the confusing description of some registers in English datasheet. It typically recommends to let the obscure SH and AZ always at zero and to not try playing with custom kernels unless you know what you are doing (which is not my case).

**Register mapping with recommended values according to the Japanese Datasheet of the M64283FP sensor**
![M64283FP](/Pictures%20and%20datasheets/Registers_address_M64283FP.png)

Even if it doesn't appear so at first glance, this simple table clarifies all the issues raised by the poorly translated English datasheet. Obscure/unknown/ill documented registers are all set to zero !

## Some additional notes

Pushing the default Game Boy camera registers to a M64283FP is overall OK: auto-calibration is activated by default, VOUT is set to Vref + O in the dark, registers ST and END are not sent. The only noticable difference is the table of register E. While the default value in the Game Boy Camera is 0b000 (50% enhancement intensity with the M64282FP), it corresponds to 0% enhancement intensity with the M64283FP. So image appears very soft.

The M64282FP has also masked pixels lines (4 lines at the bottom of image) but they always return Vref + O + the saturation voltage (like if these pixels were dazzled in full light). I think nothing usefull can be deduced from this signal, I do not understand their purpose at first glance (It maybe be used by the Game Boy Camera but I do not understand how). On the other hand the masked pixels of the M64283FP really returns a usefull dark signal.

Overall, both sensors are remarquably compatibles. A custom Game Boy Camera rom could perfectly handle the M64283FP with very minimal efforts (like shifting the register E table).

**As the default Arduino commands (digital read and write) are barely able to bitbang the clock at the recommended 500 kHz, the device is underclocked with the codes proposed here and exposure is always too long. Images in full daylight are generally overexposed for this reason.**

## The random access mode

The English datasheet is totally confusing about how to activate the random access mode while the Japanese one if perfectly clear: all image enhancement features must be deactivated: both auto-calibration and convolution kernels (N, VH1, VH0 = 0, CL, OB = 1). My own tests show that CL and OB = 1 are mandatory, not N, VH1, VH0 = 0.

**Recommended registers setting to trigger random access mode according to the Japanese Datasheet of the M64283FP sensor**
![M64283FP](/Pictures%20and%20datasheets/Registers_setting_random_access_M64283FP.png)

**Image taken strip by strip (32x128 pixels) with random access mode, Game Boy Camera plastic lens**
![M64283FP](/Pictures%20and%20datasheets/Random_access_M64283FP.png)

The random access to sensor surface increases very efficiently the frame rate, in particular with the sluggish Arduino Uno.

**96x96 pixels image, hardware cropped by random access mode, format of the [LaPochee module](https://time-space.kddi.com/ketaizukan/1999/11.html) on top of a full frame 128x128 pixels image, Game Boy Camera plastic lens**
![M64283FP](/Pictures%20and%20datasheets/LaPochee.png)
(Funfact, the LaPochee in fact uses a software cropping on a full frame image according to the sensor connections, TADD is not connected)

The dark halo on top of the image is probably due to timing inconsistencies when using the Arduino Uno during image acquisition. This dark halo is more or less present depending on the exposure registers. I did not find any clear pattern however.

I suppose that the CLOCK and the ADC may be too slow with the Arduino. Using a device with a decently fast ADC like the Raspberry Pi Pico allows bitbanging the CLOCK at nearly 500kHz while converting VOUT, what fixes both issues.

I have observed the [same artifacts](https://github.com/Raphael-Boichot/Play-with-the-Game-Boy-Camera-Mitsubishi-M64282FP-sensor/blob/main/ESP32_version_beta/Image_taken_with_ESP32.png) when attempting to port the code to ESP32 due to its slow ADC. 

## The projection mode

Based on the English datasheet instructions (which are totally confusing, oh, I yet said that), I was not able to get intersting signal. So I've restarted from scratch : used registers similar to random access mode, CL = 1, OB = 1 , N = 0, VH1 = 0 and VH0 = 0 and played with the two projection registers, it works. Let TADD always HIGH. This mode is particularly fast, it can theoretically reach about 4000 "f"ps.

**Recommended registers setting to trigger projection mode according to my own reverse engineering**
![M64283FP](/Pictures%20and%20datasheets/Registers_setting_projection_M64283FP.png)

**Me projected in one dimension of space (y-axis) and stretched in one dimension of time (x-axis). It does not hurt.**
![M64283FP](/Pictures%20and%20datasheets/Projection_M64283FP.gif)

As data are averaged on 128 pixels, the pick-to-valley signal is quite weak in this mode. You'd better have a good post-processing to extract something usefull from it. Vertical artifacts are due to the autoexposure algorithm implemented within the Arduino. Sadly, this mode would have been more interesting with outputing just a vertical line of pixels without projection, to make slit scan photography...

## Showcase

The M64283FP can be dropped to the Game Boy Camera sensor PCB and works like a charm (except for register E table inconsistency) in a Game Boy Camera. It is anyway recommended to solder this sensor on a [custom PCB giving easy access](https://github.com/HerrZatacke/M64283FP-Camera-PCB) to the TADD pin

**M64282FP sensor (left) and M64283FP sensor (right) mounted on a Game Boy Camera sensor PCB**
![M64283FP](/Pictures%20and%20datasheets/Sensor_comparison_M64282FP_vs_M64283FP.png)

**M64283FP sensor mounted on a dedicated sensor PCB giving access to STRB and TADD pins**
![M64283FP](/Pictures%20and%20datasheets/Sensor_special_PCB_M64283FP.png)

**M64283FP sensor mounted on the sensor PCB of the [PDZ43 Lapochée digital camera module](https://github.com/Raphael-Boichot/Teardown-of-the-LaPochee-digital-camera-module)**
![](/Pictures%20and%20datasheets/Lapochee_sensor_PCB_front_M64283FP.jpg)

The M64282FP itself is yellowish while the M64283FP is more grayish, they are easy to discriminate just on this criterion. I suspect a better light sensivity of the 83FP, in particular in IR, compared to the 82FP. It's just a feeling, not a scientific measurement.

**Image taken without (left) and with (right) image enhancement at 50% intensity, Game Boy Camera plastic lens**
![M64283FP](/Pictures%20and%20datasheets/Image_enhancement_M64283FP.png)

The effect of image enhancement is a little bit less aesthetic (purely subjective observation) than with the M64282FP but does the job anyway. It does not show vertical streaks like the M64282FP (in particular the early series).

**The setup used, Arduino Uno and [custom sensor board](https://github.com/HerrZatacke/M64283FP-Camera-PCB) to ease access to TADD pin**
![M64283FP](/Pictures%20and%20datasheets/Setup_M64283FP.png)

I did use here my janky prototyping board but it would be easier for you to [directly order the custom PCB](/PCB).

Final words: soldering/desoldering these sensors with such fragile front acrylic window is a bit stressful. I recommend covering the window with tape and working fast with a good soldering iron set at 300°C. For desoldering, carefully lift one side while heating all the pins on this side at once to detach them from the PCB. Adding extra fresh solder first very eases the process. Let cool down before dealing with the other side. Try not bending pins. No need for low temperature solder, just be quick. **No heat gun or the epoxy casing will delaminate from the sensor surface, ruining the optical properties.** For soldering, I recommend to gently push with the finger when soldering to ensure that optical plane is parallel to the PCB and drain as much heat as possible by thermal conduction. Do some pins to secure the sensor first, let cool down, continue with other pins, and so on.

**The mandatory RGB picture attempt made with a [DashBoy Camera](https://github.com/Raphael-Boichot/Mitsubishi-M64282FP-dashcam) and the M64283FP sensor**
![M64283FP](/Pictures%20and%20datasheets/RGB_M64283FP.png)

## Acknowledgments

- [Andreas Hahn](https://github.com/HerrZatacke) for the [M64283FP/82FP-compatible PCB](https://github.com/HerrZatacke/M64283FP-Camera-PCB). 
- Razole for providing me some M64283FPs. I've done my homeworks now, Mr Razole, I can disappear from social media.
