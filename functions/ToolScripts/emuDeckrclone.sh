#!/bin/bash

rclone_path="$toolsPath/rclone"
rclone_bin="$rclone_path/rclone"
rclone_config="$rclone_path/rclone.conf"
rclone_jobScript="$toolsPath/rclone/run_rclone_job.sh"
rclone_restoreScript="$toolsPath/rclone/run_rclone_restore.sh"

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

rclone_install_and_config(){	
    local rclone_provider=$1  
    setSetting rclone_provider "$rclone_provider"
    rm -rf "$HOME/.config/systemd/user/emudeck_saveBackup.service" > /dev/null 
    mkdir -p "$rclone_path"/tmp
    curl -L "$(getReleaseURLGH "rclone/rclone" "linux-amd64.zip")" --output "$rclone_path/tmp/rclone.temp" && mv "$rclone_path/tmp/rclone.temp" "$rclone_path/tmp/rclone.zip"

    unzip -o "$rclone_path/tmp/rclone.zip" -d "$rclone_path/tmp/" && rm "$rclone_path/tmp/rclone.zip"
    mv "$rclone_path"/tmp/* "$rclone_path/tmp/rclone" #don't quote the *
    mv  "$rclone_path/tmp/rclone/rclone" "$rclone_bin"
    rm -rf "$rclone_path/tmp"
    chmod +x "$rclone_bin"

    cp "$EMUDECKGIT/configs/rclone/rclone.conf" "$rclone_config"
    
    if [ $rclone_provider == "Emudeck-NextCloud" ]; then
    
        local url
        local username
        local password
    
        NCInput=$(zenity --forms \
                --title="Nextcloud Sign in" \
                --text="Please enter your Nextcloud information here. URL is your webdav url. Use HTTP:// or HTTPS:// please." \
                --width=300 \
                --add-entry="URL: " \
                --add-entry="Username: " \
                --add-password="Password: " \
                --separator="," 2>/dev/null)
                ans=$?
        if [ $ans -eq 0 ]; then
            echo "Nextcloud Login"
            url="$(echo "$NCInput" | awk -F "," '{print $1}')"
            username="$(echo "$NCInput" | awk -F "," '{print $2}')"
            password="$(echo "$NCInput" | awk -F "," '{print $3}')"
            
            $rclone_bin config update "$rclone_provider" vendor="nextcloud" url=$url  user=$username pass="$($rclone_bin obscure $password)"
        else
            echo "Cancel Nextcloud Login" 
        fi
    else
        $rclone_bin config update "$rclone_provider" 
    fi
    rclone_stopService
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
    if [ $rclone_provider == "Emudeck-NextCloud" ]; then

        local url
        local username
        local password

        NCInput=$(zenity --forms \
                --title="Nextcloud Sign in" \
                --text="Please enter your Nextcloud information here. URL is your webdav url. Use HTTP:// or HTTPS:// please." \
                --width=300 \
                --add-entry="URL: " \
                --add-entry="Username: " \
                --add-password="Password: " \
                --separator="," 2>/dev/null)
                ans=$?
        if [ $ans -eq 0 ]; then
            echo "Nextcloud Login"
            url="$(echo "$NCInput" | awk -F "," '{print $1}')"
            username="$(echo "$NCInput" | awk -F "," '{print $2}')"
            password="$(echo "$NCInput" | awk -F "," '{print $3}')"
            
            $rclone_bin config update "$rclone_provider" vendor="nextcloud" url=$url  user=$username pass="$($rclone_bin obscure $password)"
        else
            echo "Cancel Nextcloud Login" 
        fi
    else
        $rclone_bin config update "$rclone_provider" 
    fi
}

rclone_setup(){

    while true; do
        if [ ! -e "$rclone_bin" ] || [ ! -e "$rclone_jobScript" ];  then
            ans=$(zenity --info --title 'SaveBackup' \
                        --text 'Click on Install to continue' \
                        --width=50 \
                        --ok-label Exit \
                        --extra-button "Install SaveBackup" 2>/dev/null  )
        elif [ -z "$rclone_provider" ]; then
            ans=$(zenity --info --title 'SaveBackup' \
                        --text 'Cloud provider not found. Please click on "Pick Provider' \
                        --width=50 \
                        --ok-label Exit \
                        --extra-button "Reinstall SaveBackup" \
                        --extra-button "Pick Provider" 2>/dev/null  )
        else
            ans=$(zenity --info --title 'SaveBackup' \
                --text 'If this is your first setup click on "Login to your cloud provider" before clicking on "Create Backup"' \
                --width=50 \
                --extra-button "Reinstall SaveBackup" \
                --extra-button "Login to your cloud provider" \
                --extra-button "Create Backup" \
                --ok-label Exit 2>/dev/null ) 
        fi
        rc=$?
        if [ "$rc" == 0 ] || [ "$ans" == "" ]; then
            break
        elif [ "$ans" == "Install SaveBackup" ] || [ "$ans" == "Reinstall SaveBackup" ]; then
            rclone_install
        elif [ "$ans" == "Pick Provider" ]; then
            rclone_pickProvider
        elif [ "$ans" == "Login to your cloud provider" ]; then
            rclone_updateProvider
        elif [ "$ans" == "Create Backup" ]; then
            rclone_createBackup
        fi
    done

}

rclone_createJob(){

echo '#!/bin/bash'>"$rclone_jobScript"
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
">>"$rclone_jobScript"
chmod +x "$rclone_jobScript"

echo '#!/bin/bash'>"$rclone_restoreScript"
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

\"\$toolsPath/rclone/rclone\" copy -L \"\$rclone_provider\":Emudeck/saves \"\$savesPath\" -P > \"\$toolsPath/rclone/rclone_job.log\"
">>"$rclone_restoreScript"
chmod +x "$rclone_restoreScript"
}

rclone_createService(){
    echo "Creating SaveBackup service"
    rclone_stopService

    mkdir -p "$HOME/.config/systemd/user"
    echo \
"[Unit]
Description=Emudeck SaveBackup service

[Service]
Type=simple
ExecStart=\"$rclone_jobScript\"
CPUWeight=20
CPUQuota=50%
IOWeight=20

[Install]
WantedBy=default.target" > "$HOME/.config/systemd/user/emudeck_saveBackup.service"
#chmod +x "$HOME/.config/systemd/user/emudeck_saveBackup.service"

#create timer
echo "[Unit]
Description=Runs EmuDeck SaveBackup Every 15 minutes
Requires=emudeck_saveBackup.service
After=network-online.target
Wants=network-online.target

[Timer]
OnBootSec=5min
Unit=emudeck_saveBackup.service
OnUnitActiveSec=15m

[Install]
WantedBy=timers.target"> "$HOME/.config/systemd/user/emudeck_saveBackup.timer"
#chmod +x "$HOME/.config/systemd/user/emudeck_saveBackup.timer"
#enabling services seems to want to symlink to a place it doesn't have access to, even with --user. Maybe needs sudo...

    echo "Enabling SaveBackup"
    systemctl --user enable emudeck_saveBackup.service

    echo "Enabling SaveBackup 15 minute timer service"
    systemctl --user enable emudeck_saveBackup.timer
 
    echo "Enabling SaveBackup Timer."
    rclone_startService
}

rclone_stopService(){
    systemctl --user stop emudeck_saveBackup.timer
    systemctl --user stop emudeck_saveBackup.service
}

rclone_startService(){
    systemctl --user start emudeck_saveBackup.timer
}

rclone_runJobOnce(){
    "$rclone_jobScript"
}

rclone_downloadFiles(){
    "$rclone_restoreScript"
}

rclone_createBackup(){
     ans=$(zenity --info --title 'SaveBackup' \
                --text 'Use Create Service to backup your saves directory every 15 minutes' \
                --width=50 \
                --extra-button "Create Service" \
                --extra-button "Start Service" \
                --extra-button "Stop Service" \
                --extra-button "Restore Cloud Files" \
                --extra-button "Run Backup Once" \
                --ok-label Exit 2>/dev/null )
            rc=$?
        if [ "$rc" == 0 ] || [ "$ans" == "" ]; then
            echo "nothing chosen"
        elif [ "$ans" == "Create Service" ]; then
            rclone_createService
        elif [ "$ans" == "Start Service" ]; then
            rclone_startService
        elif [ "$ans" == "Stop Service" ]; then
            rclone_stopService
        elif [ "$ans" == "Restore Cloud Files" ]; then
            rclone_downloadFiles
        elif [ "$ans" == "Run Backup Once" ]; then
            rclone_runJobOnce
        fi
}

rclone_uploadEmu(){
  echo ""

  #emuName=$1
  #rclone_provider=$2
  #if [ -f "$toolsPath/rclone/rclone" ]; then
  #  "$toolsPath/rclone/rclone" sync -P -L "$savesPath"/$emuName/ "$rclone_provider":Emudeck/saves/$emuName/ | zenity --progress --title="Uploading saves" --text="Syncing saves..." --auto-close --width 300 --height 300 --pulsate
  #fi
}

rclone_downloadEmu(){
  echo ""

  #emuName=$1
  #rclone_provider=$2
  #if [ -f "$toolsPath/rclone/rclone" ]; then
  #  "$toolsPath/rclone/rclone" copy -P -L "$rclone_provider":Emudeck/saves/$emuName/ "$savesPath"/$emuName/ | zenity --progress --title="Uploading saves" --text="Syncing saves..." --auto-close --width 300 --height 300 --pulsate
  #fi

}
