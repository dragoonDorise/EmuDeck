#!/bin/bash

rclone_path="$toolsPath/rclone"
rclone_bin="$rclone_path/rclone"
rclone_config="$rclone_path/rclone.conf"
cloud_backup_jobScript="$toolsPath/rclone/run_cloud_backup_job.sh"
cloud_backup_restoreScript="$toolsPath/rclone/run_cloud_backup_restore.sh"

cloud_backup_install(){	
    setSetting cloud_sync_status "false" > /dev/null 
    
    if [ ! -f $rclone_bin ]; then
      mkdir -p "$rclone_path"/tmp
      curl -L "$(getReleaseURLGH "rclone/rclone" "linux-amd64.zip")" --output "$rclone_path/tmp/rclone.temp" && mv "$rclone_path/tmp/rclone.temp" "$rclone_path/tmp/rclone.zip"
      unzip -o "$rclone_path/tmp/rclone.zip" -d "$rclone_path/tmp/" && rm "$rclone_path/tmp/rclone.zip"
      mv "$rclone_path"/tmp/* "$rclone_path/tmp/rclone" #don't quote the *
      mv  "$rclone_path/tmp/rclone/rclone" "$rclone_bin"
      rm -rf "$rclone_path/tmp"
      chmod +x "$rclone_bin"
    fi
    cp "$EMUDECKGIT/configs/rclone/rclone.conf" "$rclone_config"
    
    cloud_backup_createJob
}

cloud_backup_install_and_config(){	
    local rclone_provider=$1  
    setSetting rclone_provider "$rclone_provider"
    setSetting cloud_sync_status "false" > /dev/null 
    rm -rf "$HOME/.config/systemd/user/emudeck_cloud_backup.service" > /dev/null 
    if [ ! -f $rclone_bin ]; then     
      mkdir -p "$rclone_path"/tmp
      curl -L "$(getReleaseURLGH "rclone/rclone" "linux-amd64.zip")" --output "$rclone_path/tmp/rclone.temp" && mv "$rclone_path/tmp/rclone.temp" "$rclone_path/tmp/rclone.zip"
      
      unzip -o "$rclone_path/tmp/rclone.zip" -d "$rclone_path/tmp/" && rm "$rclone_path/tmp/rclone.zip"
      mv "$rclone_path"/tmp/* "$rclone_path/tmp/rclone" #don't quote the *
      mv  "$rclone_path/tmp/rclone/rclone" "$rclone_bin"
      rm -rf "$rclone_path/tmp"
      chmod +x "$rclone_bin"
    fi
    cp "$EMUDECKGIT/configs/rclone/rclone.conf" "$rclone_config"
    
    cloud_backup_providersSetup
    cloud_backup_stopService
}

cloud_backup_pickProvider(){

    cloudProviders=()
    cloudProviders+=(1 "Emudeck-GDrive")
    cloudProviders+=(2 "Emudeck-DropBox")
    cloudProviders+=(3 "Emudeck-OneDrive")
    cloudProviders+=(4 "Emudeck-Box")
    cloudProviders+=(5 "Emudeck-NextCloud")

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


cloud_backup_updateProvider(){
    cloud_backup_providersSetup
}

cloud_backup_providersSetup(){
  
  browser=$(xdg-settings get default-web-browser)
  
  if [ $browser != 'com.google.Chrome.desktop' ];then
    flatpak install flathub com.google.Chrome -y
    xdg-settings set default-web-browser com.google.Chrome.desktop
  fi
  
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
  elif [ $rclone_provider == "Emudeck-SFTP" ]; then
  
    NCInput=$(zenity --forms \
        --title="SFTP Sign in" \
        --text="Please enter your SFTP information here." \
        --width=300 \
        --add-entry="Host: " \
        --add-entry="Username: " \
        --add-password="Password: " \
        --add-entry="Port: " \
        --separator="," 2>/dev/null)
        ans=$?
    if [ $ans -eq 0 ]; then
      echo "SFTP Login"
      host="$(echo "$NCInput" | awk -F "," '{print $1}')"
      username="$(echo "$NCInput" | awk -F "," '{print $2}')"
      password="$(echo "$NCInput" | awk -F "," '{print $3}')"
      port="$(echo "$NCInput" | awk -F "," '{print $4}')"
      
      $rclone_bin config update "$rclone_provider" host=$host user=$username port=$port pass="$($rclone_bin obscure $password)"
    else
      echo "Cancel SFTP Login" 
    fi
  
    elif [ $cloud_sync_provider == "Emudeck-SMB" ]; then
    
    NCInput=$(zenity --forms \
        --title="SMB Sign in" \
        --text="Please enter your SMB information here." \
        --width=300 \
        --add-entry="Host: " \
        --add-entry="Username: " \
        --add-password="Password: " \
        --separator="," 2>/dev/null)
        ans=$?
    if [ $ans -eq 0 ]; then
      echo "SMB Login"
      host="$(echo "$NCInput" | awk -F "," '{print $1}')"
      username="$(echo "$NCInput" | awk -F "," '{print $2}')"
      password="$(echo "$NCInput" | awk -F "," '{print $3}')"
      
      $cloud_sync_bin config update "$cloud_sync_provider" host=$host user=$username pass="$($cloud_sync_bin obscure $password)"
    else
      echo "Cancel SMB Login" 
    fi
    
  else
    $rclone_bin config update "$rclone_provider" && echo "true"
  fi
  #We get the previous default browser back
  if [ $browser != 'com.google.Chrome.desktop' ];then
    xdg-settings set default-web-browser $browser
  fi
}

cloud_backup_etup(){

    while true; do
        if [ ! -e "$rclone_bin" ] || [ ! -e "$rclone_jobScript" ];  then
            ans=$(zenity --info --title 'cloud_backup' \
                        --text 'Click on Install to continue' \
                        --width=50 \
                        --ok-label Exit \
                        --extra-button "Install cloud_backup" 2>/dev/null  )
        elif [ -z "$rclone_provider" ]; then
            ans=$(zenity --info --title 'cloud_backup' \
                        --text 'Cloud provider not found. Please click on "Pick Provider' \
                        --width=50 \
                        --ok-label Exit \
                        --extra-button "Reinstall cloud_backup" \
                        --extra-button "Pick Provider" 2>/dev/null  )
        else
            ans=$(zenity --info --title 'cloud_backup' \
                --text 'If this is your first setup click on "Login to your cloud provider" before clicking on "Create Backup"' \
                --width=50 \
                --extra-button "Reinstall cloud_backup" \
                --extra-button "Login to your cloud provider" \
                --extra-button "Create Backup" \
                --ok-label Exit 2>/dev/null ) 
        fi
        rc=$?
        if [ "$rc" == 0 ] || [ "$ans" == "" ]; then
            break
        elif [ "$ans" == "Install cloud_backup" ] || [ "$ans" == "Reinstall cloud_backup" ]; then
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

cloud_backup_createJob(){

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

cloud_backup_createService(){
    echo "Creating cloud_backup service"
    cloud_backup_stopService

    mkdir -p "$HOME/.config/systemd/user"
    echo \
"[Unit]
Description=EmuDeck cloud_backup service

[Service]
Type=simple
ExecStart=\"$rclone_jobScript\"
CPUWeight=20
CPUQuota=50%
IOWeight=20

[Install]
WantedBy=default.target" > "$HOME/.config/systemd/user/emudeck_cloud_backup.service"
#chmod +x "$HOME/.config/systemd/user/emudeck_cloud_backup.service"

#create timer
echo "[Unit]
Description=Runs EmuDeck cloud_backup Every 15 minutes
Requires=emudeck_cloud_backup.service
After=network-online.target
Wants=network-online.target

[Timer]
OnBootSec=5min
Unit=emudeck_cloud_backup.service
OnUnitActiveSec=15m

[Install]
WantedBy=timers.target"> "$HOME/.config/systemd/user/emudeck_cloud_backup.timer"
#chmod +x "$HOME/.config/systemd/user/emudeck_cloud_backup.timer"
#enabling services seems to want to symlink to a place it doesn't have access to, even with --user. Maybe needs sudo...

    echo "Enabling cloud_backup"
    systemctl --user enable emudeck_cloud_backup.service

    echo "Enabling cloud_backup 15 minute timer service"
    systemctl --user enable emudeck_cloud_backup.timer
 
    echo "Enabling cloud_backup Timer."
    cloud_backup_startService
}

cloud_backup_stopService(){
    systemctl --user stop emudeck_cloud_backup.timer
    systemctl --user stop emudeck_cloud_backup.service
}

cloud_backup_startService(){
    systemctl --user start emudeck_cloud_backup.timer
}

cloud_backup_runJobOnce(){
    "$cloud_backup_jobScript"
}

cloud_backup_downloadFiles(){
    "$cloud_backup_restoreScript"
}

cloud_backup_createBackup(){
     ans=$(zenity --info --title 'cloud_backup' \
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
            cloud_backup_createService
        elif [ "$ans" == "Start Service" ]; then
            cloud_backup_startService
        elif [ "$ans" == "Stop Service" ]; then
            cloud_backup_stopService
        elif [ "$ans" == "Restore Cloud Files" ]; then
            cloud_backup_downloadFiles
        elif [ "$ans" == "Run Backup Once" ]; then
            cloud_backup_runJobOnce
        fi
}