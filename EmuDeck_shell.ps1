##Requires -RunAsAdministrator
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
			del $output
		}
		if ($extn -eq ".7z" ){
			$dir = -join($output.replace('.7z',''), "\");
			WinRAR x -y $output $dir
			waitForWinRar
			del $output
		}
	}
	Write-Host "Done!" -ForegroundColor green -BackgroundColor black
}

function downloadCore($url, $output) {	
	$Path = Get-Location
	$Path = -join($Path,$output)
	$wc = New-Object net.webclient
	$wc.Downloadfile($url, $Path)  
	Expand-Archive $Path .\tools\EmulationStation-DE\Emulators\RetroArch\cores\ -Force
	del $Path	
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
	echo $echo
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

#Variables

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
$url_theme_epicnoir = "https://github.com/dragoonDorise/es-theme-epicnoir/archive/refs/heads/master.zip"

$userFolder = $env:USERPROFILE
$dolphinDir = -join($userFolder,'\Documents\Dolphin Emulator\Config')
$duckDir = -join($userFolder,'\Documents\DuckStation')
$yuzuDir = -join($userFolder,'\AppData\Roaming\yuzu')
$dolphinIni=-join($dolphinDir,'\Dolphin.ini')
$YuzuIni=-join($yuzuDir,'\qt-config.ini')
$duckIni=-join($duckDir,'\settings.ini')
$deckPath="/run/media/mmcblk0p1"
$raConfigDir=-join($winPath,'\Emulation\tools\EmulationStation-DE\Emulators\RetroArch\')
$raExe=-join($winPath,'\Emulation\\tools\\EmulationStation-DE\\Emulators\\RetroArch\\','retroarch.exe')
$dolphinDirBak = -join($dolphinDir,'_bak')
$duckDirBak = -join($duckDir,'_bak')
$yuzuDirBak = -join($yuzuDir,'_bak')


##### The real fun begins here!


Write-Host "Hi! Welcome to EmuDeck Windows Edition." -ForegroundColor blue -BackgroundColor black
echo ""
echo "This script will create an Emulation folder in $winPath"
echo "This folder will store your Emulators, Roms, Bios, EmulationStation and Steam Rom Manager."
Write-Host "If you want to install EmuDeck on another place, just move Emudeck.bat there now and open it again." -ForegroundColor red -BackgroundColor black
echo "Before you continue make sure you have WinRar installed"
echo "You can download Winrar from https://www.win-rar.com/download.html"
echo ""
waitForUser

clear
Show-Notification -ToastTitle 'Creating Backups of Dolphin, Yuzu and Duckstation configuration'
#Backup of non portable emulators config
if (Test-Path -Path $dolphinDirBak){
	echo ""
}
else {
	Copy-Item -Path $dolphinDir -Destination $dolphinDirBak -PassThru
}

if (Test-Path -Path $duckDirBak){
	echo ""
}
else {
	Copy-Item -Path $duckDir -Destination $duckDirBak -PassThru
}

if (Test-Path -Path $yuzuDirBak){
	echo ""
}
else {
	Copy-Item -Path $yuzuDir -Destination $yuzuDirBak -PassThru
}
Write-Host "Done!" -ForegroundColor green -BackgroundColor black

Start-Sleep -s 2

mkdir Emulation -ErrorAction SilentlyContinue
cd Emulation
mkdir bios -ErrorAction SilentlyContinue
mkdir tools -ErrorAction SilentlyContinue
mkdir saves -ErrorAction SilentlyContinue

clear


echo "Installing, please stand by..."
echo ""
#EmuDeck Download
Show-Notification -ToastTitle "Downloading EmuDeck files"
download "https://github.com/dragoonDorise/EmuDeck/archive/refs/heads/main.zip" "temp.zip"
moveFromTemp "temp\EmuDeck-main" "EmuDeck"
moveFromTemp "EmuDeck\roms" "roms"


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
#download "https://github.com/citra-emu/citra-web/releases/download/1.0/citra-setup-windows.exe" "citra.exe"
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

#ESDE Themes
Show-Notification -ToastTitle 'Downloading Epic Noir Theme'
download $url_theme_epicnoir "epicnoir.zip"
moveFromTemp "epicnoir\es-theme-epicnoir-master" "tools\EmulationStation-DE\themes\es-epicnoir"

Show-Notification -ToastTitle 'Cleaning up...'
moveFromTemp "ra\RetroArch-Win64" "tools\EmulationStation-DE\Emulators\RetroArch"
moveFromTemp "pcsx2\PCSX2 1.6.0" "tools\EmulationStation-DE\Emulators\PCSX2"
moveFromTemp "rpcs3" "tools\EmulationStation-DE\Emulators\RPCS3"
moveFromTemp "dolphin\Dolphin-x64" "tools\EmulationStation-DE\Emulators\Dolphin-x64"
rmdir cemu
rmdir ra
rmdir dolphin
rmdir esde
rmdir pcsx2
rmdir yuzu
rmdir temp
rmdir epicnoir
Write-Host "Done!" -ForegroundColor green -BackgroundColor black
#Emulators config
Show-Notification -ToastTitle 'Configuring Emulators'


#moveFromTemp "EmuDeck\configs\org.citra_emu.citra" "XXXX"
#moveFromTemp "EmuDeck\configs\org.ryujinx.Ryujinx" "XXXX"

moveFromTemp "EmuDeck\configs\org.DolphinEmu.dolphin-emu\config\dolphin-emu" $dolphinDir
moveFromTemp "EmuDeck\configs\info.cemu.Cemu\data\cemu" "tools\EmulationStation-DE\Emulators\cemu"
moveFromTemp "EmuDeck\configs\org.libretro.RetroArch\config\retroarch" "tools\EmulationStation-DE\Emulators\RetroArch"
moveFromTemp "EmuDeck\configs\net.pcsx2.PCSX2\config\PCSX2" "tools\EmulationStation-DE\Emulators\PCSX2"
moveFromTemp "EmuDeck\configs\net.rpcs3.RPCS3\config\rpcs3" "tools\EmulationStation-DE\Emulators\RPCS3"
moveFromTemp "EmuDeck\configs\org.duckstation.DuckStation\data\duckstation" $duckDir
moveFromTemp "EmuDeck\configs\steam-rom-manager" "tools"
moveFromTemp "EmuDeck\configs\org.yuzu_emu.yuzu" $yuzuDir
#moveFromTemp "EmuDeck\configs\emulationstation" "tools\EmulationStation-DE\.emulationstation"
moveFromTemp "EmuDeck\configs\app.xemu.xemu\data\xemu\xemu" "tools\EmulationStation-DE\Emulators\xemu"
moveFromTemp "EmuDeck\configs\xenia" "tools\EmulationStation-DE\Emulators\xenia"
mkdir tools\EmulationStation-DE\.emulationstation\  -ErrorAction SilentlyContinue
copy EmuDeck\configs\emulationstation\es_settings.xml tools\EmulationStation-DE\.emulationstation\es_settings.xml
Write-Host "Done!" -ForegroundColor green -BackgroundColor black

Show-Notification -ToastTitle 'Applying Windows Especial configurations'
sedFile 'tools\EmulationStation-DE\Emulators\xemu\xemu.ini' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\Emulators\xemu\xemu.toml' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\Emulators\cemu\settings.xml' 'Z:/run/media/mmcblk0p1' $winPath
sedFile 'tools\EmulationStation-DE\Emulators\cemu\settings.xml' 'roms/wiiu/roms' 'roms\wiiu\'
sedFile $dolphinIni $deckPath $winPath
sedFile 'tools\EmulationStation-DE\Emulators\PCSX2\inis\PCSX2_ui.ini' $deckPath $winPath
sedFile $YuzuIni $deckPath $winPath
sedFile $duckIni $deckPath $winPath


#SRM
sedFile 'tools\userData\userConfigurations.json' 'Z:' ''
sedFile 'tools\userData\userConfigurations.json' $deckPath $winPath
sedFile 'tools\userData\userConfigurations.json' '/home/deck/.steam/steam' 'C:\\Program Files (x86)\\Steam'
sedFile 'tools\userData\userConfigurations.json' 'run org.libretro.RetroArch' $raExe

#ESDE
sedFile 'tools\EmulationStation-DE\.emulationstation\es_settings.xml' $deckPath $winPath
sedFile 'tools\EmulationStation-DE\.emulationstation\es_settings.xml' '/Emulation/roms/' 'Emulation\roms\'

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


Show-Notification -ToastTitle 'Downloading RetroArch Cores'
mkdir "tools\EmulationStation-DE\Emulators\RetroArch\cores"  -ErrorAction SilentlyContinue

$RAcores = @('a5200_libretro.dll','81_libretro.dll','atari800_libretro.dll','bluemsx_libretro.dll','chailove_libretro.dll','fbneo_libretro.dll','freechaf_libretro.dll','freeintv_libretro.dll','fuse_libretro.dll','gearsystem_libretro.dll','gw_libretro.dll','hatari_libretro.dll','lutro_libretro.dll','mednafen_pcfx_libretro.dll','mednafen_vb_libretro.dll','mednafen_wswan_libretro.dll','mu_libretro.dll','neocd_libretro.dll','nestopia_libretro.dll','nxengine_libretro.dll','o2em_libretro.dll','picodrive_libretro.dll','pokemini_libretro.dll','prboom_libretro.dll','prosystem_libretro.dll','px68k_libretro.dll','quasi88_libretro.dll','scummvm_libretro.dll','squirreljme_libretro.dll','theodore_libretro.dll','uzem_libretro.dll','vecx_libretro.dll','vice_xvic_libretro.dll','virtualjaguar_libretro.dll','x1_libretro.dll','mednafen_lynx_libretro.dll','mednafen_ngp_libretro.dll','mednafen_pce_libretro.dll','mednafen_pce_fast_libretro.dll','mednafen_psx_libretro.dll','mednafen_psx_hw_libretro.dll','mednafen_saturn_libretro.dll','mednafen_supafaust_libretro.dll','mednafen_supergrafx_libretro.dll','blastem_libretro.dll','bluemsx_libretro.dll','bsnes_libretro.dll','bsnes_mercury_accuracy_libretro.dll','cap32_libretro.dll','citra2018_libretro.dll','citra_libretro.dll','crocods_libretro.dll','desmume2015_libretro.dll','desmume_libretro.dll','dolphin_libretro.dll','dosbox_core_libretro.dll','dosbox_pure_libretro.dll','dosbox_svn_libretro.dll','fbalpha2012_cps1_libretro.dll','fbalpha2012_cps2_libretro.dll','fbalpha2012_cps3_libretro.dll','fbalpha2012_libretro.dll','fbalpha2012_neogeo_libretro.dll','fceumm_libretro.dll','fbneo_libretro.dll','flycast_libretro.dll','fmsx_libretro.dll','frodo_libretro.dll','gambatte_libretro.dll','gearboy_libretro.dll','gearsystem_libretro.dll','genesis_plus_gx_libretro.dll','genesis_plus_gx_wide_libretro.dll','gpsp_libretro.dll','handy_libretro.dll','kronos_libretro.dll','mame2000_libretro.dll','mame2003_plus_libretro.dll','mame2010_libretro.dll','mame_libretro.dll','melonds_libretro.dll','mesen_libretro.dll','mesen-s_libretro.dll','mgba_libretro.dll','mupen64plus_next_libretro.dll','nekop2_libretro.dll','np2kai_libretro.dll','nestopia_libretro.dll','parallel_n64_libretro.dll','pcsx2_libretro.dll','pcsx_rearmed_libretro.dll','picodrive_libretro.dll','ppsspp_libretro.dll','puae_libretro.dll','quicknes_libretro.dll','race_libretro.dll','sameboy_libretro.dll','smsplus_libretro.dll','snes9x2010_libretro.dll','snes9x_libretro.dll','stella2014_libretro.dll','stella_libretro.dll','tgbdual_libretro.dll','vbam_libretro.dll','vba_next_libretro.dll','vice_x128_libretro.dll','vice_x64_libretro.dll','vice_x64sc_libretro.dll','vice_xscpu64_libretro.dll','yabasanshiro_libretro.dll','yabause_libretro.dll','bsnes_hd_beta_libretro.dll','swanstation_libretro.dll')
$RAcores.count

foreach ( $core in $RAcores )
{
	$url= -join('http://buildbot.libretro.com/nightly/windows/x86_64/latest/',$core,'.zip')
	$dest= -join('\tools\EmulationStation-DE\Emulators\RetroArch\cores\',$core,'.zip')
	downloadCore $url $dest
}

Write-Host "All done!" -ForegroundColor green -BackgroundColor black