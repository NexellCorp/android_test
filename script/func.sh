#!/bin/bash
#
# Copyright (C) 2018  Nexell Co., Ltd.
# Author: Seoji, Kim <seoji@nexell.co.kr>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

wifi_apk()
{
	adb root
	echo Starting WiFi test..
	echo SSID: $SSID
	echo PW:   $PW

	case "$SSID" in
	"")
		echo "SSID is blank!"
		usage
		exit;;
	esac
	case "$PW" in
	"")
		echo "PW is blank!"
		usage
		exit;;
	esac

	unknown_source
	adb install $CURRENT_PATH/../apk/wifitool-debug.apk

	adb shell am broadcast -n ru.yandex.qatools.wifitool/.Connect -e ssid $SSID -e security WPA -e pass $PW -e retry_count 7 -e retry_delay 6
	adb shell "pm uninstall ru.yandex.qatools.wifitool"
	sleep 6

	TEST_NAME=wifi
	test_capture
}

function func_wifi_off()
{
	# wifi setting
	adb shell am start -a android.intent.action.MAIN -n com.android.settings/.wifi.WifiSettings
	# click RND_WiFi_2.4Ghz
	adb shell input tap 984 151
	# erase info of wifi
	adb shell input tap 295 427
	#wifi off
	adb shell input tap 971 108
	# back to home
	adb shell input keyevent "KEYCODE_HOME"
}

function test_webview()
{
	adb root
	echo "Starting Webview test.."

	if [ "$QUICKBOOT" = "true" ]; then
		echo "AVN"
		# install apk - AVN
		adb install $CURRENT_PATH/../apk/Webviewtest.apk
		adb shell monkey -p com.snc.test.webview2 -v 1
		sleep 2
		echo "Do Webview test."
		echo "Press enter if test is done."
		read_enter

	elif [ "$QUICKBOOT" = "false" ]; then
		echo "General"
		# launch webview app - general
		adb shell monkey -p org.chromium.webview_shell -v 1
		adb shell input text "daum.net"
		sleep 2
		# click '>'
		adb shell input tap 940 65
		sleep 3
		# kill webview app
		adb shell am force-stop org.chromium.webview_shell

	fi

	TEST_NAME=webview
	test_capture
	echo "Webview test done.."
}

function test_recorder()
{
	echo "Starting Recorder test.."

	# install apk
	adb install $CURRENT_PATH/../apk/easy_voice_recorder.apk
	# launch app
	adb shell monkey -p com.coffeebeanventures.easyvoicerecorder -v 1
	sleep 1
	# click 'ok'
	adb shell input tap 653 411
	# click 'record'
	adb shell input tap 124 510
	sleep 2
	# click 'done'
	adb shell input tap 360 510

	# click 'record'
	adb shell input tap 124 510
	sleep 10
	# click 'done'
	adb shell input tap 360 510

	echo "Play recording file."
	read_enter

	# click 'play'
	adb shell input tap 890 510
	sleep 10
	# kill app
	adb shell am force-stop com.coffeebeanventures.easyvoicerecorder
	# uninstall app
	adb shell "pm uninstall com.coffeebeanventures.easyvoicerecorder"

	echo "Smart Recorder test done.."
	sleep 1
}

function test_camera()
{
	echo "Starting Camera Preview test.."
	# launch app
	adb shell monkey -p com.android.camera2 -v 1
	sleep 2

	adb shell input tap 710 313
	adb shell input tap 667 321
	sleep 2

	TEST_NAME=camera_preview
	test_capture

	# kill webview app
	adb shell am force-stop com.android.camera2

	echo "Camera Preview test done.."
	sleep 1
}

function test_camera_recording()
{
	echo "Starting Camera Recording test.."
	# launch app
	adb shell monkey -p com.android.camera2 -v 1
	# change mode
	adb shell input swipe 817 368 817 419

	adb shell input tap 88 325
	# recording
	adb shell input tap 946 277
	sleep 10
	# recording done
	adb shell input tap 946 277
	# click album
	adb shell input tap 740 24

	echo "Play recorded video"
	read_enter
	sleep 2

	# play video
	adb shell input tap 507 268
	sleep 5

	TEST_NAME=camera_recording
	test_capture

	echo "Starting Camera recording Aging test.."
	cnt=0
	while [ $cnt -lt 5 ];
	do
		cnt=$(($cnt+1))
		echo "recording $cnt"
		# recording video
		adb shell input tap 507 268
		sleep 5
		adb shell input tap 507 268
		sleep 2
	done

	# kill app
	adb shell am force-stop com.android.camera2

	echo "Camera Preview test done.."
	sleep 1
}

function test_display()
{
	echo "Starting display test.."
	# install apk
	adb install $CURRENT_PATH/../apk/Fps2D_3.1.0.apk
	# launch app
	adb shell monkey -p com.edburnette.fps2d -v 1
	sleep 25

	#TEST_NAME=display
	test_capture

	# kill app
	adb shell am force-stop com.edburnette.fps2d
	# uninstall app
	adb shell "pm uninstall com.edburnette.fps2d"

	echo "display test done.."
	sleep 1
}

function display_twice()
{
	TEST_NAME=display1
	test_display
	echo "Next is display test using HDMI."
	echo "Connect monitor using HDMI cable."
	read_enter
	TEST_NAME=display2
	test_display
}

function test_performance()
{
	echo "Starting Performance test.."

	# unknown sources
	unknown_source

	# install apk
	adb install $CURRENT_PATH/../apk/antutu-benchmark-6-3-4.apk
	# launch app
	adb shell monkey -p com.antutu.ABenchMark -v 1
	sleep 6
	# click install&test
	adb shell input tap 510 200
	TEST_NAME=display2
	# click download
	adb shell input tap 600 363
	# click download
	adb shell input tap 510 200
	# click download
	adb shell input tap 451 362
	sleep 50
	echo "Press enter to install."
	read_enter
	# click install
	adb shell input tap 741 486
	sleep 20
	# click done
	adb shell input tap 682 490
	# test
	adb shell input tap 510 200
	sleep 270
	echo "Do you want screencapture?"
	read_enter
	# click for rotating screen
	adb shell input tap 1007 43
	sleep 1

	TEST_NAME=performance
	test_capture

	# kill app
	adb shell am force-stop com.antutu.ABenchMark
	# uninstall app
	adb shell "pm uninstall com.antutu.ABenchMark"

	# back to home
	adb shell input keyevent "KEYCODE_HOME"

	echo "Performance test done.."
	sleep 1
}

function test_factory_reset()
{
	echo "Starting Factory Reset test.."
	touch command
	echo --wipe_data > command
	adb root
	adb shell mkdir -p /cache/recovery
	adb push command /cache/recovery
	rm command
	adb shell reboot recovery
	echo "Factory Reset test done.."
}

function test_OTA_upgrade()
{
:<<'END'
	#precondition: build dist

	echo "Starting OTA Upgrade Test.."

	cd $CURRENT_PATH/../../../../$DIST_DIRECTORY && touch command && echo --update_package=/cache/ota_update.zip > command
	adb root
	adb shell mkdir -p /cache/recovery
	cd $CURRENT_PATH/../../../../$DIST_DIRECTORY && adb push ota_update.zip /cache
	cd $CURRENT_PATH/../../../../$DIST_DIRECTORY && adb push command /cache/recovery
	adb shell reboot recovery

	echo "OTA Upgrade Test done.."
END
}

function freq_cpu()
{
	touch cur_freq
	touch avail_freq
	adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq > cur_freq
	adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies > avail_freq
	mv $CURRENT_PATH/cur_freq $CURRENT_PATH/../tmp
	mv $CURRENT_PATH/avail_freq $CURRENT_PATH/../tmp
}

function touch_apk()
{
	echo "Starting touch test.."
	# install apk
	adb install $CURRENT_PATH/../apk/Touch_test.apk
	echo "Please launch touch app."
	sleep 10
	echo "If you finish the test, press enter."
	read_enter

	TEST_NAME=touch_screen
	test_capture

	adb shell am force-stop com.spencerstudios.screentest
	echo "touch test done.."
}

function youtube()
{
	adb install $CURRENT_PATH/../apk/YouTube_v13.01.53.apk
}

function 3d_mark()
{
	echo "Starting 3d_mark"
	adb install $CURRENT_PATH/../apk/3DMark_v2.0.4574.apk
	adb shell monkey -p com.futuremark.dmandroid.application -v 1
	sleep 5
	adb shell input tap 530 544
	adb shell input tap 530 544
	sleep 2
	adb shell input tap 537 338
	adb shell input tap 246 111
	adb shell input tap 558 687
	echo "To start the test, press enter."
	read_enter
	adb shell input tap 558 687
	echo "Press enter if test is done."
	read_enter

	TEST_NAME=3d_mark
	test_capture

	adb shell "pm uninstall com.futuremark.dmandroid.application"
	echo "3d_mark done.."
	dis_rotation
}

function video_antutu()
{
	echo "Starting Antutu video.."
	# push media file
	adb push * /storage/emulated/0
	adb install $CURRENT_PATH/../apk/antutu-video-tester.apk
	adb shell monkey -p com.antutu.videobench -v 1
	sleep 3
	adb shell input tap 361 178
	sleep 3
	adb shell input tap 655 348

	echo "Is Antutu video test done?"
	read_enter

	TEST_NAME=video_antutu
	test_capture

	adb shell input tap 230 325
	sleep 1
	TEST_NAME=video_antutu_full1
	test_capture

	adb shell input swipe 817 419 817 368
	sleep 1
	TEST_NAME=video_antutu_full2
	test_capture

	adb shell input swipe 731 419 485 419
	sleep 1
	TEST_NAME=video_antutu_partial
	test_capture

	adb shell input swipe 731 419 485 419
	sleep 1
	TEST_NAME=video_antutu_not_support1
	test_capture

	adb shell input swipe 741 452 741 181
	sleep 1
	TEST_NAME=video_antutu_not_support2
	test_capture

	#read_enter
	adb shell "pm uninstall com.antutu.videobench"
	dis_rotation
	echo "Antutu video done.."
}

function a1_sd()
{
	echo "Starting a1_sd.."
	adb install $CURRENT_PATH/../apk/A1_SD_v2.6.1.apk
	adb shell monkey -p com.a1dev.sdbench -v 1
	adb shell input tap 600 210
	read_enter
	# kill app
	adb shell am force-stop com.a1dev.sdbench
	adb shell monkey -p com.a1dev.sdbench -v 1

	adb shell input tap 600 356
	read_enter
	adb shell input tap 600 488

	sleep 15
	read_enter
	TEST_NAME=a1_sd
	test_capture

	adb shell "pm uninstall com.a1dev.sdbench"

	echo "a1_sd done.."
}

function stability()
{
	echo "Starting stability.."
	adb install $CURRENT_PATH/../apk/stability_2.7.apk
	adb shell monkey -p com.into.stability -v 1
	adb shell input tap 507 798

	adb shell input tap 280 180
	read_enter
	TEST_NAME=stability
	test_capture

	adb shell "pm uninstall com.into.stability"

	# back to home
	adb shell input keyevent "KEYCODE_HOME"
	dis_rotation
	echo "Stability done.."
}

function game()
{
	echo "Starting game.."
	adb install $CURRENT_PATH/../apk/Asphalt_8_Airborne_3.5.apk
	adb shell monkey -p com.gameloft.android.ANMP.GloftA8HM -v 1
	sleep 5
	# ok
	adb shell input tap 743 332
	sleep 1
	# ok
	adb shell input tap 740 310
	sleep 13
	# download
	adb shell input tap 257 568
	echo "Press enter if download is done."
	read_enter

	adb shell input tap 520 254
	adb shell input text "26"
	adb shell input tap 866 397
	adb shell input tap 630 348
	adb shell input tap 507 554
	sleep 2
	# x
	adb shell input tap 997 54
	sleep 2
	# x
	adb shell input tap 997 54
	sleep 2
	# play
	adb shell input tap 842 502
	sleep 1
	# tutorial no
	adb shell input tap 317 450
	sleep 1
	# career
	adb shell input tap 878 183
	sleep 1
	# game
	adb shell input tap 190 230
	sleep 1
	# next
	adb shell input tap 888 565
	sleep 1
	# next
	adb shell input tap 888 565
	sleep 3
	# start race
	adb shell input tap 888 565

	sleep 15
	echo "Press enter if test is done."
	read_enter
	TEST_NAME=asphalt8
	test_capture

	adb shell "pm uninstall com.gameloft.android.ANMP.GloftA8HM"
	echo "game done.."
}

function wifi_analyze()
{
	echo "Starting wifi_analyze.."
	adb install $CURRENT_PATH/../apk/Wifi_Network_Analyzer.apk
	adb shell monkey -p com.pzolee.wifiinfo -v 1
	sleep 2
	adb shell input tap 431 647
	adb shell input tap 503 950

	sleep 3
	TEST_NAME=wifi_analyze
	test_capture

	adb shell "pm uninstall com.pzolee.wifiinfo"
	echo "wifi_analyze done.."
	dis_rotation
}

function cpu_z()
{
	echo "Starting cpu_z.."
	adb install $CURRENT_PATH/../apk/CPU_Z_v2.2.apk
	adb shell monkey -p com.yukioobarkh.cupz -v 1

	sleep 4

	TEST_NAME=cpu_z_cpu
	test_capture

	adb shell input swipe 785 390 455 390
	sleep 1
	TEST_NAME=cpu_z_device
	test_capture

	adb shell input swipe 785 390 455 390
	sleep 1
	TEST_NAME=cpu_z_system
	test_capture

	adb shell input swipe 785 390 455 390
	sleep 1
	TEST_NAME=cpu_z_betery
	test_capture

	adb shell input swipe 785 390 455 390
	sleep 1
	TEST_NAME=cpu_z_sensor
	test_capture

	adb shell "pm uninstall com.yukioobarkh.cupz"
	echo "cpu_z done.."
}

function mxplayer()
{
	echo "Starting mxplayer.."
	adb install $CURRENT_PATH/../apk/MX_Player_v1.9.16.apk
	adb shell monkey -p com.mxtech.videoplayer.ad -v 1
	sleep 2
	adb shell input tap 738 318
	adb shell input tap 743 397

	echo "If you finish test with mxplayer"
	read_enter
	adb shell am force-stop com.mxtech.videoplayer.ad

	echo "mxplayer stopped"
}

function multi_cap()
{
	echo "Starting multi capture test.."
	# launch app
	adb shell monkey -p com.android.camera2 -v 1
	sleep 2

	adb shell input tap 710 313
	adb shell input tap 667 321

	echo "capture 5 times! move camera!"
	read_enter

	cnt=0
	while [ $cnt -lt 5 ];
	do
		cnt=$(($cnt+1))
		echo "capture $cnt"
		# take a photo
		adb shell input tap 946 277
		TEST_NAME=multi_cap$cnt
		test_capture
		sleep 1
	done
	sleep 2

	# kill app
	adb shell am force-stop com.android.camera2

	echo "multi capture done.."
	sleep 1
}

function memtest()
{
	echo "Starting memory test.."
	echo "q: 32bit, w: 64bit"
	read input

	case "$input" in
	q)
		echo "push 32bit memtester.."
		adb root
		adb push $CURRENT_PATH/../bin/memtester32 /system/bin
		adb shell /system/bin/memtester32 10m 10;;
	w)
		echo "push 64bit memtester.."
		adb root
		adb push $CURRENT_PATH/../bin/memtester64 /system/bin
		adb shell /system/bin/memtester64 10m 10;;
	esac
}

function carlife()
{
	echo "Starting Carlife test.."
	adb install $CURRENT_PATH/../apk/carlife_sign.apk
	#adb shell monkey -p  -v 1
	sleep 2
}


##### setting function #####

function unknown_source()
{
	# unknown sources
	adb shell settings put secure install_non_market_apps 1
}

function developer_option()
{
	# 1
	adb shell am start -S com.android.settings/.Settings\$DevelopmentSettingsActivity

	# 2
	#adb shell settings put global development_settings_enabled 1
}

function dis_rotation()
{
	# 1. disable auto-rotate
	adb shell settings put system accelerometer_rotation 0
	# set user_rotation
	# 0 potrait 1 landscape
	adb shell settings put system user_rotation 0
}

function read_enter()
{
	echo "Enter: continue, q: quit"
	read input

	if [ "$input" = "\n" ]; then
		echo "continue.."
	elif [ "$input" = "q" ]; then
		echo "Quit the test.."
		exit
	fi
}

function stay_awake()
{
	adb root
	adb shell settings put global stay_on_while_plugged_in 3
}

function test_capture()
{
	# screen capture
	adb shell screencap -p /storage/emulated/0/DCIM/Camera/${TEST_NAME}.png
	# send file to pc
	adb pull /storage/emulated/0/DCIM/Camera/${TEST_NAME}.png $CURRENT_PATH/../tmp
}

function print_arg()
{
	echo "TEST_NAME: $TEST_NAME"
	echo "SSID: $SSID"
	echo "PW: $PW"
	echo "DIST_DIRECTORY: $DIST_DIRECTORY"
	echo "SETTING: $SETTING"
	echo "QUICKBOOT: $QUICKBOOT"
}
