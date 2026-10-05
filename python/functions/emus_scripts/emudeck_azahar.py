from core.all import *

def azahar_install():
    set_msg(f"Installing azahar")
    repository = "azahar-emu/azahar"

    if system == "linux":
        type="AppImage"
        look_for="AppImage"
        path=emus_folder
        if cpu_arch == "arm":
            repository = "dragoonDorise/azahar"
            look_for = "arm64."

    if system.startswith("win"):
        type="zip"
        look_for="msvc"
        path=f"{emus_folder}/azahar"

    if system == "darwin":
        type="zip"
        look_for="macos"
        path=emus_folder

    try:
        repo=get_latest_release_gh(repository,type,look_for)
        if install_emu("azahar", repo, type, path) is False:
            return False
    except Exception as e:
        print(f"Error during install: {e}")
        return False

    if system == "linux":
        flush_emulator_launchers("azahar")
        create_desktop_shortcut(home / ".local" / "share" / "applications" / "Azahar.desktop",
                                "Azahar AppImage", f"{tools_path}/launchers/azahar.sh", False)
    return True


def azahar_uninstall():
    try:
        if system == "linux":
            remove_parser("nintendo_3ds_azahar")
            uninstall_emu("azahar", "AppImage")
        if system.startswith("win"):
          uninstall_emu("Azahar", "dir")
        if system == "darwin":
          uninstall_emu("Azahar", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def azahar_is_installed():
    if system == "linux":
        return (emus_folder / "azahar.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "azahar" / "azahar.exe").exists()
    if system == "darwin":
      return (emus_folder / "azahar.app").exists()


def azahar_init():
    set_msg(f"Setting up Azahar")
    flush_emulator_launchers("azahar")
    if system == "linux":
        destination=f"{home}/.config/azahar-emu"
    if system.startswith("win"):
        destination = f"{emus_folder}/azahar/user/config"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/azahar/"

    copy_and_set_settings_file(f"{system}/azahar/qt-config.ini", destination)

    azahar_set_emulation_folder()
    if system == "linux":
        azahar_setup_storage()
    azahar_setup_saves()
    if system == "linux":
        azahar_setup_textures()
        azahar_migrate()
    azahar_set_resolution()
    azahar_set_controller_style()
    esde_set_emu("Azahar (Standalone)","n3ds")
    azahar_add_custom_parser()
    azahar_add_steam_input_profile()
    azahar_add_es_config()

def azahar_install_init():
    azahar_install()
    azahar_init()

def azahar_add_custom_parser():
    if azahar_is_installed() and srm_is_installed():
        add_parser("nintendo_3ds_azahar")


def azahar_setup_storage():
    """Moves Citra or old Azahar sdmc/nand into Emulation/storage/azahar and links cheats/textures (Linux)."""
    for folder in ("sdmc", "nand"):
        azahar_move_storage_folder(folder)

    link_to_storage_folder(home / ".local" / "share" / "azahar-emu" / "cheats", "azahar/cheats")
    link_to_storage_folder(home / ".local" / "share" / "azahar-emu" / "load" / "textures", "azahar/textures")


def azahar_move_storage_folder(folder: str):
    """Copies the Citra or Azahar <folder> (sdmc/nand) into Emulation/storage/azahar like the bash version."""
    target = Path(storage_path) / "azahar" / folder
    azahar_flatpak = home / ".var" / "app" / "io.github.azahar.Azahar" / "data" / "azahar-emu" / folder
    azahar_local = home / ".local" / "share" / "azahar-emu" / folder
    citra_sources = [
        Path(storage_path) / "citra" / folder,
        home / ".var" / "app" / "org.citra_emu.citra" / "data" / "citra-emu" / folder,
        home / ".local" / "share" / "citra-emu" / folder,
    ]
    target.parent.mkdir(parents=True, exist_ok=True)

    no_azahar_original = not azahar_flatpak.is_dir() or not (home / ".local" / "share" / "azahar-emu").is_dir()
    citra_source = next((p for p in citra_sources if p.is_dir()), None)
    if not target.is_dir() and no_azahar_original and citra_source:
        set_msg(f"Copying Citra {folder} to the Azahar folder")
        subprocess.run(["rsync", "-a", "--ignore-existing", str(citra_source), str(target.parent)], check=False)

    if not target.is_dir() and (azahar_flatpak.is_dir() or azahar_local.is_dir()):
        set_msg(f"Copying Azahar {folder} to the Emulation/storage folder")
        source = azahar_flatpak if azahar_flatpak.is_dir() else azahar_local
        if subprocess.run(["rsync", "-a", "--ignore-existing", str(source), str(target.parent)], check=False).returncode == 0:
            shutil.rmtree(source, ignore_errors=True)
    else:
        target.mkdir(parents=True, exist_ok=True)


def azahar_setup_textures():
    """Links Azahar's texture folder into Emulation/texturepacks (Linux)."""
    textures = home / ".local" / "share" / "azahar-emu" / "load" / "textures"
    textures.mkdir(parents=True, exist_ok=True)
    link_to_textures_folder(textures, "azahar/textures")


def azahar_migrate():
    """Points the old Citra and Lime3DS launchers to Azahar's (Linux)."""
    launchers = Path(tools_path) / "launchers"
    for old_launcher in ("citra.sh", "lime3ds.sh"):
        link = launchers / old_launcher
        if link.exists() or link.is_symlink():
            link.unlink()
        link.symlink_to(launchers / "azahar.sh")


def azahar_setup_saves():
    if system == "linux":
        origin_saves=f"{storage_path}/azahar/sdmc"
        origin_states=f"{home}/.local/share/azahar-emu/states"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/azahar/sdmc"
        origin_states=f"{emus_folder}/azahar/states"
    if system == "darwin":
        origin_saves=f"{home}/.share/azahar/sdmc"
        origin_states=f"{home}/.local/share/azahar-emu/states"

    link_to_saves_folder(origin_saves, "azahar/saves")
    link_to_saves_folder(origin_states, "azahar/states")


def azahar_config_file():
    if system == "linux":
        return Path(f"{home}/.config/azahar-emu/qt-config.ini")
    if system.startswith("win"):
        return Path(f"{emus_folder}/azahar/qt-config.ini")
    if system == "darwin":
        return Path(f"{home}/Library/Application Support/azahar/qt-config.ini")


def azahar_set_emulation_folder() -> bool:
    if system == "linux":
        link_to_bios_folder(home / ".local" / "share" / "azahar-emu" / "sysdata", "azahar/keys")

    config_file = azahar_config_file()

    if not config_file.is_file():
        return False

    Path(f"{storage_path}/azahar/screenshots").mkdir(parents=True, exist_ok=True)

    set_config("Paths\\gamedirs\\3\\path", f"{roms_path}/n3ds", config_file)
    set_config("nand_directory", f"{storage_path}/azahar/nand/", config_file)
    set_config("sdmc_directory", f"{storage_path}/azahar/sdmc/", config_file)
    set_config("Paths\\screenshotPath", f"{storage_path}/azahar/screenshots/", config_file)

    set_config("nand_directory\\default", "false", config_file)
    set_config("sdmc_directory\\default", "false", config_file)
    set_config("use_custom_storage", "true", config_file)
    set_config("use_custom_storage\\default", "false", config_file)

    return True


def azahar_set_resolution() -> bool:
    if system == "linux":
        config_path = f"{home}/.config/azahar-emu/qt-config.ini"
    elif system.startswith("win"):
        config_path = f"{emus_folder}/azahar/user/config/qt-config.ini"
    elif system == "darwin":
        config_path=f"{home}/Library/Application Support/azahar/qt-config.ini"
    else:
        return False

    resolution_map = {
        "720P": 3,
        "1080P": 5,
        "1440P": 6,
        "4K": 9,
    }

    resolution = settings.resolutions.azahar
    multiplier = resolution_map.get(resolution, 3)

    if resolution == "4K" and system == "linux" and get_screen_width() < 3840:
        multiplier = 5

    set_ini_value(config_path, "Renderer", "resolution_factor", str(multiplier))
    set_ini_value(config_path, "Renderer", r"resolution_factor\default", "false")

    return True

def azahar_set_abxy_style():
    print("NYI")

def azahar_set_bayx_style():
    print("NYI")

def azahar_set_controller_style():
    if settings.controllerLayout == "bayx":
        azahar_set_bayx_style()
    else:
        azahar_set_bayx_style()

def azahar_add_to_steam():
    set_msg("Adding Azahar to Steam")
    launcher = tools_path / "launchers" / ("azahar.bat" if system.startswith("win") else "azahar.sh")
    add_steam_shortcut("azahar", "Azahar", str(launcher), str(emus_folder), str(icons_path / "ico/azahar.ico"))


def azahar_add_steam_input_profile():
    add_steam_input_custom_icons()
    set_msg("Adding Azahar Steam Input Profile.")
    add_steam_input_templates()


def azahar_add_es_config():
    return esde_add_custom_systems_file()
