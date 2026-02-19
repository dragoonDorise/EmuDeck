from core.all import *

esde_release_json = "https://gitlab.com/es-de/emulationstation-de/-/raw/master/latest_release.json"
esde_add_steam_input_file = (
    Path(emudeck_backend)
    / "configs"
    / "steam-input"
    / "emulationstation-de_controller_config.vdf"
)
steam_input_templateFolder = home / ".steam" / "steam" / "controller_base" / "templates"

if system == "linux":
    esde_install_dir = Path.home() / "Applications"
    esde_config_dir = Path.home() / "ES-DE"
else:
    esde_install_dir = esde_folder
    esde_config_dir = esde_folder

esde_settings_folder = esde_config_dir
esde_settings_file = esde_config_dir / "settings" / "es_settings.xml"
esde_systems_file = esde_config_dir / "custom_systems" / "es_systems.xml"
esde_rules_file = esde_config_dir / "custom_systems" / "es_find_rules.xml"


def esde_get_url():
    try:
        resp = requests.get(esde_release_json, timeout=10)
        resp.raise_for_status()
        data = resp.json()
    except Exception as e:
        print(f"Warning: could not fetch release JSON: {e}")
        return False

    if system == "linux":
        exename = "LinuxSteamDeckAppImage"
    if system.startswith("win"):
        exename = "WindowsPortable"
    if system == "darwin":
        exename = "macOSApple"

    ESDE_releaseURL = ""
    for pkg in data.get("stable", {}).get("packages", []):
        if pkg.get("name") == exename:
            ESDE_releaseURL = pkg.get("url", "")
            break

    return ESDE_releaseURL


def esde_install():
    set_msg("Installing ES-DE")

    if system == "linux":
        type = "AppImage"

        esde_install_dir.mkdir(parents=True, exist_ok=True)
        esde_config_dir.mkdir(parents=True, exist_ok=True)

        try:
            install_emu("ES-DE", esde_get_url(), type, esde_install_dir)
            esde_add_to_steam()
            return True
        except Exception as e:
            print(f"Error during install: {e}")
            return False

    if system.startswith("win"):
        type = "zip"
    if system == "darwin":
        type = "dmg"

    esde_install_dir.mkdir(parents=True, exist_ok=True)

    try:
        install_emu("ES-DE", esde_get_url(), type, esde_install_dir)
        esde_add_to_steam()
        return True
    except Exception as e:
        print(f"Error during install: {e}")
        return False

def esde_uninstall():
    try:
        if system == "linux":
            uninstall_emu("ES-DE", "AppImage")
            esde_config_dir_local = Path.home() / "ES-DE"
            if esde_config_dir_local.exists():
                shutil.rmtree(esde_config_dir_local, ignore_errors=True)
                print(f"Removed config directory at {esde_config_dir_local}")
            return True

        if system.startswith("win"):
            esde_win_dir = Path(os.environ["APPDATA"]) / "EmuDeck" / "EmulationStation-DE"
            if esde_win_dir.exists():
                shutil.rmtree(esde_win_dir, ignore_errors=True)
                print(f"Removed {esde_win_dir}")
            return True

        if system == "darwin":
            uninstall_emu("ES-DE", "app")
            return True

        return False

    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False


def esde_init():
    set_msg("EmulationStation DE - Paths and Themes")

    destination = esde_settings_folder
    destination.mkdir(parents=True, exist_ok=True)

    src = Path(emudeck_backend) / "configs" / "common" / "emulationstation"
    shutil.copytree(src, destination, dirs_exist_ok=True)

    copy_and_set_settings_file(
        "common/emulationstation/settings/es_settings.xml",
        destination / "settings",
    )

    dlmedia = Path(storage_path / "es-de/downloaded-media")
    dlmedia.mkdir(parents=True, exist_ok=True)

    # esde_apply_theme(esde_theme_url, esde_theme_name)
    esde_set_default_emulators()


def esde_install_init():
    esde_install()
    esde_init()


def esde_is_installed():
    if system == "linux":
        return (Path.home() / "Applications" / "ES-DE.AppImage").exists()
    if system.startswith("win"):
        return (Path(os.environ["APPDATA"]) / "EmuDeck" / "EmulationStation-DE" / "ES-DE.exe").exists()
    if system == "darwin":
        return (esde_folder / "ES-DE.app").exists()
    return False


def esde_apply_theme(esde_theme_url: str, esde_theme_name: str):
    # Themes en config dir (SIN /ES-DE extra)
    themes_dir = esde_config_dir / "themes"
    themes_dir.mkdir(parents=True, exist_ok=True)

    dest = themes_dir / esde_theme_name
    if not dest.exists():
        subprocess.run(["git", "clone", esde_theme_url, str(dest)], check=True)

    # Settings file real está en config/settings
    settings_file = esde_config_dir / "settings" / "es_settings.xml"
    text = settings_file.read_text(encoding="utf-8")

    pattern = r'(?<=<string name="ThemeSet" value=").*?(?=" />)'
    new_text = re.sub(pattern, esde_theme_name, text)

    settings_file.write_text(new_text, encoding="utf-8")


def esde_set_default_emulators():
    gamelists_dir = esde_config_dir / "gamelists"
    gamelists_dir.mkdir(parents=True, exist_ok=True)

    emus = [
        ("Dolphin (Standalone)", "gc"),
        ("PPSSPP (Standalone)", "psp"),
        ("Dolphin (Standalone)", "wii"),
        ("PCSX2 (Standalone)", "ps2"),
        ("melonDS", "nds"),
        ("Azahar (Standalone)", "n3ds"),
        ("Beetle Lynx", "atarilynx"),
        ("DuckStation (Standalone)", "psx"),
        ("Beetle Saturn", "saturn"),
        ("ScummVM (Standalone)", "scummvm"),
    ]

    for label, system_code in emus:
        esde_set_emu(label, system_code)


def esde_set_emu(emu: str, system_code: str) -> None:
    gamelist_file = esde_config_dir / "gamelists" / system_code / "gamelist.xml"

    if gamelist_file.exists():
        print(f"{system_code} gamelist already present, skipping.")
        return

    gamelist_file.parent.mkdir(parents=True, exist_ok=True)

    src = (
        emudeck_backend
        / "configs"
        / "common"
        / "emulationstation"
        / "gamelists"
        / system_code
        / "gamelist.xml"
    )

    try:
        shutil.copy2(src, gamelist_file)
        print(f"Copied template for {system_code} → {gamelist_file}")
    except FileNotFoundError:
        print(f"Template not found for {system_code}: {src}")
    except Exception as e:
        print(f"Error copying {system_code} gamelist: {e}")


def esde_add_to_steam():
    set_msg("Adding ES-DE to Steam")

    if system == "linux" or system == "darwin":
        launcher = str(tools_path / "launchers/es-de/es-de.sh")
        icon_path = str(emudeck_backend / "icons/ES-DE.png")
    if system.startswith("win"):
        launcher = str(tools_path / "launchers/es-de/es-de.bat")
        icon_path = str(emudeck_backend / "icons/ico/es-de.ico")

    set_msg(icon_path)

    add_steam_shortcut(
        "esde",
        "EmulationStationDE",
        launcher,
        str(esde_config_dir if system == "linux" else esde_folder),
        str(icon_path),
    )
