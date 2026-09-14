from core.all import *
import re
import requests
from pathlib import Path

def ppsspp_install():
    set_msg(f"Installing ppsspp")

    if system == "linux":
        name="PPSSPP"
        type="flatpak"
        destination = f"{emus_folder}"
        repo="org.ppsspp.PPSSPP"

    if system.startswith("win"):
        name = "ppsspp"
        type = "zip"
        destination = f"{emus_folder}/ppsspp"

        repo = get_latest_release_gh(
            repository="hrydgard/ppsspp",
            fileType=".zip",
            fileNameContains="Windows-x64"
        ) or "https://www.ppsspp.org/files/1_20_1/ppsspp_win.zip"

    if system == "darwin":
        name="ppsspp"
        type="dmg"
        destination = f"{emus_folder}"
        repo="https://www.ppsspp.org/files/1_20_1/PPSSPP_macOS.dmg"

    try:
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def ppsspp_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.ppsspp.PPSSPP", "flatpak")
        if system.startswith("win"):
          uninstall_emu("ppsspp", "dir")
        if system == "darwin":
          uninstall_emu("PPSSPPDL", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def ppsspp_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.ppsspp.PPSSPP")
    if system.startswith("win"):
      return (emus_folder / "ppsspp" / "PPSSPPWindows64.exe").exists()
    if system == "darwin":
      return (emus_folder / "PPSSPPDL.app").exists()


def ppsspp_config_dir():
    if system == "linux":
        return Path(f"{home}/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SYSTEM")
    if system.startswith("win"):
        return Path(f"{emus_folder}/ppsspp/memstick/PSP/SYSTEM")
    if system == "darwin":
        return Path(f"{home}/Library/Application Support/PPSSPP/PSP/SYSTEM")


def ppsspp_config_file():
    return ppsspp_config_dir() / "ppsspp.ini"


def ppsspp_token_file():
    return ppsspp_config_dir() / "ppsspp_retroachievements.dat"


def ppsspp_init():
    set_msg(f"Setting up ppsspp")
    flush_emulator_launchers("ppsspp")

    destination = ppsspp_config_dir()
    destination.mkdir(parents=True, exist_ok=True)

    if system.startswith("win"):
        copy_setting_dir(f"{system}/ppsspp/", f"{emus_folder}/ppsspp/")
        copy_and_set_settings_file(f"{system}/ppsspp/memstick/PSP/SYSTEM/ppsspp.ini", destination)
    else:
        copy_setting_dir(f"{system}/ppsspp/", destination)
        copy_and_set_settings_file(f"{system}/ppsspp/ppsspp.ini", destination)

    ppsspp_set_emulation_folder()
    ppsspp_setup_saves()
    ppsspp_set_resolution()
    ppsspp_retro_achievements()

def ppsspp_install_init():
    ppsspp_install()
    ppsspp_init()


def ppsspp_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/SAVEDATA"
        origin_states=f"{home}/.var/app/org.ppsspp.PPSSPP/config/ppsspp/PSP/PPSSPP_STATE"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/ppsspp/memstick/SAVEDATA"
        origin_states=f"{emus_folder}/ppsspp/memstick/PPSSPP_STATE"
    if system == "darwin":
        origin_saves=f"{home}/.config/ppsspp/PSP/SAVEDATA"
        origin_states=f"{home}/.config/ppsspp/PSP/PPSSPP_STATE"

    move_contents_and_link(origin_saves,f"{saves_path}/ppsspp/saves")
    move_contents_and_link(origin_states,f"{saves_path}/ppsspp/states")


def ppsspp_set_emulation_folder() -> bool:
    config_file = ppsspp_config_file()

    if not config_file.is_file():
        return False

    set_ini_value(config_file, "General", "CurrentDirectory", f"{roms_path}/psp")

    return True


def ppsspp_set_resolution():
    config_path = ppsspp_config_file()

    resolution_map = {
        "720P": 3,
        "1080P": 4,
        "1440P": 5,
        "4K": 6,
    }

    multiplier = resolution_map.get(settings.resolutions.ppsspp, 3)

    if settings.resolutions.ppsspp == "4K" and system == "linux" and get_screen_width() < 3840:
        multiplier = 4

    set_config("InternalResolution", multiplier, Path(config_path), " = ")

    return True
    
    
def ppsspp_retro_achievements():
    if settings.achievements.user == '':
        ppsspp_retro_achievements_off()
    else:
        ppsspp_retro_achievements_on()


def ppsspp_retro_achievements_on():
    config_path = ppsspp_config_file()
    token_path = ppsspp_token_file()

    set_config("AchievementsEnable", "True", config_path, " = ")
    set_config("AchievementsUserName", f"{achievements_user}", config_path, " = ")

    token_path.parent.mkdir(parents=True, exist_ok=True)
    token_path.write_text(achievements_token)

    if achievements_hardcore:
        set_config("AchievementsChallengeMode", "True", config_path, " = ")
    else:
        set_config("AchievementsChallengeMode", "False", config_path, " = ")


def ppsspp_retro_achievements_off():
    config_path = ppsspp_config_file()
    token_path = ppsspp_token_file()

    set_config("AchievementsEnable", "False", config_path, " = ")
    set_config("AchievementsChallengeMode", "False", config_path, " = ")

    token_path.parent.mkdir(parents=True, exist_ok=True)
    token_path.write_text("")