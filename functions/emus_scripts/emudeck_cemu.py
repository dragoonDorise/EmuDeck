from core.all import *


def cemu_install():
    set_msg(f"Installing Cemu")

    if system == "linux":
        type="AppImage"
        look_for=""
        destination = emus_folder
        name="Cemu"

    if system.startswith("win"):
        type="zip"
        look_for="windows-x64"
        destination = f"{emus_folder}/cemu"
        name="cemu"

    if system == "darwin":
        type="dmg"
        look_for="macos"
        destination = emus_folder
        name="Cemu"

    try:
        repo=get_latest_release_gh("cemu-project/Cemu",type,look_for)
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def cemu_uninstall():
    try:
        if system == "linux":
            uninstall_emu("Cemu", "AppImage")
        if system.startswith("win"):
          uninstall_emu("cemu", "dir")
        if system == "darwin":
          uninstall_emu("Cemu", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def cemu_is_installed():
    if system == "linux":
        return (emus_folder / "Cemu.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "cemu" / "cemu.exe").exists()
    if system == "darwin":
      return (emus_folder / "Cemu.app").exists()


def cemu_init():
    set_msg(f"Setting up cemu")
    flush_emulator_launchers("cemu")
    if system == "linux":
        destination=f"{home}/.config/Cemu"
        settings_file_src=f"{system}/cemu/settings.xml"
    if system.startswith("win"):
        destination=f"{emus_folder}/cemu"
        settings_file_src=f"{system}/cemu/settings.xml"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/Cemu/"
        settings_file_src=f"{system}/Cemu/settings.xml"

    copy_setting_dir(f"{system}/cemu/",destination)

    copy_and_set_settings_file(settings_file_src, destination)

    #plugins_install_steamdeck_gyro_dsu()
    cemu_setup_saves()
    cemu_setup_storage()
    cemu_set_resolution()
    cemu_set_controller_style()
    cemu_set_language()

def cemu_install_init():
    cemu_install()
    cemu_init()


CEMU_LANGUAGES = {
    "ja": 0, "en": 1, "fr": 2, "de": 3, "it": 4, "es": 5,
    "zh": 6, "ko": 7, "nl": 8, "pt": 9, "ru": 10, "tw": 11,
}


def cemu_set_language() -> bool:
    if system == "linux":
        settings_file = f"{home}/.config/Cemu/settings.xml"
    if system.startswith("win"):
        settings_file = f"{emus_folder}/cemu/settings.xml"
    if system == "darwin":
        settings_file = f"{home}/Library/Application Support/Cemu/settings.xml"

    settings_path = Path(settings_file)

    if not settings_path.is_file():
        return False

    language = get_system_language()

    if language not in CEMU_LANGUAGES:
        return False

    text = settings_path.read_text(encoding="utf-8")
    new_tag = f"<console_language>{CEMU_LANGUAGES[language]}</console_language>"

    if re.search(r"<console_language>[^<]*</console_language>", text):
        text = re.sub(r"<console_language>[^<]*</console_language>", new_tag, text)
    else:
        text = text.replace("</content>", f"\t{new_tag}\n</content>")

    settings_path.write_text(text, encoding="utf-8")

    return True


def cemu_setup_saves():
    if system == "linux":
        origin_saves=f"{roms_path}/wiiu/mlc01/usr/save"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/cemu/mlc01/usr/save"
    if system == "darwin":
        origin_saves=f"{home}/Library/Application Support/Cemu/mlc01/usr/save"

    move_contents_and_link(origin_saves,f"{saves_path}/Cemu/saves")

def cemu_setup_storage():
    print("NYI")

def cemu_set_resolution():
    print("NYI")

def cemu_set_abxy_style():
    print("NYI")

def cemu_set_bayx_style():
    print("NYI")

def cemu_set_controller_style():
    if settings.controllerLayout == "bayx":
        cemu_set_bayx_style()
    else:
        cemu_set_bayx_style()

def cemu_config_dir():
    if system == "linux":
        return f"{home}/.config/Cemu"
    if system.startswith("win"):
        return f"{emus_folder}/cemu"
    if system == "darwin":
        return f"{home}/Library/Application Support/Cemu"
    return None


def _cemu_sdl_lib_candidates():
    if system == "linux":
        return [
            "/usr/lib/libSDL3.so.0",
            "/usr/lib/libSDL2-2.0.so.0",
            "/usr/lib/x86_64-linux-gnu/libSDL3.so.0",
            "/usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0",
        ]
    if system == "darwin":
        return [
            f"{emus_folder}/Cemu.app/Contents/Frameworks/libSDL2-2.0.0.dylib",
            f"{emus_folder}/Cemu.app/Contents/Frameworks/libSDL2.dylib",
            "/opt/homebrew/lib/libSDL2-2.0.0.dylib",
            "/usr/local/lib/libSDL2-2.0.0.dylib",
        ]
    return []


def cemu_set_controllers():
    if system.startswith("win"):
        return
    config_dir = cemu_config_dir()
    if not config_dir:
        return
    controller_dir = Path(config_dir) / "controllerProfiles"
    if not controller_dir.is_dir():
        return
    tool = Path(emudeck_backend) / "tools" / "gamepads" / "cemu_gamepads.py"
    template_dir = Path(emudeck_backend) / "configs" / system / "cemu" / "controllerTemplates"
    if not tool.is_file() or not template_dir.is_dir():
        return
    for candidate in _cemu_sdl_lib_candidates():
        if not Path(candidate).is_file():
            continue
        env = dict(os.environ)
        env["SDL_LIB"] = str(candidate)
        env["CEMU_CONTROLLER_DIR"] = str(controller_dir)
        env["CEMU_TEMPLATE_DIR"] = str(template_dir)
        result = subprocess.run(
            [sys.executable, str(tool), "--write"],
            check=False,
            env=env,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if result.returncode == 0:
            return
    print("Cemu gamepad detection: no SDL library found")


def cemu_launch_fixes():
    cemu_set_controllers()
