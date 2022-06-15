#!/bin/bash
RAautoSave(){
	if [ $RAautoSave == true ]; then
		sed -i 's|savestate_auto_load = "false"|savestate_auto_load = "true"|g' $raConfigFile 
		sed -i 's|savestate_auto_save = "false"|savestate_auto_save = "true"|g' $raConfigFile 
	else
		sed -i 's|savestate_auto_load = "true"|savestate_auto_load = "false"|g' $raConfigFile 
		sed -i 's|savestate_auto_save = "true"|savestate_auto_save = "false"|g' $raConfigFile 
	fi	
}
