#!/bin/bash
cloud_sync_createService(){
     echo "NYI"
 }

cloud_sync_startService(){
   echo "NYI"
 }

 cloud_sync_stopService(){
   echo "NYI"
 }

cloud_sync_downloadEmuAll(){
  osascript -e 'display notification "Downloading saves" with title "CloudSync"'
  cloud_sync_download 'all'
 }


 cloud_sync_uploadEmuAll(){
   osascript -e 'display notification "Uploading saves" with title "CloudSync"'
   cloud_sync_upload 'all'
   osascript -e 'display notification "Saves uploaded" with title "CloudSync"'
 }
