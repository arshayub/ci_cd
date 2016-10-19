#!/bin/bash

#This script is used to calculate the time difference between the PPS signals generated by 
#network switch and the timing receivers

#Sourcing the configuration file available in the current working directory
source ./saftppsconfig.sh

#Erasing lines from the log file that are not required for time difference calculation
#Erasing all the lines from the log file having Falling as a string. Time difference
#is calculated for all the rising edges of the clock and hence falling edge data is not required
sed '/Falling/d' $exp_IO1_log > $expIOtemp1

#Erasing lines from the log data having Edge and -- in it
sed '/Edge/d' $expIOtemp1 > $expIOtemp2
sed '/--/d' $expIOtemp2 > $exp_IO1_log

#Deleting the temporary files
rm $expIOtemp1 $expIOtemp2

#Storing the values of IO ports to an array variable
port=( $(awk '{print $1}' $exp_IO1_log) )

#Storing the hexadecimal values of PPS time to an array variable
var=( $(awk '{print $6}' $exp_IO1_log) )

#variable n defines the length of the array "var"
n=${#var[@]}
#Initial value for variables
i=0
k=0
j=0

#Calculating time difference between network switch and timing receivers
# Both Pexarria and SCU3 should refer to the PPS time stamp value from network switch
#Therefore, the difference is calculated between Pexarria (IO2) and network switch (IO1) and
#SCU3 (IO3) and network switch (IO1) 

#Conditional check. Stay inside the loop until variable 'i' is less than array length
while [[ $i -lt $n ]]
do

#Calculating the difference in time between network switch and Pexarria
	if [ "${port[i]}" == "IO2" ] && [ "${port[i+1]}" == "IO1" ] ; then
		difference=$(( ${var[i+1]} - ${var[i]}))
#Converting the hexadecimal value to decimal value
		num=$((10#$difference))
#Appending the value to an array
		newnum+=( $num )
        	echo "${var[i+1]} ${port[i+1]} ---- ${var[i]} ${port[i]} Diff= $num ns Switch vs pex"
		echo
	fi

	if [ "${port[i]}" == "IO2" ] && [ "${port[i+2]}" == "IO1" ] && [ "${port[i+1]}" != "IO1" ]; then
                difference=$(( ${var[i+2]} - ${var[i]}))
                num=$((10#$difference))
#Appending the value to an array
		newnum+=( $num )
                echo "${var[i+2]} ${port[i+2]} ---- ${var[i]} ${port[i]} Diff= $num ns Switch vs pex"
                echo
        fi

#Calculating the difference in time between network switch and SCU3
	if [ "${port[i]}" == "IO3" ] && [ "${port[i+1]}" == "IO1" ] ; then
                difference=$(( ${var[i+1]} - ${var[i]}))
#Converting the hexadecimal value to decimal value
                num=$((10#$difference))
#Appending the value to an array
		newnum+=( $num )
                echo "${var[i+1]} ${port[i+1]} ---- ${var[i]} ${port[i]} Diff= $num ns Switch vs scu"
                echo
        fi

        if [ "${port[i]}" == "IO3" ] && [ "${port[i+2]}" == "IO1" ] && [ "${port[i+1]}" != "IO1" ]; then
                difference=$(( ${var[i+2]} - ${var[i]}))
                num=$((10#$difference))
#Appending the value to an array
                newnum+=( $num )
                echo "${var[i+2]} ${port[i+2]} ---- ${var[i]} ${port[i]} Diff= $num ns Switch vs scu"
                echo
        fi

#Increment count value to check all the values from the log file
	let i++
done

for k in "${newnum[@]}"
do
    if [ "$k" -ge "200" ] ; then
        let j++
    fi
done

if [ "$j" != "0" ]; then
echo "PPS test result: Time difference between switch and timing receiver greater than 200 ns exists" | mail -s “pps_test_delay_error” a.suresh@gsi.de
fi

#Remove the log file after all the operation is complete
rm $exp_IO1_log
