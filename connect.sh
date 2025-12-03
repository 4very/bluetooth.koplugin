#!/bin/bash

timeout 5s bluetoothctl connect E4:17:D8:7D:3D:69
# timeout 5s bluetoothctl connect 72:31:20:98:0B:8D

bluetoothctl info | grep Name
	Name: 8BitDo Micro gamepad

