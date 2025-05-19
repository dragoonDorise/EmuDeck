#Legacy functions
function emulatorInit($emuName, $emulatorFile, $formattedArgs){
    $launcher = Join-Path $env:APPDATA "EmuDeck\Backend\tools\launcher.py"
    python $launcher $emuName $formattedArgs
}
