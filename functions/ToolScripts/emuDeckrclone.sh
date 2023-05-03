#!/bin/bash

rclone_path="$toolsPath/rclone"
rclone_bin="$rclone_path/rclone"
rclone_config="$rclone_path/rclone.conf"
rclone_jobScript="$toolsPath/rclone/run_rclone_job.sh"
rclone_restoreScript="$toolsPath/rclone/run_rclone_restore.sh"

rclone_install(){	
  {
    local rclone_provider=$1  
    setSetting rclone_provider "$rclone_provider" > /dev/null 
    rm -rf "$HOME/.config/systemd/user/emudeck_saveBackup.service" > /dev/null 
    mkdir -p "$rclone_path"/tmp > /dev/null 
    curl -L "$(getReleaseURLGH "rclone/rclone" "linux-amd64.zip")" --output "$rclone_path/tmp/rclone.temp" && mv "$rclone_path/tmp/rclone.temp" "$rclone_path/tmp/rclone.zip" > /dev/null 
    
    unzip -o "$rclone_path/tmp/rclone.zip" -d "$rclone_path/tmp/" && rm "$rclone_path/tmp/rclone.zip" > /dev/null 
    mv "$rclone_path"/tmp/* "$rclone_path/tmp/rclone"  > /dev/null  #don't quote the *
    mv  "$rclone_path/tmp/rclone/rclone" "$rclone_bin" > /dev/null 
    rm -rf "$rclone_path/tmp" > /dev/null 
    chmod +x "$rclone_bin" > /dev/null 
  } > /dev/null
}

rclone_config(){	
 
  kill -15 $(pidof rclone)
  local rclone_provider=$1  
   cp "$EMUDECKGIT/configs/rclone/rclone.conf" "$rclone_config"
  rclone_stopService
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

  zenity --info --text --width=200 "Press OK when you are logged into your Cloud Provider"
 
  #Lets search for that token
   while read line
   do
      if [[ "$line" == *"[Emudeck"* ]]
      then
        section=$line
      elif [[ "$line" == *"token = "* ]]; then
        token=$line
        break     
      fi
   
   done < $rclone_config
   
   replace_with=""
   
   # Cleanup
   token=${token/"token = "/$replace_with}
   token=$(echo "$token" | sed "s/\"/'/g")
   section=$(echo "$section" | sed 's/[][]//g; s/"//g')  
   
   json='{"section":"'"$section"'","token":"'"$token"'"}'
   
   #json=$token
   
   response=$(curl --request POST --url "https://patreon.emudeck.com/hastebin.php" --header "content-type: application/x-www-form-urlencoded" --data-urlencode "data=${json}")
   
     
    text="$(printf "<b>CloudSync Configured!</b>\nIf you want to set CloudSync on another EmuDeck installation you need to use this code:\n\n<b>${response}</b>")"
      
      zenity --info --width=300 \
     --text="${text}" 2>/dev/null
    
    clean_response=$(echo -n "$response" | tr -d '\n')
    
    echo "$clean_response"
  
}

 rclone_config_with_code(){	
   local code=$1
   if [ $code ]; then
     rclone_stopService
     
     json=$(curl -s "https://patreon.emudeck.com/hastebin.php?code=$code")     
     json_object=$(echo $json | jq .)
     
     section=$(echo $json | jq .section)
     token=$(echo $json | jq .token)
    
      # Cleanup
      token=$(echo "$token" | sed "s/\"//g")
      token=$(echo "$token" | sed "s/'/\"/g")            
      section=$(echo "$section" | sed 's/[][]//g; s/"//g')     
      
     cp "$EMUDECKGIT/configs/rclone/rclone.conf" "$rclone_config"
     
     iniFieldUpdate "$rclone_config" "$section" "token" "$token"     
     
     #Bad Temp fix:
     
     sed -i "s/token =/''/g" $rclone_config
     sed -i 's/  /token = /g' $rclone_config
     
     text="$(printf "<b>CloudSync Configured!")"      
       zenity --info \
      --text="${text}" 2>/dev/null
   else
     exit
   fi
   
 }

rclone_install_and_config(){	
    local rclone_provider=$1
    rclone_install $rclone_provider
    rclone_config $rclone_provider
}

rclone_install_and_config_with_code(){	
    local rclone_provider=$1    
    code=$(zenity --entry --text="Please enter your SaveSync code")
    rclone_install $rclone_provider
    rclone_config_with_code $code
}


rclone_uninstall(){
  rm -rf $rclone_bin && rm -rf $rclone_config && echo "true"
}

rclone_stopService(){
    systemctl --user stop emudeck_saveBackup.timer
    systemctl --user stop emudeck_saveBackup.service
}

rclone_upload(){
  local emuName=$1
  "$toolsPath/rclone/rclone" copy -P -L "$savesPath"/$emuName/ "$rclone_provider":Emudeck/saves/$emuName/ && echo $timestamp > "$savesPath"/$emuName/.last_upload && rm -rf $savesPath/$emuName/.fail_upload | zenity --progress --title="Uploading saves" --text="Syncing saves..." --auto-close --width 300 --height 100 --pulsate     
}

rclone_download(){
  local emuName=$1
  "$toolsPath/rclone/rclone" copy -P -L "$rclone_provider":Emudeck/saves/$emuName/ "$savesPath"/$emuName/ && echo $timestamp > "$savesPath"/$emuName/.last_download && rm -rf $savesPath/$emuName/.fail_download | zenity --progress --title="Downloading saves" --text="Syncing saves..." --auto-close --width 300 --height 100 --pulsate
}


rclone_uploadEmu(){
  local emuName=$1
  if [ -f "$toolsPath/rclone/rclone" ]; then    
    local timestamp=$(date +%s)
  
    #We check for internet connection
    if [[ $(check_internet_connection) == true ]]; then
      
      #Do we have a failed upload?
      if [ -f $savesPath/$emuName/.fail_upload ]; then
          
        while true; do
          ans=$(zenity --question \
             --title="CloudSync conflict" \
             --text="We've detected a previously failed upload, do you want us to upload your saves and overwrite your saves in the cloud?" \
             --extra-button "No, download from the cloud and overwrite my local saves" \
             --cancel-label="Skip for now" \
             --ok-label="Yes, upload them" \
             --width=400)
          rc=$?
          response="${rc}-${ans}"
          break
        done
        
        if [[ $response =~ "download" ]]; then
          #Download - Extra
          rclone_download $emuName
        elif [[ $response =~ "0-" ]]; then
          #Upload - OK
          rclone_upload $emuName
        else
          #Skip - Cancel
          return
        fi
      
      else        
      #Upload
       rclone_upload $emuName 
      fi  
    
    else
    # No internet? We mark it as failed
      echo $timestamp > $savesPath/$emuName/.fail_upload
    fi   
    
  fi
}

rclone_downloadEmu(){
  local emuName=$1
  if [ -f "$toolsPath/rclone/rclone" ]; then    
    local timestamp=$(date +%s)
    
    #We check for internet connection
    if [[ $(check_internet_connection) == true ]]; then
      
      #Do we have a failed download?
      if [ -f $savesPath/$emuName/.fail_download ]; then
        
        while true; do
          ans=$(zenity --question \
             --title="CloudSync conflict" \
             --text="We've detected a previously failed download, do you want us to download your saves from the cloud and overwrite your local saves?" \
             --extra-button "No, upload to the cloud and overwrite my cloud saves" \
             --cancel-label="Skip for now" \
             --ok-label="Yes, download them" \
             --width=400)
          rc=$?
          response="${rc}-${ans}"
          break
        done
      
        if [[ $response =~ "upload" ]]; then
          #Upload - Extra button
          rclone_upload $emuName
        elif [[ $response =~ "0-" ]]; then
          #Download - OK
          rclone_download $emuName
        else
          #Skip - Cancel
          return
        fi

        
      else        
      #Download
       rclone_download $emuName
      fi
    else
    # No internet? We mark it as failed
      echo $timestamp > "$savesPath"/$emuName/.fail_download
    fi  
  fi
}