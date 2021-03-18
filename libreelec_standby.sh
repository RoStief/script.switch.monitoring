#!/bin/bash

listening=0

function trace_script {
	msg=$1
	echo $msg
}

function stop_listen_cec {
	pkill -f cec-client
}

function  airmouse_event {
	line=$1
	echo $line

	if echo $line|grep -q "KEY_SLEEP (142) pressed"; then
        #if echo $line|grep -q ",value "; then
            echo "Starting Kodi - $(date)"

            stop_listen_cec
            # after input: start kodi
            systemctl start kodi &

	    echo "Kodi was Started - $(date)"

	    listening=0
            pkill -f libinput
        fi
}

function listen_cec {
       #just listen to CEC Events to ensure no switch from TV is done
	cec-client > /dev/null 2>&1 &
}

function read_remote_input {
     /storage/.kodi/addons/virtual.system-tools/bin/evtest --grab "$device">&1 | while read line; do
     #/bin/libinput debug-events --device $device>&1 | while read line; do
	 echo "$line"
         airmouse_event "$line"
         if [ $listening == 0 ]; then
             break
         fi
     done
}

trace_script "Waiting for Startup - $(date)"
# first wait for input
device='/dev/input/by-id/usb-SAGE_SAGE_AirMouse-event-if02'
while  [ 1 ]; do
    kodiRunning="$(systemctl is-active kodi.service)"
    if [ "${kodiRunning}" = "inactive" ]; then
	trace_script "Kodi not Running - Waiting for Input"
	listening=1

	listen_cec
	#kodi is not running - start listening
	read_remote_input
        
	trace_script "Airmouse Listening done."
    else
	trace_script "Waiting for Kodi to finish..."
        while [ "${kodiRunning}" != "inactive" ];
	do
                kodiRunning="$(systemctl is-active kodi.service)"
		sleep 0.5;
	done
           trace_script "Kodi has Stopped"
    fi
    # test for termination
    test $? -gt 128 && break
done
trace_script "Standbyscript finished - $(date)" 
