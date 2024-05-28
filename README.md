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

**Register mapping according to the Japanese Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_address.png)

## The random access mode

**Register setting to trigger random access mode according to the Japanese Datasheet of the M64283FP sensor**
![](/Pictures%20and%20datasheets/Registers_setting_random_access.png)

## Showcase

**M64282FP sensor (left) and M64283FP sensor (right) on a Game Boy Camera sensor PCB**
![](/Pictures%20and%20datasheets/Sensor_comparison.png)
