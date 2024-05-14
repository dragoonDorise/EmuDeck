#!/bin/bash
cloud_sync_createService(){
     local SERVICE_NAME="com.emudeck.cloudsync"
     local PLIST_PATH="$HOME/Library/LaunchAgents/$SERVICE_NAME.plist"
     local SCRIPT_PATH="$HOME/.config/EmuDeck/backend/tools/cloudSync/cloud_sync_watcher.sh"


     mkdir -p "$(dirname "$PLIST_PATH")"

     {
     cat <<EOF > "$PLIST_PATH"
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>$SERVICE_NAME</string>
        <key>ProgramArguments</key>
        <array>
          <string>/bin/bash</string>
          <string>$SCRIPT_PATH</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
      </dict>
     </plist>
EOF
     #chmod +x "$SCRIPT_PATH"
     }
 }


cloud_sync_startService(){
   local SERVICE_NAME="com.emudeck.cloudsync"
   local PLIST_PATH="$HOME/Library/LaunchAgents/$SERVICE_NAME.plist"
   local SCRIPT_PATH="$HOME/.config/EmuDeck/backend/tools/cloudSync/cloud_sync_watcher.sh"
   launchctl load "$PLIST_PATH"
 }

 cloud_sync_stopService(){
   local SERVICE_NAME="com.emudeck.cloudsync"
   local PLIST_PATH="$HOME/Library/LaunchAgents/$SERVICE_NAME.plist"
   local SCRIPT_PATH="$HOME/.config/EmuDeck/backend/tools/cloudSync/cloud_sync_watcher.sh"
   launchctl unload "$PLIST_PATH"
 }
