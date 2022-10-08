#!/bin/bash

rclone_path="$toolsPath/rclone"
rclone_bin="$rclone_path/rclone"
rclone_config="$rclone_path/rclone.conf"

rclone_install(){	

    mkdir -p "$rclone_path"/tmp
    curl -L "$(getReleaseURLGH "rclone/rclone" "linux-amd64.zip")" --output "$rclone_path/tmp/rclone.temp" && mv "$rclone_path/tmp/rclone.temp" "$rclone_path/tmp/rclone.zip"

    unzip -o "$rclone_path/tmp/rclone.zip" -d "$rclone_path/tmp/" && rm "$rclone_path/tmp/rclone.zip"
    mv "$rclone_path"/tmp/* "$rclone_path/tmp/rclone" #don't quote the *
    mv  "$rclone_path/tmp/rclone/rclone" "$rclone_bin"
    rm -rf "$rclone_path/tmp"
    chmod +x "$rclone_bin"

    cp "$EMUDECKGIT/configs/rclone/rclone.conf" "$rclone_config"

    rclone_createJob
}

rclone_pickProvider(){

    cloudProviders=()
    cloudProviders+=(1 "Emudeck-GDrive")
    cloudProviders+=(2 "Emudeck-DropBox")
    cloudProviders+=(3 "Emudeck-OneDrive")
    cloudProviders+=(4 "Emudeck-Box")
    #cloudProviders+=(5 "Emudeck-NextCloud")

    rclone_provider=$(zenity --list \
        --title="EmuDeck SaveSync Host" \
        --height=500 \
        --width=500 \
        --ok-label="OK" \
        --cancel-label="Exit" \
        --text="Choose the service you would like to use to host your cloud saves.\n\nKeep in mind they can take a fair amount of space.\n\nThis will open a browser window for you to sign into your chosen cloud provider." \
        --radiolist \
        --column="Select" \
        --column="Provider" \
        "${cloudProviders[@]}" 2>/dev/null)
    if [[ -n "$rclone_provider" ]]; then
        setSetting rclone_provider "$rclone_provider"
        return 0
    else
        return 1
    fi
}

rclone_updateProvider(){
    $rclone_bin config update "$rclone_provider"
}

rclone_setup(){

    while true; do
        if [ ! -e "$rclone_bin" ] || [ ! -e "$toolsPath/rclone/run_rclone_job.sh" ];  then
            ans=$(zenity --info --title 'Rclone Setup!' \
                        --text 'Backup to cloud' \
                        --width=50 \
                        --ok-label Exit \
                        --extra-button "Install rclone" 2>/dev/null  )
        elif [ -z "$rclone_provider" ]; then
            ans=$(zenity --info --title 'Rclone Setup!' \
                        --text 'Backup to cloud' \
                        --width=50 \
                        --ok-label Exit \
                        --extra-button "Reinstall rclone" \
                        --extra-button "Pick Provider" 2>/dev/null  )
        else
            ans=$(zenity --info --title 'Rclone Setup!' \
                --text 'Backup to cloud' \
                --width=50 \
                --ok-label Exit \
                --extra-button "Reinstall rclone" \
                --extra-button "Pick Provider" \
                --extra-button "Login" \
                --extra-button "Run Backup" 2>/dev/null ) 
        fi
        rc=$?
        if [ "$rc" == 0 ]; then
            break
        elif [ "$ans" == "" ]; then
            break
        elif [ "$ans" == "Install rclone" ] || [ "$ans" == "Reinstall rclone" ]; then
            rclone_install
        elif [ "$ans" == "Pick Provider" ]; then
            rclone_pickProvider
        elif [ "$ans" == "Login" ]; then
            rclone_updateProvider
        elif [ "$ans" == "Run Backup" ]; then
            "$toolsPath/rclone/run_rclone_job.sh"
        fi
    done

}

rclone_runcopy(){
    $rclone_bin copy -L "$savesPath" "$rclone_provider":Emudeck/saves -P
}

rclone_createJob(){
echo '#!/bin/bash'>"$toolsPath/rclone/run_rclone_job.sh"
echo "source \$HOME/emudeck/settings.sh
PIDFILE=\"\$toolsPath/rclone/rclone.pid\"

function finish {
  echo \"Script terminating. Exit code \$?\"
}
trap finish EXIT

if [ -z \"\$savesPath\" ] || [ -z \"\$rclone_provider\" ]; then
    echo \"You need to setup your cloudprovider first.\"
    exit
fi

if [ -f \"\$PIDFILE\" ]; then
  PID=\$(cat \"\$PIDFILE\")
  ps -p \"\$PID\" > /dev/null 2>&1
  if [ \$? -eq 0 ]; then
    echo \"Process already running\"
    exit 1
  else
    ## Process not found assume not running
    echo \$\$ > \"\$PIDFILE\"
    if [ \$? -ne 0 ]; then
      echo \"Could not create PID file\"
      exit 1
    fi
  fi
else
  echo \$\$ > \"\$PIDFILE\"
  if [ \$? -ne 0 ]; then
    echo \"Could not create PID file\"
    exit 1
  fi
fi

\"\$toolsPath/rclone/rclone\" copy -L \"\$savesPath\" \"\$rclone_provider\":Emudeck/saves -P > \"\$toolsPath/rclone/rclone_job.log\"

">>"$toolsPath/rclone/run_rclone_job.sh"
chmod +x "$toolsPath/rclone/run_rclone_job.sh"
}