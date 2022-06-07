#!/bin/bash
migrateAndLinkConfig(){

emu=$1
migrationTable=$2
#step 1 should be attempt to unlink everything that gets passed in so we can start fresh.
#for path in $migrationTable[@]
#do
#    if [ -L $path ]; then
#        echo unlinking $path
#        unlink $path
#    fi
#done
migrationFlag="$HOME/emudeck/.${emu}MigrationCompleted"

#check if we have a nomigrateflag for $emu
if [ ! -f "$migrationFlag" ]; then
    #ask user before migrating data
    text="`printf "We would like to migrate data from the flatpak to the AppImage for ${emu}. \nNew directories for this emulator will be made, and config changes will point to these folders regardless of this choice.."`"
    doMigrate=$(zenity --info --title "Migrate "${emu}" Data?" \
        --text="${text}" \
        --width=300 \
        --ok-label "Leave ${emu} alone this time" \
        --extra-button "Leave ${emu} alone forever" \
        --extra-button "Migrate Data" 2>/dev/null)
    rc=$?
    echo "$emu Do migration? User chose: $doMigrate"
    if [ "$doMigrate" == "Migrate Data" ]; then
        n=$(( ${#migrationTable[@]} - 1 ))
        #odd should be flatpak
        #even should be appimage
        #determine plan based on first pair
        if [[ ! -e ${migrationTable[0]} ]]; then
        #no flatpak data. nothing to do. (or should we link it?)
        echo "No flatpak data found, continuing."
        elif [[ -d ${migrationTable[0]} && -d ${migrationTable[1]} ]]; then
            #both locations exist
            #ask user which to keep
            text="`printf "Data was found for both the appimage and flatpak for ${emu}.\nWe will be using the AppImage from now on.\nPlease choose which data to keep."`"
            ans=$(zenity --info --title "Migrate "${emu}" Data?" \
            --text="${text}" \
            --width=300 \
            --ok-label "Don't do anything with my stuff" \
            --extra-button "Keep AppImage Data" \
            --extra-button "Migrate Flatpak Data" 2>/dev/null)
            rc=$?
            if [[ ! $ans == "" ]]; then #user didn't cancel
                echo "$emu flatpak/appimage data choice. User Chose: $ans"
                for ((i=0; i<=n; i=(i+2))) { # for each pair of dirs

                    if [[ $ans == "Migrate Flatpak Data" ]]; then
                        fromDir=${migrationTable[i]}
                        toDir=${migrationTable[i+1]}
                        echo  "Migrating ${fromDir} to ${toDir}"
                        unlink 
                        #backup destination location, delete it, then sync original over
                        mv "$toDir" "$toDir.orig" && mkdir -p $toDir && rsync -av "${fromDir}/" "${toDir}"
                        cd ${fromDir}
                        cd ..
                        #backup and remove original
                        mv "${fromDir}" "${fromDir}.orig" && rm -rf "${fromDir}"

                        #link .config to .var so flatpak still works
                        ln -sfn ${toDir} .

                    elif [[ $ans == "Keep AppImage Data" ]]; then
                        fromDir=${migrationTable[i+1]}
                        toDir=${migrationTable[i]}
                        cd ${toDir}
                        cd ..
                        #backup flatpak data
                        mv "${toDir}" "${toDir}.orig"
                        #link appimage data to flatpak folder
                        ln -sfn "${fromDir}" .

                    else
                        echo "Something went wrong"
                        exit
                    fi

                }
            else
                echo "User doesn't want migration at this time."
            fi

        elif [[ -L ${migrationTable[0]} && -d ${migrationTable[0]} && -d ${migrationTable[1]} ]]; then
            echo "Flatpak already linked"
        elif [[ -d ${migrationTable[0]} && ! -e ${migrationTable[1]} ]]; then
            echo "No AppImage data found, but flatpak data found. New AppImage install."
            for ((i=0; i<=n; i=(i+2))) { # for each pair of dirs


                    fromDir=${migrationTable[i]}
                    toDir=${migrationTable[i+1]}
                    echo  "Migrating ${fromDir} to ${toDir}"
                    cd ${fromDir}/..
                    #backup destination location, delete it, then sync original over
                    mkdir -p ${toDir} && rmdir ${toDir} #make the path for todir, but remove the end folder
                    mv "${fromDir}" "${toDir}" #move the original to the new location
                    #link .config to .var so flatpak still works
                    ln -sfn ${toDir} .

            }
        else
            echo "do nothing"
        fi
        touch $migrationFlag
    elif [ $doMigrate == "Leave ${emu} alone forever" ]; then
        touch $migrationFlag
    fi
fi

}