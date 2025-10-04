#!/bin/bash

num=0

while ((num<=10 ))
do 
	if((num%2 ==0))
	then
		echo "The number is Even$num"
	fi
	num=$((num+1))

done

