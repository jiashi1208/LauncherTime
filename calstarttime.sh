#!/bin/sh
#sh calstarttime.sh bd60 20 tfile.csv

function gettime()
{
	infile=$1
	line=$2

	tmp=`sed -n "${line} p" ${infile} | awk '{print $2}' | awk -F ":" '{ printf( "%02d:%02d:%06.3f", $1, $2, $3 ) }'`
	echo "${tmp}"
}

function mytime()
{
	echo $1 | sed 's/\./:/g' | awk -F ":" '{print (($1*60+$2)*60+$3)*1000+$4 }'
}

function proc()
{
	strec=$1
	num=$2
	code=0
	tfile=$3
	device=$4
	
	for i in `seq 1 ${num}`; do
		code=$(($code+1))
		logfile="time_${code}.txt"
		

		for pid in `adb -s $device shell ps | grep BaiduMap | awk '{print $2}'`; do
			echo "pid: ${pid}"
			adb -s $device shell su -c "kill -9 ${pid}"
		done

		adb -s $device logcat -c
		#adb -s $device shell /data/local/recrep rep ${strec} 1
		adb -s $device shell uiautomator runtest BaiduMapUIATest.jar -e device huaweiu9508 -c com.baidu.BaiduMap.testCases.Test#test_1
		
		echo "start analysis log"
	
		adb -s $device logcat -d -v time ActivityManager:I *:S | grep -i baidumap > $logfile

		stline=`sed -n "/START.*WelcomeScreen/ =" $logfile`
		endline=`sed -n "/Displayed.*MapsActivity:/ =" $logfile`

		sttime=`gettime $logfile ${stline}`

		endtime=`gettime $logfile ${endline}`

		echo "${sttime},${endtime}"
		
		st=`mytime ${sttime}`
		et=`mytime ${endtime}`
		t=$[ $et - $st ]

		echo "${sttime},${endtime},${t}"
		#echo "${i},${sttime},${endtime},${t}" >> ${ofile}
		echo "${t}" >> ${tfile}
	
		rm $logfile
		sleep 3
	done	
	
}

proc $1 $2 $3 $4

