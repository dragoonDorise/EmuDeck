#!/bin/bash
cloud_sync_install_and_config(){
     #startLog ${FUNCNAME[0]}
     local cloud_sync_provider=$1
     #We force Chrome to be used as the default
     {

     if [ ! -f "$cloud_sync_bin" ]; then
       cloud_sync_install $cloud_sync_provider
     fi
     } && cloud_sync_config "$cloud_sync_provider"

     setSetting cloud_sync_provider "$cloud_sync_provider"
     setSetting cloud_sync_status "true"
 }

 cloud_sync_install(){
   {
     # startLog ${FUNCNAME[0]}
    local cloud_sync_provider=$1
    setSetting cloud_sync_provider "$cloud_sync_provider"
    setSetting cloud_sync_status "true"

    cloud_sync_createService

    if [ ! -f "$cloud_sync_bin" ]; then
      mkdir -p "$cloud_sync_path"/tmp > /dev/null
      rcloneFile="osx-amd64.zip"

      if [ $appleChip == "arm64" ];then
           rcloneFile="osx-arm64.zip"
      fi

      curl -L "$(getReleaseURLGH "rclone/rclone" ".zip" $rcloneFile)" --output "$cloud_sync_path/tmp/rclone.temp" && mv "$cloud_sync_path/tmp/rclone.temp" "$cloud_sync_path/tmp/rclone.zip"


      unzip -o "$cloud_sync_path/tmp/rclone.zip" -d "$cloud_sync_path/tmp/" && rm "$cloud_sync_path/tmp/rclone.zip" > /dev/null
      mv "$cloud_sync_path"/tmp/* "$cloud_sync_path/tmp/rclone"  > /dev/null  #don't quote the *
      mv  "$cloud_sync_path/tmp/rclone/rclone" "$cloud_sync_bin" > /dev/null
      rm -rf "$cloud_sync_path/tmp" > /dev/null
      chmod +x "$cloud_sync_bin" > /dev/null
    fi


   } > /dev/null
 }


 cloud_sync_createService(){
     echo "NYI"
 }