import os, json, platform
from pathlib import Path
from types import SimpleNamespace

system = platform.system().lower()  # 'linux', 'darwin', 'windows'
#system = "linux"
home = Path.home()
emudeck_backend = home / ".config/EmuDeck/backend"
emudeck_folder = home / ".config/EmuDeck"
emudeck_logs = home / ".config/EmuDeck/logs/"
temp_dir=home/"Downloads"
app_folder=home/"Applications"
emus_folder=app_folder
esde_folder=app_folder
pegasus_folder=app_folder
progress_bar=0
apple_chip = "arm64"  # or "arm64" on Apple Silicon


#Windows vars
if system.startswith("win"):
    appdata_roaming = Path(os.environ.get("APPDATA"))
    emudeck_backend = Path(os.path.expandvars(appdata_roaming / "EmuDeck/backend"))
    emudeck_folder = Path(os.path.expandvars(appdata_roaming / "EmuDeck"))
    emudeck_logs =  Path(os.path.expandvars(appdata_roaming / "EmuDeck/logs"))
    emudeck_temp = Path(os.path.expandvars(appdata_roaming / "EmuDeck/temp"))
    app_folder=Path(os.path.expandvars(emudeck_folder / "Emulators"))
    emus_folder=Path(os.path.expandvars(app_folder))
    esde_folder=Path(os.path.expandvars(emudeck_folder / "EmulationStation-DE"))
    pegasus_folder=Path(os.path.expandvars(emudeck_folder / "Pegasus"))

json_settings_path = Path(emudeck_folder) / "settings.json"
if json_settings_path.exists():
    with open(json_settings_path, encoding='utf-8') as jf:
        # Aquí json.load lee y va aplicando object_hook a cada dict
        settings = json.load(jf, object_hook=lambda d: SimpleNamespace(**d))

        install_emus=settings.installEmus
        overwrite_config_emus=settings.overwriteConfigEmus
        install_frontends=settings.installFrontends


        RABezels=settings.bezels
        RAautoSave=settings.autosave
        arClassic3D=settings.ar.classic3d
        arDolphin=settings.ar.dolphin
        arSega=settings.ar.sega
        arSnes=settings.ar.snes
        RAHandClassic2D=settings.shaders.classic
        RAHandClassic3D=settings.shaders.classic3d
        RAHandHeldShader=settings.shaders.handhelds
        controllerLayout=settings.controllerLayout

        cloud_sync_status=settings.cloudSyncStatus

        emuGBA=settings.emulatorAlternative.gba
        emuMAME=settings.emulatorAlternative.mame
        #emuMULTI=settings.emulatorAlternative.multiemulator
        emuN64=settings.emulatorAlternative.n64
        emuNDS=settings.emulatorAlternative.nds
        emuPSP=settings.emulatorAlternative.psp
        emuPSX=settings.emulatorAlternative.psx
        emuDreamcast=settings.emulatorAlternative.dreamcast
        emuSCUMMVM=settings.emulatorAlternative.scummvm


        installationPath=settings.storagePath



        emulation_path=Path(os.path.expandvars(installationPath+"/Emulation"))
        roms_path=Path(os.path.expandvars(installationPath+"/Emulation/roms"))
        tools_path=Path(os.path.expandvars(installationPath+"/Emulation/tools"))
        bios_path=Path(os.path.expandvars(installationPath+"/Emulation/bios"))
        saves_path=Path(os.path.expandvars(installationPath+"/Emulation/saves"))
        storage_path=Path(os.path.expandvars(installationPath+"/Emulation/storage"))
        ESDEscrapData=Path(os.path.expandvars(installationPath+"/Emulation/tools/downloaded_media"))

        esde_theme_url="https://github.com/anthonycaccese/epic-noir-revisited-es-de.git"
        esde_theme_name=settings.themeESDE
        pegasusThemeUrl=settings.themePegasus[0]
        pegasusThemeName=settings.themePegasus[1]
        achievementsUser=settings.achievements.user
        achievementsUserToken=settings.achievements.token
        achievementsHardcore=settings.achievements.hardcore


        androidStorage=None
        androidstorage_path=None
        androidInstallRA=True
        androidInstallDolphin=True
        androidInstallPPSSPP=True
        androidInstallCitraMMJ=None
        androidInstallLime3DS=True
        androidInstallNetherSX2=True
        androidInstallScummVM=True
        androidSetupRA=True
        androidSetupDolphin=True
        androidSetupPPSSPP=True
        androidSetupCitraMMJ=None
        androidSetupLime3DS=True
        androidSetupNetherSX2=None
        androidSetupScummVM=True
        androidInstallESDE=False
        androidInstallPegasus=True
        androidRABezels=True

        #Se crean desde fuera del setup
        #rclone_provider="Emudeck-cloud"
        cs_user="csEC2D3ED74AF3/"
        cloud_sync_provider="Emudeck-cloud"

else:
    settings = ""  # o lo que quieras por defecto

cloud_sync_bin = tools_path / "rclone" / "rclone"

if system.startswith("win"):
    cloud_sync_bin = tools_path / "rclone" / "rclone.exe"

if system == "linux":
    srm_path=f"{home}/.config/Steam Rom Manager"
if system.startswith("win"):
    srm_path=f"{tools_path}/"
if system == "darwin":
    srm_path=f"{home}/Library/Application Support/steam-rom-manager"


def get_steam_paths():
    import winreg
    reg_path = r"Software\Valve\Steam"
    with winreg.OpenKey(winreg.HKEY_CURRENT_USER, reg_path) as key:
        steam_install_path = winreg.QueryValueEx(key, "SteamPath")[0]
    steam_install_path = steam_install_path.replace("/", "\\")

    steam_install_path_srm = steam_install_path.replace("\\", "\\\\")

    steam_exe = os.path.join(steam_install_path, "Steam.exe")

    return steam_install_path, steam_install_path_srm, steam_exe

steam_install_path=f"{home}/.steam/steam"

if system.startswith("win"):
    steam_install_path, steam_install_path_srm, steam_exe = get_steam_paths()

if system.startswith("darwin"):
    steam_install_path=f"{home}/Library/Application Support/Steam/"
