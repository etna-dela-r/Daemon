#!/bin/bash

function Load_gif
{
    pid=$!

    while [ -d /proc/${pid} ];
    do
	echo -ne "\r|"
	sleep 0.2
	echo -ne "\r/"
	sleep 0.2
	echo -ne "\r-"
	sleep 0.2
	echo -ne "\r\\"
	sleep 0.2
    done
    echo -ne "\r";
}
