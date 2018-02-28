1. Introduction

This is Nexell Android BSP Auto Testsuite.
You can check available test and setting options on Usage.txt.
If you run script using 'all' option, test result will be stored on result directory.
Otherwise, test result will be stored on tmp directory.


2. Precondition

- dist build
To run OTA Upgrade test, dist built result is needed.

3. Run test

- Connect target device and pc using USB cable
The script run test using adb. So before run the script, connect target device and pc using USB cable.

- Run test.sh
Run script using proper option according to Usage.txt.
There are also some example running script on Usage.txt.


4. Test item information

- 'all'
The test include all available test. It also include webview test.
Because of webview test including both script for General and AVN,
you should select one of them by using '-q' argument.
Otherwise, it test for General mode in basically.
It is running automatically but you should check status of test once in a while.
You might have to press enter or do other action to go to next step.

- wifi
Using passed ssid and password, the test try to connect wifi.

- webview
The test access daum.net with a network connection.
It include both script for General and AVN.
You can select one both of them by running script with '-q' argument.
Otherwise, it test for General mode in basically.

- recorder
The test install recorder app and record voice.

- camera
The test launch camera app and check preview screen.

- camrera_rec
The test launch camera app and record video.
This also include Recording Aging test.

- display
The test install Fps2D app and run.
This run display test twice. First run with primary screen and second using HDMI cable.

- performance
The test install Antutu benchmark and run.

- fac_reset
The test run factory reset.

- ota
The test run OTA upgrade. Be careful that dist built is needed.
Dist built directory name is needed when running OTA upgrade test.

- cpu_freq
The test check current frequency and available frequencies.

- antutu_video
The test install Antutu video and run.

- 3d_mark
The test install 3D Mark and run.

- al_sd
The test install A1 SD and run.

- stability
The test install Stability and run.

- game
The test install Asphalt8 game and run.

- touch
The test install touch app. You should run and check it yourself.

- wifi_analyze
The test install Wifi analyze app and run.

- cpu_z
The test install CPU_Z and run.

- mxplayer
The test install and launch Mxplayer. You should test playing video yourself.

- memtest
The test install memtest binary to target board and run.
You should choose between 32bit and 64bit.

- youtube
The test install youtube app.
