#!/bin/bash
checkForFile(){
	file=$1
	delete=$2
	finished=false	
	while [ $finished == false ]
	do 		 
		test=$(test -f $file && echo true)			
	  	if [[ $test == true ]]; then
	  	  	finished=true;
		  	clear			  	
			if [[ $delete == 'delete' ]]; then  
		  		rm ~/emudeck/.electron-finished
			fi
			echo 'true';			
			break
	  	fi							  
	done
}