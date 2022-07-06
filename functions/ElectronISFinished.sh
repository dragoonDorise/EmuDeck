#!/bin/bash
finished=false
while [ $finished == false ]
do 		 
	test=$(test -f ~/emudeck/.electron-finished && echo true)	
	  if [ $test == true ]; then
	  	  finished=true;
		clear	
		  echo 'true';
		break
	  fi							  
done