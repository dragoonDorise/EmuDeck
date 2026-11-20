from core.all import *
import xml.etree.ElementTree as ET


def cemu_install():
    stat_install("cemu")
    set_msg(f"Installing Cemu")
    repo_name = "cemu-project/Cemu"

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
        look_for="Cemu"
        destination = emus_folder
        name="Cemu"
        repo_name = "dragoonDorise/Cemu"

    try:
        repo=get_latest_release_gh(repo_name,type,look_for)
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def cemu_uninstall():
    try:
        srm_remove_emulator_parsers("cemu")
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

    previous_xml = None
    previous_mlc = None

    if system == "linux":
        settings_path = cemu_settings_file()
        previous_mlc = ""
        if settings_path.is_file():
            previous_xml = settings_path.read_bytes()
            previous_mlc = ET.fromstring(previous_xml).findtext("mlc_path") or ""

    try:
        copy_setting_dir(f"{system}/cemu/", destination)
        copy_and_set_settings_file(settings_file_src, destination)

        if not cemu_set_emulation_folder(previous_mlc) and system == "linux":
            raise FileNotFoundError(settings_path)
    except Exception:
        if previous_xml is not None:
            settings_path.write_bytes(previous_xml)
        raise
    cemu_setup_saves()
    cemu_setup_storage()
    cemu_set_resolution()
    cemu_set_controller_style()
    cemu_set_language()
    cemu_add_steam_input_profile()
    srm_add_emulator_parsers("cemu")

def cemu_install_init():
    cemu_install()
    cemu_init()


CEMU_LANGUAGES = {
    "ja": 0, "en": 1, "fr": 2, "de": 3, "it": 4, "es": 5,
    "zh": 6, "ko": 7, "nl": 8, "pt": 9, "ru": 10, "tw": 11,
}


def cemu_settings_file():
    if system == "linux":
        return Path(f"{home}/.config/Cemu/settings.xml")
    if system.startswith("win"):
        return Path(f"{emus_folder}/cemu/settings.xml")
    if system == "darwin":
        return Path(f"{home}/Library/Application Support/Cemu/settings.xml")


def cemu_set_emulation_folder(previous_mlc: str | None = None) -> bool:
    settings_path = cemu_settings_file()

    if not settings_path.is_file():
        return False
    
    if system == "linux":
        return _cemu_set_linux_paths(settings_path, previous_mlc)

    text = settings_path.read_text(encoding="utf-8")
    roms_dir = f"{roms_path}/wiiu/roms"
    mlc_dir = f"{roms_path}/wiiu/mlc01"

    if roms_dir not in text:
        text = text.replace("</GamePaths>", f"  <Entry>{roms_dir}/</Entry>\n  </GamePaths>", 1)

    text = re.sub(r"<mlc_path>[^<]*</mlc_path>", f"<mlc_path>{mlc_dir}</mlc_path>", text)

    settings_path.write_text(text, encoding="utf-8")

    return True

def _cemu_set_linux_paths(settings_path: Path, previous_mlc: str | None) -> bool:
    tree = ET.parse(settings_path)
    mlc = tree.find("mlc_path")
    game_path = tree.find("GamePaths/Entry")
    if mlc is None or game_path is None:
        raise ValueError(f"Missing Cemu path settings in {settings_path}")

    default_mlc = Path(home) / ".local/share/Cemu/mlc01"
    if previous_mlc is None:
        previous_mlc = mlc.text
    active_mlc = previous_mlc or str(default_mlc)
    migrated_source = None

    if Path(active_mlc) == default_mlc and not default_mlc.is_symlink():
        source = default_mlc.resolve()
        target = (Path(roms_path) / "wiiu/mlc01").resolve()
        if source in target.parents or target in source.parents:
            raise ValueError(f"Overlapping MLC paths: {source} and {target}")

        if source != target:
            target.mkdir(parents=True, exist_ok=True)
            if not source.exists() or not any(source.iterdir()):
                active_mlc = str(target)
            elif subprocess.check_output(
                ["find", str(target), "-mindepth", "1", "!", "-type", "d", "-print", "-quit"]
            ):
                print("Both MLC folders contain data. Keeping the current MLC path.")
            else:
                paths = [f"{source}/", f"{target}/"]
                subprocess.run(["rsync", "-a", "--", *paths], check=True)
                if subprocess.check_output(["rsync", "-acni", "--", *paths]):
                    raise RuntimeError("MLC verification failed. Keeping the original data.")
                active_mlc = str(target)
                migrated_source = source

    mlc.text = active_mlc
    game_path.text = f"{roms_path}/wiiu/roms/"

    settings_path = settings_path.resolve()
    with tempfile.TemporaryDirectory(dir=settings_path.parent) as directory:
        temporary = Path(directory) / settings_path.name
        tree.write(temporary, encoding="utf-8", xml_declaration=True)
        shutil.copymode(settings_path, temporary)
        temporary.replace(settings_path)

    if migrated_source is not None:
        try:
            shutil.rmtree(migrated_source)
        except OSError as error:
            print(f"Cemu uses {active_mlc}. Could not remove the old MLC: {error}")

    return True


def cemu_set_language() -> bool:
    settings_path = cemu_settings_file()

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
        mlc = ET.parse(cemu_settings_file()).getroot().findtext("mlc_path")
        active_mlc = Path(mlc) if mlc else Path(home) / ".local/share/Cemu/mlc01"
        origin_saves = active_mlc / "usr/save"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/cemu/mlc01/usr/save"
    if system == "darwin":
        origin_saves=f"{home}/Library/Application Support/Cemu/mlc01/usr/save"

    link_to_saves_folder(origin_saves, "Cemu/saves")

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
            "/usr/lib/aarch64-linux-gnu/libSDL3.so.0",
            "/usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0",
            "/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0",
        ]
    if system == "darwin":
        return [f"{emudeck_folder}/automap/libSDL3.dylib"]
    if system.startswith("win"):
        return [
            f"{emus_folder}/eden-windows-msvc/SDL2.dll",
            str(Path(emudeck_backend) / "configs" / "windows" / "yuzu" / "SDL2.dll"),
        ]
    return []


def cemu_set_controllers():
    if not automap_enabled("cemu"):
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
    if system == "darwin":
        download_sdl3_darwin()
    for candidate in _cemu_sdl_lib_candidates():
        if not Path(candidate).is_file():
            continue
        if system.startswith("win"):
            ignore_steam_virtual_gamepad(candidate)
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

def cemu_add_to_steam():
    set_msg("Adding Cemu to Steam")
    launcher = tools_path / "launchers" / ("cemu.bat" if system.startswith("win") else "cemu.sh")
    add_steam_shortcut("cemu", "Cemu", str(launcher), str(emus_folder), str(icons_path / "ico/cemu.ico"))


def cemu_add_steam_input_profile():
    add_steam_input_custom_icons()
    set_msg("Adding CemuNative Steam Input Profile.")
    add_steam_input_templates()
