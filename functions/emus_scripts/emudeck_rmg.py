from core.all import *


def rmg_install():
    set_msg(f"Installing rmg")

    if system == "linux":
        name="RMG"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"
        repo="com.github.Rosalie241.RMG"

    if system.startswith("win"):
        return False;

    if system == "darwin":
        return False;

    try:
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def rmg_uninstall():
    try:
        if system == "linux":
            uninstall_emu("com.github.Rosalie241.RMG", "flatpak")
        if system.startswith("win"):
          uninstall_emu("rmg", "dir")
        if system == "darwin":
          uninstall_emu("rmg", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def rmg_is_installed():
    if system == "linux":
        return is_flatpak_installed("com.github.Rosalie241.RMG")
    if system.startswith("win"):
      return (emus_folder / "rmg" / "rmg.exe").exists()
    if system == "darwin":
      return (emus_folder / "rmg.app").exists()


def rmg_init():
    set_msg(f"Setting up RMG")
    flush_emulator_launchers("rosaliesmupengui")
    if system == "linux":
        destination=f"{home}/.var/app/com.github.Rosalie241.RMG/config/RMG/"
    if system.startswith("win"):
        destination=f"{emus_folder}/rmg/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/rmg"

    copy_setting_dir(f"{system}/rmg/",destination)
    copy_and_set_settings_file(f"{system}/rmg/mupen64plus.cfg", destination)

    rmg_setup_storage()
    rmg_set_emulation_folder()
    rmg_setup_saves()
    rmg_set_resolution()
    rmg_set_controller_style()
    esde_set_emu("Rosalie's Mupen GUI (Standalone)","n64")
    rmg_add_custom_parser()

def rmg_install_init():
    rmg_install()
    rmg_init()


def rmg_add_custom_parser():
    if rmg_is_installed() and srm_is_installed():
       add_parser("nintendo_64_rmg")

def rmg_config_paths():
    if system == "linux":
        base = Path(f"{home}/.var/app/com.github.Rosalie241.RMG/config/RMG")
    if system.startswith("win"):
        base = Path(f"{emus_folder}/rmg")
    if system == "darwin":
        base = Path(f"{home}/Library/Application Support/rmg")
    return base / "mupen64plus.cfg", base / "GLideN64.ini"


def rmg_set_emulation_folder():
    config_file, _ = rmg_config_paths()

    set_config("Directory", f"{roms_path}/n64", config_file, " = ")
    set_config("64DD_AmericanIPL", f"{bios_path}/64DD_IPL_US.n64", config_file, " = ")
    set_config("64DD_JapaneseIPL", f"{bios_path}/64DD_IPL_JP.n64", config_file, " = ")
    set_config("64DD_DevelopmentIPL", f"{bios_path}/64DD_IPL_DEV.n64", config_file, " = ")

    return True


def rmg_setup_saves():
    config_file, _ = rmg_config_paths()

    Path(f"{saves_path}/RMG/saves").mkdir(parents=True, exist_ok=True)
    Path(f"{saves_path}/RMG/states").mkdir(parents=True, exist_ok=True)

    set_config("SaveSRAMPath", f"{saves_path}/RMG/saves", config_file, " = ")
    set_config("SaveStatePath", f"{saves_path}/RMG/states", config_file, " = ")

    return True


def rmg_setup_storage():
    config_file, gliden_file = rmg_config_paths()

    Path(f"{storage_path}/RMG/cache").mkdir(parents=True, exist_ok=True)
    Path(f"{storage_path}/RMG/HiResTextures").mkdir(parents=True, exist_ok=True)
    Path(f"{storage_path}/RMG/screenshots").mkdir(parents=True, exist_ok=True)

    set_config("textureFilter\\txHiresEnable", "1", gliden_file)
    set_config("textureFilter\\txPath", f"{storage_path}/RMG/HiResTextures", gliden_file)
    set_config("textureFilter\\txCachePath", f"{storage_path}/RMG/cache", gliden_file)

    set_config("ScreenshotPath", f"{storage_path}/RMG/screenshots", config_file, " = ")

    if system == "linux":
        data_dir = f"{home}/.var/app/com.github.Rosalie241.RMG/data/RMG"
        cache_dir = f"{home}/.var/app/com.github.Rosalie241.RMG/cache/RMG"
        set_config("UserDataDirectory", f'"{data_dir}"', config_file, " = ")
        set_config("UserCacheDirectory", f'"{cache_dir}"', config_file, " = ")

    return True


def rmg_set_resolution():
    print("NYI")

def rmg_set_abxy_style():
    print("NYI")

def rmg_set_bayx_style():
    print("NYI")

def rmg_set_controller_style():
    if settings.controllerLayout == "bayx":
        rmg_set_bayx_style()
    else:
        rmg_set_bayx_style()