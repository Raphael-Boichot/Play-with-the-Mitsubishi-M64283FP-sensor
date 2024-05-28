# Play with the Mitsubishi M64283FP sensor
A set of codes to address the Mitsubishi M64283FP artificial retina with Arduino. These codes are compatible with the M64282FP sensor of the Game Boy Camera as well.

## Some history
Mitsubishi created a series of CMOS sensors called “artificial retina”, with the aim of becoming inexpensive, easy-to-program consumer products. The first traces of these sensors in literature date back to 1994, but their commercial boom really began in 1998 with the launch of the Game Boy Camera and the first mass-produced sensor, the M64282FP. The trace of these sensors is then lost in more or less mass-market products, and they have certainly equipped cell phones, consumer multimedia products, fingerprint readers and security cameras, but the reference of the sensors used is lost to this day. It is almost certain that the M64283FP sensor equipped the “LaPochee” module accompanying the TZ43 Chiaro cell phone and the PCPICO, a kind of multimedia interface in which the role of the sensor is not clearly established.

The originality (and shortcoming) of these sensors is that they produce an analog output from digital registers that are “relatively” simple to apply and allow real-time image processing with conventional transformations (edge detection, inversion, gain change, etc.). This analog output then has to be converted into a digital signal byte by byte to be processeds further, which represents a major bottleneck in terms of data flow. The Game Boy Camera overcomes this shortcoming by incorporating a very fast analog-to-digital converter in its mapper but is capped to about 12 fps nevertheless.

To overcome this shortcoming, the sensors in the analog range evolved towards random tile addressing (M64283FP) and lower definitiveness (M64285FP), but eventually disappeared in favor of faster, fully digital sensors. It is totally unknown now which sensor equipped with apparatus and what the production volume was, except for the Game Boy Camera.

Mitsubishi's sensor division was finally incorporated into Renesas in 2003. The M642XX sensor series is notorious for the disastrous translation of these datasheets which were probably never though to be distributed outside Japan. Hopefully, the M64283FP original datasheet is available and the translated version is at least understandable.

The M64283FP was probably available for retail as it had a quite successful carrer in labs to make augmented vision equipment, both in Japanese laboratory and in the West. 

ce capteur apparaît sporadiquement sur des sites d'enchère en ligne japonais pour un prix aléatoire et certains destockeurs de puce chinois declarent en posséder mais je n'ai jamais réussi à en obtenir par ce biais malgré des palabres sans fin pour négocier les prix et quantités. J'ai obtenu deux exemplaires du M64283FP par un genereux donateur qui connait quelqu'un qui connait quelqu'un chez Mitsubishi...

## Register setting

**Register mapping according to the English Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_address_2.png)

**Address 000, TADD HIGH**
**Register Z1-Z0:** used to correct the output voltage (VOUT) so that it matches Vref given by register V in dark conditions. In total darkness, VOUT anyway shifts with exposure time compared to Vref and can be corrected other registers (see next). Default values recommended: Z1 = 1 and Z0 = 0.
**Register O5-O0:** plus or minus voltage (in small increments, 32 steps of 32 mV) added to register Vref given by register V. MSB gives the polarity of the applied voltage.
The registers at this address have exactly the same effect with the M64282FP sensor.

**Address 001, TADD HIGH**
**Registers N, VH:** enable image enhancement (N) and choose which convolution kernel to apply among 4 (VH0, VH1). Convolution kernels can also be forced via P, M and X registers. The formula to force custom kernels is not trivial.
**Registers G:** output gain, see tables in datasheet.
The registers at this address have exactly the same effect with the M64282FP sensor.

**Address 010 and 011, TADD HIGH**
**Register C:** Exposure time in 65535 increments of 16 µs. Maximal exposure is 1048 ms if clock is set to 500 Mhz. Downclocking is possible to increase exposure time but overcloking gives image with intense artifacts (top of the image becomes black). Without image enhancement, 0x0010 is the minimal exposure recommended. With image enhancement, 0x0020 is the minimal exposure recommended (0x0030 for the M64283FP). Using values below that creates images with black parts.
The registers at this address have exactly the same effect with the M64282FP sensor.

**Address 100, TADD HIGH**
**Registers SH, AZ** totally confusing role in the English datasheet, eluded in the Japanese datasheet. Recommended default values: SH = 0, AZ = 0.
**Register CL:** Enable the auto-calibration circuit. Is used in conjonction with OB that outputs a line of dark pixels. 0 is active.
**Registers P3-P0** custom convolution kernels. 0x0001 by default.
The registers P3-P0 at this address have exactly the same effect with the M64282FP sensor. SH and AZ does not exist in the M64282FP sensor.

**Address 101, TADD HIGH**
**Registers PX, PY:** projection mode when active (vertical, horizontal, none). Recommended values: PX = 0, PY = 0 (no projection).
**Register MV4:** plus or minus bias for projection mode.
**Register OB:** Enable to output optical black level as a dark pixel line at the top of the image. Is used in conjonction with CL. 0 is active.
**Register M3-M0:** custom convolution kernels. 0x0000 by default.

**Address 110, TADD HIGH**
**Register MV3-MV0:** voltage bias for the projection mode, 16 steps of 8 mV.
**Register X3-X0:** custom convolution kernels. 0x0001 by default.


**Register mapping according to the Japanese Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_address.png)

## The random access mode

**Register setting to trigger random access mode according to the Japanese Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_setting_random_access.png)

## Showcase

**M64282FP sensor (left) and M64283FP sensor (right) on a Game Boy Camera sensor PCB**
![](/Pictures%20and%20datasheets/Sensor_comparison.png)
