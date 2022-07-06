#!/bin/bash
finished=false
echo "" > ~/emudeck/check.log
while [ $finished == false ]
do 		 
	test=$(test -f ~/emudeck/.electron-finished && echo true)	
	echo $test >> ~/emudeck/check.log
	  if [[ $test == true ]]; then
	  	  finished=true;
		  clear	
		  echo 'true';
		  rm ~/emudeck/.electron-finished
		break
	  fi							  
done