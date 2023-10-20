# home-assistant-docker-armv7

The last working offical docker image for armv7 appears to be 2022.6.7.  Since this version no offical builds will start up properly on my armv7 powered QNAP NAS.  This dockerfile builds an image with a recent version of HA that will start up properly on my hardware.  The dockerfile is based on the work of magicse found in this [issue](https://github.com/home-assistant/core/issues/86589) as well as the offical HA and linuxserver.io docker files.  
