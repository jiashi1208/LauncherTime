#!/bin/sh
#sh looptesttime.sh bd62 20 3 


function proc()
{
	strec=$1
	num=$2
	loop=$3
	device=$4
	
	code=0
	tfile="time.csv"
	can1=3
	can2=0.7
	exe="C:/bin/dataproc.exe"

	for i in `seq 1 ${loop}`; do
		code=$(($code+1))
		outfile="time_${code}.csv"
		sh calstarttime.sh $strec $num $tfile $device
		sleep 3

		echo " one group OK"
		
    echo "start proc start time data group"
    
		$exe $tfile ${outfile} $can1 $can2
		
		echo "ok finish proc start time data"
		
		tmp=`tail -1 ${outfile}`
		
		echo "avr:${tmp}"
		rm $tfile

	done
	
}

proc $1 $2 $3 $4

