#!/bin/bash


read -p "Enter the jetha ki bandi :" bandi 
read -p "jethalal ka pyaar %" pyaar


if [[ $bandi == "daya bhabhi" ]];
then
	echo "Jetha is  Loyal"
elif [[ $pyaar -ge 100 ]];
then
	echo "Jetha is loyal"
else
	echo "jetha is not loyal"

fi
