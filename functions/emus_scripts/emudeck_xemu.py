from core.all import *
from pathlib import Path
import requests
import zipfile


def xemu_install():
    set_msg("Installing Xemu")

    if system == "linux":
        name = "xemu"
        type = "flatpak"
        look_for = ""
        destination = f"{emus_folder}"

    elif system.startswith("win"):
        name = "xemu"
        type = "zip"
        look_for = "windows-x86_64.zip"
        destination = f"{emus_folder}/xemu"

    elif system == "darwin":
        name = "xemu"
        type = "zip"
        look_for = "macos-universal"
        destination = f"{emus_folder}"

    try:
        if system == "linux":
            repo = "app.xemu.xemu"
        else:
            repo = get_latest_release_gh("xemu-project/xemu", type, look_for)

        install_emu(name, repo, type, destination)
        return True

    except Exception as e:
        print(f"Error during install: {e}")
        return False


def xemu_uninstall():
    try:
        if system == "linux":
            uninstall_emu("app.xemu.xemu", "flatpak")
        elif system.startswith("win"):
            uninstall_emu("xemu", "dir")
        elif system == "darwin":
            uninstall_emu("xemu", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False


def xemu_is_installed():
    if system == "linux":
        return is_flatpak_installed("app.xemu.xemu")
    if system.startswith("win"):
        return (emus_folder / "xemu" / "xemu.exe").exists()
    if system == "darwin":
        return (emus_folder / "xemu.app").exists()


def xemu_init():
    set_msg("Setting up xemu")
    flush_emulator_launchers("xemu")

    if system == "linux":
        destination = f"{home}/.var/app/app.xemu.xemu/data/xemu/xemu"
    elif system.startswith("win"):
        destination = f"{emus_folder}/xemu/"
    elif system == "darwin":
        destination = f"{home}/Library/Application Support/xemu"

    copy_setting_dir("common/xemu/", destination)
    copy_and_set_settings_file("common/xemu/xemu.toml", destination)

    xemu_setup_storage()
    xemu_set_resolution()
    xemu_widescreen()
    xemu_set_language()


def xemu_install_init():
    xemu_install()
    xemu_init()


XEMU_LANGUAGES = {
    "en": 1, "ja": 2, "de": 3, "fr": 4, "es": 5,
    "it": 6, "ko": 7, "zh": 8, "pt": 9,
}

XEMU_EEPROM_LANGUAGE_OFFSET = 0x90


def xemu_set_language() -> bool:
    eeprom_path = Path(storage_path) / "xemu" / "eeprom.bin"

    if not eeprom_path.is_file():
        return False

    language = get_system_language()

    if language not in XEMU_LANGUAGES:
        return False

    with open(eeprom_path, "r+b") as f:
        f.seek(XEMU_EEPROM_LANGUAGE_OFFSET)
        f.write(bytes([XEMU_LANGUAGES[language]]))

    return True


def xemu_setup_storage():
    dest_dir = Path(storage_path) / "xemu"
    dest_dir.mkdir(parents=True, exist_ok=True)

    if system == "linux":
        subprocess.run(
            [
                "flatpak", "override", "--user",
                "app.xemu.xemu",
                f"--filesystem={str(emulation_path)}:rw",
            ],
            check=True
        )

    url = "https://github.com/mborgerson/xemu-hdd-image/releases/latest/download/xbox_hdd.qcow2.zip"
    zip_path = dest_dir / "xbox_hdd.qcow2.zip"

    r = requests.get(url, stream=True, timeout=30)
    r.raise_for_status()
    with open(zip_path, "wb") as f:
        for chunk in r.iter_content(8192):
            f.write(chunk)

    with zipfile.ZipFile(zip_path, "r") as zf:
        for info in zf.infolist():
            if info.is_dir():
                continue
            out_file = dest_dir / Path(info.filename).name
            with zf.open(info) as src, open(out_file, "wb") as dst:
                dst.write(src.read())

    zip_path.unlink(missing_ok=True)
    return True


def xemu_set_resolution():
    if system == "linux":
        config_path = f"{home}/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
    if system.startswith("win"):
        config_path = f"{emus_folder}/xemu/xemu.toml"
    if system == "darwin":
        config_path = f"{home}/Library/Application Support/xemu/xemu.toml"

    resolution_map = {
        "720P": 1,
        "1080P": 2,
        "1440P": 3,
        "4K": 5,
    }

    resolution = settings.resolutions.xemu
    multiplier = resolution_map.get(resolution, 1)

    if resolution == "4K" and system == "linux" and get_screen_width() < 3840:
        multiplier = 2

    config_file = Path(config_path)
    lines = config_file.read_text().splitlines()
    setting = f"surface_scale = {multiplier}"

    for index, line in enumerate(lines):
        if line.startswith("surface_scale ="):
            lines[index] = setting
            break
    else:
        for index, line in enumerate(lines):
            if line == "[display.quality]":
                lines.insert(index + 1, setting)
                break
        else:
            lines.extend(["", "[display.quality]", setting])

    config_file.write_text("\n".join(lines) + "\n")
    return True


def xemu_widescreen():
    if settings.ar.classic3d == "169":
        xemu_widescreen_on()
    else:
        xemu_widescreen_off()


def xemu_widescreen_on():
    if system == "linux":
        config_path = f"{home}/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
    elif system.startswith("win"):
        config_path = f"{emus_folder}/xemu/xemu.toml"
    elif system == "darwin":
        config_path = f"{home}/Library/Application Support/xemu/xemu.toml"

    set_config("fit", "'scale_16_9'", config_path, separator=" = ")


def xemu_widescreen_off():
    if system == "linux":
        config_path = f"{home}/.var/app/app.xemu.xemu/data/xemu/xemu/xemu.toml"
    elif system.startswith("win"):
        config_path = f"{emus_folder}/xemu/xemu.toml"
    elif system == "darwin":
        config_path = f"{home}/Library/Application Support/xemu/xemu.toml"

    set_config("fit", "'scale_4_3'", config_path, separator=" = ")