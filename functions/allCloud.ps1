#Legacy functions
function emulatorInit($emuName, $emulatorFile, $formattedArgs){
    $emulatorFile = $emulatorFile -replace '/', '\\'
    $formattedArgs = $formattedArgs -replace '/', '\\'
    $launcher = Join-Path $env:APPDATA "EmuDeck/Backend/tools/launcher.py"
    python $launcher $emuName $formattedArgs
}
