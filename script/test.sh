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
#
#
# This program is for auto BSP manual test.
# If more information is needed, read README.txt file.
#
# Precondition
# - build dist. it is needed to launch ota test.
#

set -e
source func.sh
CURRENT_PATH=`pwd`
QUICKBOOT=false

function usage()
{
	echo -e "\nThis is Nexell Android BSP Auto Testsuite.\n"
	echo -e "Usage: ./test.sh [-t <test name>] [-i <wifi ssid> -p <pw>] [-d <dist result directory name>] [-q <true> (for AVN)] [-o <setting option>]\n"
	echo "- Available test name: wifi, webview, recorder, camera, camera_rec, display, performance, fac_reset, ota, cpu_freq, antutu_video, 3d_mark, a1_sd, stability, game, multi_cap, touch, wifi_analyze, cpu_z, mxplayer, memtest, youtube"
	echo -e "- Available settings option: awake, dis_rotation\n"
	echo -e "Test 'all' include all component of test list except OTA test."
	echo -e "You need to run OTA upgrade test after test 'all' done.\n"
	echo -e "Test 'webview' run test script for General in basically."
	echo -e "For test in AVN, use -q option.\n"

	echo "Ex) $0 -t wifi -i RND_WiFi_2.4Ghz -p nexellrnd"
	echo "$0 -t webview -i RND_WiFi_2.4Ghz -p nexellrnd"
	echo "$0 -t webview -i RND_WiFi_2.4Ghz -p nexellrnd -q true"
	echo "$0 -t ota -s s5p6818 -d result-s5p4418-avn_ref-dist"
	echo -e "$0 -t all -i RND_WiFi_2.4Ghz -p nexellrnd -o dis_rotation"
	echo -e "$0 -t all -i RND_WiFi_2.4Ghz -p nexellrnd -o dis_rotation -q true"
	echo -e "$0 -o awake\n"
}

function parse()
{
	while getopts "t:i:p:a:d:s:o:q:l" opt;
	do
		case $opt in
			t) TEST_NAME=$OPTARG;;
			i) SSID=$OPTARG;;
			p) PW=$OPTARG;;
			d) DIST_DIRECTORY=$OPTARG;;
			o) SETTING=$OPTARG;;
			q) QUICKBOOT=true;;
		esac
	done

	shift $((OPTIND - 1))

	export SSID PW SOURCE BUILT_DIRECTORY TEST_NAME SETTING DIST_DIRECTORY QUICKBOOT
}

function test_func()
{
	parse $@

	#echo "TEST_NAME: $TEST_NAME"
	#echo "SETTING: $SETTING"
	#echo "SSID: $SSID, PASS: $PW"

	case "$1" in
		"")
			usage
			exit;;
		help)
			usage
			exit;;
	esac

	case "$SETTING" in
		awake)
			stay_awake;;

		dis_rotation)
			dis_rotation;;
	esac

	case "$TEST_NAME" in

		wifi)
			wifi_apk;;

		webview)
			echo "QUICKBOOT: $QUICKBOOT"
			wifi_apk
			test_webview;;

		recorder)
			test_recorder;;

		camera)
			test_camera;;

		camera_rec)
			test_camera_recording;;

		display)
			display_twice;;

		performance)
			dis_rotation
			wifi_apk
			test_performance;;

		fac_reset)
			test_factory_reset;;

		ota)
			echo "DIST_DIRECTORY: $DIST_DIRECTORY"

			test_OTA_upgrade;;

		cpu_freq)
			freq_cpu;;

		touch)
			touch_apk;;

		youtube)
			youtube;;

		antutu_video)
			video_antutu;;

		3d_mark)
			3d_mark;;

		a1_sd)
			a1_sd;;

		stability)
			stability;;

		game)
			game;;

		cpu_z)
			cpu_z;;

		wifi_analyze)
			wifi_analyze;;

		mxplayer)
			mxplayer;;

		multi_cap)
			multi_cap;;

		memtest)
			memtest;;

		carlife)
			carlife;;

		all)
			print_arg
			adb root
			stay_awake
			dis_rotation

			# need to launch camera app first to create directory.
			test_camera
			multi_cap
			test_camera_recording
			wifi_apk
			sleep 3
			wifi_apk
			sleep 2
			touch_apk
			mxplayer
			youtube
			test_webview
			wifi_analyze
			test_recorder
			display_twice
			test_performance
			video_antutu
			3d_mark
			a1_sd
			stability
			game
			cpu_z
			freq_cpu
			memtest

			# create result direcry
			DIREC=$CURRENT_PATH/../result/$(date +"%m-%d-%Y_%T")
			mkdir $DIREC
			mv $CURRENT_PATH/../tmp/* $DIREC

			echo "Next is Factory reset test."
			echo "After reset, you should run OTA upgrade test!!"
			read_enter
			test_factory_reset;;

		*)
		if [ "$SETTING" != "" ]; then
			exit
		fi

		usage
		exit;;
	esac
}

test_func $@
