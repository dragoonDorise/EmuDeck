$env:path = $env:path + ";C:\Program Files\WinRaR"
#$winPath=-join((Get-Item .\EmuDeck.bat).PSDrive.Name,':')
$winPath = Get-Location
function waitForWinRar(){
	While(1){
		$winrar = [bool](Get-Process Winrar -EA SilentlyContinue)
		if(!$winrar){
			break
		}
	}
}

function download($url, $output) {
	#Invoke-WebRequest -Uri $url -OutFile $output
	$wc = New-Object net.webclient
	$wc.Downloadfile($url, -join('Emulation/',$output))
   
	foreach ($line in $output) {
		$extn = [IO.Path]::GetExtension($line)
		if ($extn -eq ".zip" ){
			   #Expand-Archive  $output $output.replace('.zip','') -ErrorAction SilentlyContinue
			$dir = -join($output.replace('.zip',''), "\");
			WinRAR x -y $output $dir
			waitForWinRar
			Remove-Item $output
		}
		if ($extn -eq ".7z" ){
			$dir = -join($output.replace('.7z',''), "\");
			WinRAR x -y $output $dir
			waitForWinRar
			Remove-Item $output
		}
	}
	Write-Host "Done!" -ForegroundColor green -BackgroundColor black
}

function downloadCore($url, $output) {
	#Invoke-WebRequest -Uri $url -OutFile $output
	$file=-join('Emulation\',$output,'.zip')
	$zipFile=-join('E:\',$file)
	$destination = -join($winPath,'Emulation\tools\EmulationStation-DE\Emulators\RetroArch\cores\')
	$wc = New-Object net.webclient
	$wc.Downloadfile($url, $file)
	
	foreach ($line in $file) {
		$extn = [IO.Path]::GetExtension($line)
		if ($extn -eq ".zip" ){			
			Expand-Archive -Path $zipFile -DestinationPath $destination -Force
			Remove-Item $zipFile
		}
		#if ($extn -eq ".7z" ){
		#	$dir = -join($output.replace('.7z',''), "\");
		#	WinRAR x -y $output $dir
		#	waitForWinRar
		#	del $output
		#}
	}
	Write-Host "Done!" -ForegroundColor green -BackgroundColor black
}

function Show-Notification {
	[cmdletbinding()]
	Param (
		[string]
		$ToastTitle,
		[string]
		[parameter(ValueFromPipeline)]
		$ToastText
	)
	$echo = -join($ToastTitle,'...')
	Write-Output $echo
	[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
	$Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

	$RawXml = [xml] $Template.GetXml()
	($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
	($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

	$SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
	$SerializedXml.LoadXml($RawXml.OuterXml)

	$Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
	$Toast.Tag = "PowerShell"
	$Toast.Group = "PowerShell"
	$Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

	$Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
	$Notifier.Show($Toast);
}

function moveFromTemp($old,$new){
	robocopy "$old" $new /s /Move /NFL /NDL /NJH /NJS /nc /ns /np 
}

function waitForUser(){
	Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
}

function sedFile($file, $old, $new){
	(Get-Content $file).replace($old, $new) | Set-Content $file
}



$installationPath = "C:\Emulation\"
$url_ra = "https://buildbot.libretro.com/stable/1.10.3/windows/x86_64/RetroArch.7z"
$url_dolphin = "https://dl.dolphin-emu.org/builds/c0/39/dolphin-master-5.0-16101-x64.7z"
$url_pcsx2 = "https://github.com/PCSX2/pcsx2/releases/download/v1.6.0/pcsx2-v1.6.0-windows-32bit-portable.7z"
$url_rpcs3 = "https://github.com/RPCS3/rpcs3-binaries-win/releases/download/build-2ba437b6dc0c68a6f2cc4a683012c3d25310839a/rpcs3-v0.0.22-13600-2ba437b6_win64.7z"
$url_yuzu = "https://github.com/yuzu-emu/yuzu-mainline/releases/download/mainline-0-1014/yuzu-windows-msvc-20220512-4d5eaaf3f.zip"
$url_duck = "https://github.com/stenzek/duckstation/releases/download/latest/duckstation-windows-x64-release.zip"
$url_cemu = "https://cemu.info/releases/cemu_1.26.2.zip"
$url_xenia = "https://github.com/xenia-project/release-builds-windows/releases/latest/download/xenia_master.zip"
$url_xemu = "https://github.com/mborgerson/xemu/releases/latest/download/xemu-win-release.zip"
$url_srm = "https://github.com/SteamGridDB/steam-rom-manager/releases/download/v2.3.36/Steam-ROM-Manager-portable-2.3.36.exe"
$url_esde = "https://gitlab.com/es-de/emulationstation-de/-/package_files/36880305/download"
$url_citra ="https://github.com/citra-emu/citra-nightly/releases/download/nightly-1766/citra-windows-mingw-20220520-a6e7a81.7z"
$userFolder = $env:USERPROFILE
$dolphinDir = -join($userFolder,'\Documents\Dolphin Emulator\Config')
$duckDir = -join($userFolder,'\Documents\DuckStation')
$yuzuDir = -join($userFolder,'\AppData\Roaming\yuzu')
$dolphinIni=-join($dolphinDir,'\Dolphin.ini')
$YuzuIni=-join($yuzuDir,'\config\qt-config.ini')
$duckIni=-join($duckDir,'\settings.ini')
$deckPath="/run/media/mmcblk0p1/"
$raConfigDir=-join($winPath,'\Emulation\tools\EmulationStation-DE\Emulators\RetroArch\')
$raExe=-join($winPath,'\Emulation\\tools\\EmulationStation-DE\\Emulators\\RetroArch\\','retroarch.exe')

Write-Host "Hi! Welcome to EmuDeck Windows Edition." -ForegroundColor blue -BackgroundColor black
Write-Output ""
Write-Output "This script will create an Emulation folder in the same folder as this file"
Write-Output "and in there it will download all the needed Emulators, EmulationStation and Steam Rom Manager."
Write-Host "If you want to install EmuDeck on another drive, just move Emudeck.bat there now and open it again." -ForegroundColor red -BackgroundColor black
Write-Output "Before you continue make sure you have WinRar installed"
Write-Output "You can download Winrar from https://www.win-rar.com/download.html"
Write-Output ""
waitForUser

Clear-Host



mkdir Emulation -ErrorAction SilentlyContinue
Set-Location Emulation
mkdir bios -ErrorAction SilentlyContinue
mkdir tools -ErrorAction SilentlyContinue
mkdir saves -ErrorAction SilentlyContinue
Clear-Host

Write-Output "Installing, please stand by..."
Write-Output ""
#EmuDeck Download
Show-Notification -ToastTitle "Downloading EmuDeck files"
download "https://github.com/dragoonDorise/EmuDeck/archive/refs/heads/dev.zip" "temp.zip"
moveFromTemp "temp\EmuDeck-dev" "EmuDeck"
moveFromTemp "EmuDeck\roms" "roms"
moveFromTemp "EmuDeck\tools\launchers" "tools\launchers"

#Dowloading..ESDE
Show-Notification -ToastTitle 'Downloading EmulationStation DE'
download $url_esde "esde.zip"
moveFromTemp "esde\EmulationStation-DE" "tools/EmulationStation-DE"

#
#We download all the Emulators
#


#RetroArch
Show-Notification -ToastTitle 'Downloading RetroArch'
download $url_ra "ra.7z"
#Dolphin
Show-Notification -ToastTitle 'Downloading Dolphin'
download $url_dolphin "dolphin.7z"
#PCSX2 
Show-Notification -ToastTitle 'Downloading PCSX2'
download $url_pcsx2 "pcsx2.7z"
#RPCS3
Show-Notification -ToastTitle 'Downloading RPCS3'
download $url_rpcs3 "rpcs3.7z"
#Xemu
Show-Notification -ToastTitle 'Downloading Xemu'
download $url_xemu "xemu-win-release.zip"
moveFromTemp "xemu-win-release" "tools\EmulationStation-DE\Emulators\xemu"
#Yuzu
Show-Notification -ToastTitle 'Downloading Yuzu'
download $url_yuzu "yuzu.zip"
moveFromTemp "yuzu\yuzu-windows-msvc" "tools\EmulationStation-DE\Emulators\yuzu\yuzu-windows-msvc"
#Citra
Show-Notification -ToastTitle 'Downloading Citra'
download $url_citra "citra.zip"
moveFromTemp "citra/nightly-mingw" "tools\EmulationStation-DE\Emulators\citra"
#Duckstation
Show-Notification -ToastTitle 'Downloading DuckStation'
download $url_duck "duckstation.zip"
moveFromTemp "duckstation" "tools\EmulationStation-DE\Emulators\duckstation"
#Cemu
Show-Notification -ToastTitle 'Downloading Cemu'
download $url_cemu "cemu.zip"
moveFromTemp "cemu\cemu_1.26.2" "tools\EmulationStation-DE\Emulators\cemu"
#Xenia
Show-Notification -ToastTitle 'Downloading Xenia'
download $url_xenia "xenia.zip"
moveFromTemp "xenia" "tools\EmulationStation-DE\Emulators\xenia"
#SRM
Show-Notification -ToastTitle 'Downloading Steam Rom Manager'
download $url_srm "tools/srm.exe"

Show-Notification -ToastTitle 'Cleaning up...'
moveFromTemp "ra\RetroArch-Win64" "tools\EmulationStation-DE\Emulators\RetroArch"
moveFromTemp "pcsx2\PCSX2 1.6.0" "tools\EmulationStation-DE\Emulators\PCSX2"
moveFromTemp "rpcs3" "tools\EmulationStation-DE\Emulators\RPCS3"
moveFromTemp "dolphin\Dolphin-x64" "tools\EmulationStation-DE\Emulators\Dolphin-x64"
Remove-Item cemu
Remove-Item ra
Remove-Item dolphin
Remove-Item esde
Remove-Item pcsx2
Remove-Item yuzu
Remove-Item temp
Write-Host "Done!" -ForegroundColor green -BackgroundColor black
#Emulators config
Show-Notification -ToastTitle 'Configuring Emulators'




#moveFromTemp "EmuDeck\configs\org.citra_emu.citra" "XXXX"
#moveFromTemp "EmuDeck\configs\org.ryujinx.Ryujinx" "XXXX"

moveFromTemp "EmuDeck\configs\org.DolphinEmu.dolphin-emu\config\dolphin-emu" $dolphinDir
moveFromTemp "EmuDeck\configs\info.cemu.Cemu\data\cemu" "tools\EmulationStation-DE\Emulators\cemu"
moveFromTemp "EmuDeck\configs\org.citra_emu.citra\config\citra-emu" "tools\EmulationStation-DE\Emulators\citra"
moveFromTemp "EmuDeck\configs\org.libretro.RetroArch\config\retroarch" "tools\EmulationStation-DE\Emulators\RetroArch"
moveFromTemp "EmuDeck\configs\net.pcsx2.PCSX2\config\PCSX2" "tools\EmulationStation-DE\Emulators\PCSX2"
moveFromTemp "EmuDeck\configs\net.rpcs3.RPCS3\config\rpcs3" "tools\EmulationStation-DE\Emulators\RPCS3"
moveFromTemp "EmuDeck\configs\org.duckstation.DuckStation\data\duckstation" $duckDir
mkdir "tools\userData\" -ErrorAction SilentlyContinue
Copy-Item  "EmuDeck\configs\steam-rom-manager\userData\userConfigurationsWE.json" "tools\userData\userConfigurations.json"
rename tools/userData/userConfigurationsWE.json tools/userData/userConfigurations.json
moveFromTemp "EmuDeck\configs\org.yuzu_emu.yuzu" $yuzuDir
#moveFromTemp "EmuDeck\configs\emulationstation" "tools\EmulationStation-DE\.emulationstation"
moveFromTemp "EmuDeck\configs\app.xemu.xemu\data\xemu\xemu" "tools\EmulationStation-DE\Emulators\xemu"
moveFromTemp "EmuDeck\configs\xenia" "tools\EmulationStation-DE\Emulators\xenia"
mkdir "tools\EmulationStation-DE\.emulationstation" -ErrorAction SilentlyContinue
Copy-Item EmuDeck\configs\emulationstation\es_settings.xml tools\EmulationStation-DE\.emulationstation\es_settings.xml
Write-Host "Done!" -ForegroundColor green -BackgroundColor black

Show-Notification -ToastTitle 'Applying Windows Especial configurations'
sedFile 'tools\EmulationStation-DE\Emulators\xemu\xemu.ini' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\Emulators\xemu\xemu.toml' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\Emulators\cemu\settings.xml' 'Z:/run/media/mmcblk0p1/' $winPath
sedFile 'tools\EmulationStation-DE\Emulators\cemu\settings.xml' 'roms/wiiu/roms' 'roms\wiiu\'
sedFile $dolphinIni $deckPath $winPath
sedFile $dolphinIni 'Emulation/bios/' 'Emulation\bios\'
sedFile $dolphinIni '/roms/gamecube' '\roms\gamecube'
sedFile $dolphinIni '/roms/wii' '\roms\wii'
sedFile 'tools\EmulationStation-DE\Emulators\PCSX2\inis\PCSX2_ui.ini' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\Emulators\PCSX2\inis\PCSX2_ui.ini' 'Emulation/bios/' 'Emulation\bios\'
sedFile $YuzuIni $deckPath $winPath
sedFile $YuzuIni 'Emulation/roms/switch' 'Emulation\roms\switch'
sedFile $duckIni $deckPath $winPath
sedFile $duckIni 'Emulation/bios/' 'Emulation\bios\'

#SRM
sedFile 'tools\userData\userConfigurations.json' 'E:/' $winPath


#ESDE
sedFile 'tools\EmulationStation-DE\.emulationstation\es_settings.xml' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\.emulationstation\es_settings.xml' '/Emulation/roms/' 'Emulation\roms\'

Show-Notification -ToastTitle 'Downloading RetroArch Cores'
mkdir "tools\EmulationStation-DE\Emulators\RetroArch\cores" -ErrorAction SilentlyContinue
$RAcores = @('a5200_libretro.dll','81_libretro.dll','atari800_libretro.dll','bluemsx_libretro.dll','chailove_libretro.dll','fbneo_libretro.dll','freechaf_libretro.dll','freeintv_libretro.dll','fuse_libretro.dll','gearsystem_libretro.dll','gw_libretro.dll','hatari_libretro.dll','lutro_libretro.dll','mednafen_pcfx_libretro.dll','mednafen_vb_libretro.dll','mednafen_wswan_libretro.dll','mu_libretro.dll','neocd_libretro.dll','nestopia_libretro.dll','nxengine_libretro.dll','o2em_libretro.dll','picodrive_libretro.dll','pokemini_libretro.dll','prboom_libretro.dll','prosystem_libretro.dll','px68k_libretro.dll','quasi88_libretro.dll','scummvm_libretro.dll','squirreljme_libretro.dll','theodore_libretro.dll','uzem_libretro.dll','vecx_libretro.dll','vice_xvic_libretro.dll','virtualjaguar_libretro.dll','x1_libretro.dll','mednafen_lynx_libretro.dll','mednafen_ngp_libretro.dll','mednafen_pce_libretro.dll','mednafen_pce_fast_libretro.dll','mednafen_psx_libretro.dll','mednafen_psx_hw_libretro.dll','mednafen_saturn_libretro.dll','mednafen_supafaust_libretro.dll','mednafen_supergrafx_libretro.dll','blastem_libretro.dll','bluemsx_libretro.dll','bsnes_libretro.dll','bsnes_mercury_accuracy_libretro.dll','cap32_libretro.dll','citra2018_libretro.dll','citra_libretro.dll','crocods_libretro.dll','desmume2015_libretro.dll','desmume_libretro.dll','dolphin_libretro.dll','dosbox_core_libretro.dll','dosbox_pure_libretro.dll','dosbox_svn_libretro.dll','fbalpha2012_cps1_libretro.dll','fbalpha2012_cps2_libretro.dll','fbalpha2012_cps3_libretro.dll','fbalpha2012_libretro.dll','fbalpha2012_neogeo_libretro.dll','fceumm_libretro.dll','fbneo_libretro.dll','flycast_libretro.dll','fmsx_libretro.dll','frodo_libretro.dll','gambatte_libretro.dll','gearboy_libretro.dll','gearsystem_libretro.dll','genesis_plus_gx_libretro.dll','genesis_plus_gx_wide_libretro.dll','gpsp_libretro.dll','handy_libretro.dll','kronos_libretro.dll','mame2000_libretro.dll','mame2003_plus_libretro.dll','mame2010_libretro.dll','mame_libretro.dll','melonds_libretro.dll','mesen_libretro.dll','mesen-s_libretro.dll','mgba_libretro.dll','mupen64plus_next_libretro.dll','nekop2_libretro.dll','np2kai_libretro.dll','nestopia_libretro.dll','parallel_n64_libretro.dll','pcsx2_libretro.dll','pcsx_rearmed_libretro.dll','picodrive_libretro.dll','ppsspp_libretro.dll','puae_libretro.dll','quicknes_libretro.dll','race_libretro.dll','sameboy_libretro.dll','smsplus_libretro.dll','snes9x2010_libretro.dll','snes9x_libretro.dll','stella2014_libretro.dll','stella_libretro.dll','tgbdual_libretro.dll','vbam_libretro.dll','vba_next_libretro.dll','vice_x128_libretro.dll','vice_x64_libretro.dll','vice_x64sc_libretro.dll','vice_xscpu64_libretro.dll','yabasanshiro_libretro.dll','yabause_libretro.dll','bsnes_hd_beta_libretro.dll','swanstation_libretro.dll')
$RAcores.count

foreach ( $core in $RAcores )
{
	$url= -join('http://buildbot.libretro.com/nightly/windows/x86_64/latest/',$core,'.zip')
	$dest= -join('tools\EmulationStation-DE\Emulators\RetroArch\cores\',$core)
	Show-Notification -ToastTitle "Downloading $url"	
	downloadCore $url $dest
}

#RetroArch especial fixes
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' '~/.var/app/org.libretro.RetroArch/config/retroarch/' $raConfigDir
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' '/app/share/libretro/' ':\'
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' '/"' '\"'
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' 'http://localhost:4404\' 'http://localhost:4404/'
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' '/app/lib/retroarch/filters/' '\app\lib\retroarch\filters\'
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' 'database/' 'database\'
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' 'http://buildbot.libretro.com/nightly/linux/x86_64/latest\' 'http://buildbot.libretro.com/nightly/windows/x86_64/latest/'
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' 'config/remaps' 'config\remaps'
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' '/Emulation/bios' '\Emulation\bios'
sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' 'video4linux2' ''
#sedFile 'tools\EmulationStation-DE\Emulators\citra\qt-config.ini' $deckPath $winPath

#Path fixes other emus

sedFile 'tools\EmulationStation-DE\Emulators\RetroArch\retroarch.cfg' '/Emulation/bios' '\Emulation\bios'

sedFile 'tools/launchers/cemu.bat' 'XX' $winPath
sedFile 'tools/launchers/dolphin-emu.bat'  'XX' $winPath
sedFile 'tools/launchers/duckstation.bat'  'XX' $winPath
sedFile 'tools/launchers/PCSX2.bat'  'XX' $winPath
sedFile 'tools/launchers/retroarch.bat'  'XX' $winPath
sedFile 'tools/launchers/RPCS3.bat'  'XX' $winPath
sedFile 'tools/launchers/xemu-emu.bat'  'XX' $winPath
sedFile 'tools/launchers/xenia.bat'  'XX' $winPath
sedFile 'tools/launchers/yuzu.bat'  'XX' $winPath


#Controller configs
#Dolphin
$controllerDolphinIni=-join($dolphinDir,'\GCPadNew.ini')
$controllerDolphinWiiIni=-join($dolphinDir,'\WiimoteNew.ini')

#Dolphin GC
sedFile $controllerDolphinIni 'evdev/0/Microsoft X-Box 360 pad 0' 'XInput/0/Gamepad'
sedFile $controllerDolphinIni 'Buttons/A = SOUTH' 'Buttons/A = Button B'
sedFile $controllerDolphinIni 'Buttons/B = EAST' 'Buttons/B = Button A'
sedFile $controllerDolphinIni 'Buttons/X = NORTH' 'Buttons/X = Button Y'
sedFile $controllerDolphinIni 'Buttons/Y = WEST' 'Buttons/Y = Button X'
sedFile $controllerDolphinIni 'Buttons/Z = TR' 'Buttons/Z = Trigger L'
sedFile $controllerDolphinIni 'Buttons/Start = START' 'Buttons/Start = Start'
sedFile $controllerDolphinIni 'Main Stick/Up = `Axis 1-`' 'Main Stick/Up = `Left Y+`'
sedFile $controllerDolphinIni 'Main Stick/Down = `Axis 1+`' 'Main Stick/Down = `Left Y-`'
sedFile $controllerDolphinIni 'Main Stick/Left = `Axis 0-`' 'Main Stick/Left = `Left X-`'
sedFile $controllerDolphinIni 'Main Stick/Right = `Axis 0+`' 'Main Stick/Right = `Left X+`'
sedFile $controllerDolphinIni 'C-Stick/Up = `Axis 4-`' 'C-Stick/Up = `Right Y+`'
sedFile $controllerDolphinIni 'C-Stick/Down = `Axis 4+`' 'C-Stick/Down = `Right Y-`'
sedFile $controllerDolphinIni 'C-Stick/Left = `Axis 3-`' 'C-Stick/Left = `Right X-`'
sedFile $controllerDolphinIni 'C-Stick/Right = `Axis 3+`' 'C-Stick/Right = `Right X+`'
sedFile $controllerDolphinIni 'Triggers/L = `Full Axis 2+`' 'Triggers/L = `Shoulder L`'
sedFile $controllerDolphinIni 'Triggers/R = `Full Axis 5+`' 'Triggers/R = `Shoulder R`'
sedFile $controllerDolphinIni 'Triggers/L-Analog = `Full Axis 2+`' 'Triggers/L-Analog = `Trigger L`'
sedFile $controllerDolphinIni 'Triggers/R-Analog = `Full Axis 5+`' 'Triggers/R-Analog = `Trigger R`'
sedFile $controllerDolphinIni 'D-Pad/Up = `Axis 7-`' 'D-Pad/Up = `Pad N`'
sedFile $controllerDolphinIni 'D-Pad/Down = `Axis 7+`' 'D-Pad/Down = `Pad S`'
sedFile $controllerDolphinIni 'D-Pad/Left = `Axis 6-`' 'D-Pad/Left = `Pad W`'
sedFile $controllerDolphinIni 'D-Pad/Right = `Axis 6+`' 'D-Pad/Right = `Pad E`'

#Dolphin Wii
sedFile $controllerDolphinWiiIni 'evdev/0/Microsoft X-Box 360 pad 0' 'XInput/0/Gamepad'
sedFile $controllerDolphinWiiIni 'Buttons/A = SOUTH' 'Buttons/A = Button B'
sedFile $controllerDolphinWiiIni 'Buttons/B = EAST' 'Buttons/B = Button A'
sedFile $controllerDolphinWiiIni 'Buttons/1 = NORTH' 'Buttons/X = Button Y'
sedFile $controllerDolphinWiiIni 'Buttons/2 = WEST' 'Buttons/Y = Button X'
sedFile $controllerDolphinWiiIni 'Buttons/- = SELECT' 'Buttons/- = Select'
sedFile $controllerDolphinWiiIni 'Buttons/+ = START' 'Buttons/+ = Start'
sedFile $controllerDolphinWiiIni 'D-Pad/Up = `Axis 7-`' 'D-Pad/Up = `Pad N`'
sedFile $controllerDolphinWiiIni 'D-Pad/Down = `Axis 7+`' 'D-Pad/Down = `Pad S`'
sedFile $controllerDolphinWiiIni 'D-Pad/Left = `Axis 6-`' 'D-Pad/Left = `Pad W`'
sedFile $controllerDolphinWiiIni 'D-Pad/Right = `Axis 6+`' 'D-Pad/Right = `Pad E`'
sedFile $controllerDolphinWiiIni 'Shake/Z = TL' 'Shake/Z = Shoulder L'
sedFile $controllerDolphinWiiIni 'IR/Up = `Axis 4-`' 'IR/Up = `Right Y+`'
sedFile $controllerDolphinWiiIni 'IR/Down = `Axis 4+`' 'IR/Down = `Right Y-`'
sedFile $controllerDolphinWiiIni 'IR/Left = `Axis 3-`' 'IR/Left = `Right X-`'
sedFile $controllerDolphinWiiIni 'IR/Right = `Axis 3+`' 'IR/Right = `Right X+`'
sedFile $controllerDolphinWiiIni 'Nunchuk/Buttons/C = `Full Axis 5+`' 'Nunchuk/Buttons/C = `Trigger L`'
sedFile $controllerDolphinWiiIni 'Nunchuk/Buttons/Z = `Full Axis 2+`' 'Nunchuk/Buttons/Z = `Trigger R`'
sedFile $controllerDolphinWiiIni 'Nunchuk/Stick/Up = `Axis 1-`' 'Nunchuk/Stick/Up = `Left Y+`'
sedFile $controllerDolphinWiiIni 'Nunchuk/Stick/Down = `Axis 1+`' 'Nunchuk/Stick/Down = `Left Y-`'
sedFile $controllerDolphinWiiIni 'Nunchuk/Stick/Left = `Axis 0-`' 'Nunchuk/Stick/Left = `Left X-`'
sedFile $controllerDolphinWiiIni 'Nunchuk/Stick/Right = `Axis 0+`' 'Nunchuk/Stick/Right = `Left X+`'
sedFile $controllerDolphinWiiIni 'Nunchuk/Shake/Z = TR' 'Nunchuk/Shake/Z = TR'



Write-Host "All done!" -ForegroundColor green -BackgroundColor black