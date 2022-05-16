$env:path = $env:path + ";C:\Program Files\WinRaR"
$winPath=-join((Get-Item .\EmuDeck.bat).PSDrive.Name,':')

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
			del $output
		}
		if ($extn -eq ".7z" ){
			$dir = -join($output.replace('.7z',''), "\");
			WinRAR x -y $output $dir
			waitForWinRar
			del $output
		}
	}
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

	[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
	$Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

	$RawXml = [xml] $Template.GetXml()
	($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
	($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

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
	robocopy "$old" $new /s /move /NFL /NDL /NJH /NJS /nc /ns /np
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
$url_xemu = "https://github.com/mborgerson/xemu/releases/latest/download/xemu-win-release.zip"


Write-Host "Hi! Welcome to EmuDeck Windows Edition." -ForegroundColor blue -BackgroundColor black
echo ""
echo "This script will create an Emulation folder in the same folder as this file"
echo "and in there it will download all the needed emulators, EmulationStation and Steam Rom Manager."
Write-Host "If you want to install EmuDeck on another drive, just move Emudeck.bat there now and open it again." -ForegroundColor red -BackgroundColor black
echo "Before you continue make sure you have WinRar installed"
echo "You can download Winrar from https://www.win-rar.com/download.html"
echo ""
waitForUser

clear



mkdir Emulation -ErrorAction SilentlyContinue
cd Emulation
mkdir bios -ErrorAction SilentlyContinue
mkdir emulators -ErrorAction SilentlyContinue
mkdir tools -ErrorAction SilentlyContinue
mkdir saves -ErrorAction SilentlyContinue

clear

echo "Installing, please stand by..."

#EmuDeck Download
Show-Notification -ToastTitle "Downloading EmuDeck files"
download "https://github.com/dragoonDorise/EmuDeck/archive/refs/heads/main.zip" "temp.zip"
moveFromTemp "temp\EmuDeck-main" "EmuDeck"
moveFromTemp "EmuDeck\roms" "roms"




#
#We download all the emulators
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
download $url_xemu "xemu.zip"
moveFromTemp "xemu-win-release" "emulators\xemu"
#Yuzu
Show-Notification -ToastTitle 'Downloading Yuzu'
download $url_yuzu "yuzu.zip"
moveFromTemp "yuzu\yuzu-windows-msvc" "emulators\yuzu"
#Citra
#download "https://github.com/citra-emu/citra-web/releases/download/1.0/citra-setup-windows.exe" "citra.exe"
#Duckstation
Show-Notification -ToastTitle 'Downloading DuckStation'
download $url_duck "duckstation.zip"
moveFromTemp "duckstation" "emulators\duckstation"
#Cemu
Show-Notification -ToastTitle 'Downloading Cemu'
download $url_cemu "cemu.zip"
moveFromTemp "cemu\cemu_1.26.2" "emulators\cemu"
#Xenia
Show-Notification -ToastTitle 'Downloading Xenia'
download $url_xenia "xenia.zip"
moveFromTemp "xenia" "emulators\xenia"
#Xemu
Show-Notification -ToastTitle 'Downloading Xemu'
download $url_xemu "xemu.zip"
moveFromTemp "xemu" "emulators\xemu"
#SRM
Show-Notification -ToastTitle 'Downloading Steam Rom Manager'
download $url_srm "tools/srm.exe"
#ESDE
Show-Notification -ToastTitle 'Downloading EmulationStation DE'
download $url_esde "esde.zip"
moveFromTemp "esde\EmulationStation-DE" "tools/EmulationStation-DE"
#We wait for winrar to finish

Show-Notification -ToastTitle 'Cleaning up...'
moveFromTemp "ra\RetroArch-Win64" "emulators\retroarch"
moveFromTemp "pcsx2\PCSX2 1.6.0" "emulators\pcsx2"
moveFromTemp "rpcs3" "emulators\rpcs3"
moveFromTemp "dolphin\Dolphin-x64" "emulators\dolphin"
rmdir cemu
rmdir ra
rmdir dolphin
rmdir esde
rmdir pcsx2
rmdir yuzu
rmdir temp

#Emulators config
Show-Notification -ToastTitle 'Configuring Emulators'
$userFolder = $env:USERPROFILE
$dolphinDir = -join($userFolder,'\Documents\Dolphin Emulator\Config')
$duckDir = -join($userFolder,'\Documents\DuckStation')
$yuzuDir = -join($userFolder,'\AppData\Roaming\yuzu')
$dolphinIni=-join($dolphinDir,'\Dolphin.ini')
$YuzuIni=-join($dolphinDir,'\qt-config.ini')
$duckIni=-join($duckDir,'\settings.ini')
$deckPath="/run/media/mmcblk0p1"
$raConfigDir=-join($winPath,'\Emulation\emulators\retroarch\')

#To do

#moveFromTemp "EmuDeck\configs\org.citra_emu.citra" "XXXX"
#moveFromTemp "EmuDeck\configs\org.ryujinx.Ryujinx" "XXXX"

moveFromTemp "EmuDeck\configs\org.DolphinEmu.dolphin-emu\config\dolphin-emu" $dolphinDir
moveFromTemp "EmuDeck\configs\info.cemu.Cemu\data\cemu" "emulators\cemu"
moveFromTemp "EmuDeck\configs\org.libretro.RetroArch\config\retroarch" "emulators\retroarch"
moveFromTemp "EmuDeck\configs\net.pcsx2.PCSX2\config\PCSX2" "emulators\pcsx2"
moveFromTemp "EmuDeck\configs\net.rpcs3.RPCS3\config\rpcs3" "emulators\rpcs3"
moveFromTemp "EmuDeck\configs\org.duckstation.DuckStation\data\duckstation" $duckDir
moveFromTemp "EmuDeck\configs\steam-rom-manager" "tools"
moveFromTemp "EmuDeck\configs\org.yuzu_emu.yuzu" $yuzuDir
moveFromTemp "EmuDeck\configs\emulationstation" "tools\EmulationStation-DE\.emulationstation" 
moveFromTemp "EmuDeck\configs\app.xemu.xemu\data\xemu\xemu" "emulators\xemu"
moveFromTemp "EmuDeck\configs\xenia" "emulators\xenia"

$deckPath="/run/media/mmcblk0p1"

sedFile 'emulators\xemu\xemu.ini' $deckPath $winPath
sedFile 'emulators\xemu\xemu.toml' $deckPath $winPath
sedFile 'emulators\cemu\settings.xml' 'Z:/run/media/mmcblk0p1' $winPath
sedFile 'emulators\cemu\settings.xml' 'roms/wiiu/roms' 'roms\wiiu\'
sedFile $dolphinIni $deckPath $winPath
sedFile 'tools\userData\userConfigurations.json' 'Z:' ''
sedFile 'tools\userData\userConfigurations.json' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\.emulationstation\es_settings.xml' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\.emulationstation\custom_systems\es_systems.xml' '/usr/bin/bash /run/media/mmcblk0p1/Emulation/tools/launchers/cemu.sh' 'E:\Emulation\emulators\cemu\cemu.exe'
sedFile 'tools\EmulationStation-DE\.emulationstation\custom_systems\es_systems.xml' 'z:%' ''
sedFile 'emulators\pcsx2\inis\PCSX2_ui.ini' $deckPath $winPath
sedFile $YuzuIni $deckPath $winPath
sedFile $duckIni $deckPath $winPath

#RetroArch especial fixes
sedFile 'emulators\retroarch\retroarch.cfg' $deckPath $winPath
sedFile 'emulators\retroarch\retroarch.cfg' '~/.var/app/org.libretro.RetroArch/config/retroarch/' $raConfigDir
sedFile 'emulators\retroarch\retroarch.cfg' '/app/share/libretro/' ':'
sedFile 'emulators\retroarch\retroarch.cfg' '/"' '\"'
sedFile 'emulators\retroarch\retroarch.cfg' 'http://localhost:4404\' 'http://localhost:4404/'
sedFile 'emulators\retroarch\retroarch.cfg' '/app/lib/retroarch/filters/' '\app\lib\retroarch\filters\'
sedFile 'emulators\retroarch\retroarch.cfg' 'database/' 'database\'
sedFile 'emulators\retroarch\retroarch.cfg' 'http://buildbot.libretro.com/nightly/linux/x86_64/latest\' 'http://buildbot.libretro.com/nightly/linux/x86_64/latest/'
sedFile 'emulators\retroarch\retroarch.cfg' 'config/remaps' 'config\remaps'
sedFile 'emulators\retroarch\retroarch.cfg' '/Emulation/bios' '\Emulation\bios'
sedFile 'emulators\retroarch\retroarch.cfg' 'video4linux2' ''

#sedFile 'emulators\citra\qt-config.ini' $deckPath $winPath



Write-Host "All done!" -ForegroundColor green -BackgroundColor black