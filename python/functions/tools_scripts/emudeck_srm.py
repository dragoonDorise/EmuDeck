from core.all import *

def srm_install():
    stat_install("srm")
    set_msg(f"Installing Steam Rom Manager")

    if system == "linux":
        type="AppImage"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        type = "exe"
        look_for = "portable"
        destination = Path(os.environ["APPDATA"]) / "EmuDeck" / "SteamRomManager"
        destination.mkdir(parents=True, exist_ok=True)

    if system == "darwin":
        type="dmg"
        look_for=""
        destination = f"{emus_folder}"

    try:
        if system == "linux" and cpu_arch == "arm":
            repo=get_latest_release_gh("dragoonDorise/steam-rom-manager",type,"arm64.AppImage")
        else:
            repo=get_latest_release_gh("SteamGridDB/steam-rom-manager",type,look_for)

        install_emu("srm", repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def srm_uninstall():
    if system == "linux":
        uninstall_emu("srm", "AppImage")
        shutil.rmtree(tools_path / "launchers" / "srm", ignore_errors=True)

        config_dir = Path(srm_path)
        if config_dir.exists():
            shutil.rmtree(config_dir, ignore_errors=True)
            print(f"Removed config directory at {config_dir}")

    if system.startswith("win"):
        appdata = Path(os.environ["APPDATA"])

        shutil.rmtree(appdata / "EmuDeck" / "SteamRomManager", ignore_errors=True)
        shutil.rmtree(tools_path / "launchers" / "srm", ignore_errors=True)
        (appdata / "Microsoft" / "Windows" / "Start Menu" / "Programs" / "EmuDeck" / "SteamRomManager.lnk").unlink(missing_ok=True)

        # Legacy installation
        shutil.rmtree(tools_path / "userData", ignore_errors=True)
        (tools_path / "srm.exe").unlink(missing_ok=True)

    if system == "darwin":
        uninstall_emu("Steam Rom Manager", "app")

    return True

def srm_is_installed():
    if system == "linux":
        return (emus_folder / "srm.AppImage").exists() or (Path(tools_path) / "Steam-ROM-Manager.AppImage").exists()
    if system.startswith("win"):
        return (Path(os.environ["APPDATA"]) / "EmuDeck" / "SteamRomManager" / "srm.exe").exists()
    if system == "darwin":
        return (emus_folder / "Steam Rom Manager.app").exists()
    return False

def srm_init():
    set_msg(f"Setting up Steam Rom Manager")
    if hybrid_mode:
        (Path(emudeck_folder) / "customParsers").mkdir(parents=True, exist_ok=True)
        source = Path(bash_backend) / "configs" / "steam-rom-manager" / "userData"
        copy_with_backup(source / "userConfigurations.json", Path(srm_path) / "userData" / "userConfigurations.json")
        copy_with_backup(source / "userSettings.json", Path(srm_path) / "userData" / "userSettings.json")
        srm_add_extra_parsers()
        srm_set_emulation_folder()
        srm_set_env()
    else:
        copy_setting_dir(f"common/srm/",f"{srm_path}")
        copy_and_set_settings_file(f"common/srm/userData/userSettings.json", f"{srm_path}/userData")
        copy_and_set_settings_file(f"common/srm/userData/userConfigurations.json", f"{srm_path}/userData")
        srm_frame_settings()
        srm_add_custom_parsers()
    if system == "linux":
        srm_add_controller_template()
        srm_add_steam_input_profiles()
        srm_flush_tool_launcher()
        add_steam_input_custom_icons()
        srm_flush_old_symlinks()
    if system.startswith("win"):
        srm_windows_paths()
    return True


def srm_set_emulation_folder():
    user_data = Path(srm_path) / "userData"
    replacements = {
        "userConfigurations.json": [("/run/media/mmcblk0p1/Emulation/tools", tools_path),
                                    ("/run/media/mmcblk0p1/Emulation/storage", storage_path),
                                    ("/home/deck", home)],
        "userSettings.json": [("/home/deck", home),
                              ("/run/media/mmcblk0p1/Emulation/roms", roms_path),
                              ("/run/media/mmcblk0p1/Emulation/tools", tools_path)],
    }
    for name, pairs in replacements.items():
        file = user_data / name
        if file.is_file():
            for old, new in pairs:
                sed(old, str(new), file)
    return True


def srm_set_env():
    set_msg("Steam Rom Manager - Set enviroment")
    user_settings = Path(srm_path) / "userData" / "userSettings.json"
    if not user_settings.is_file():
        return False
    data = json.loads(user_settings.read_text(encoding="utf-8"))
    environment = data.setdefault("environmentVariables", {})
    environment["steamDirectory"] = str(home / ".steam" / "steam")
    environment["romsDirectory"] = str(roms_path)
    user_settings.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    srm_frame_settings()
    return True


def srm_steam_path() -> Optional[Path]:
    for candidate in (home / ".local" / "share" / "Steam", home / ".steam" / "steam"):
        if candidate.is_dir():
            return candidate
    return None


def srm_add_controller_template():
    if hybrid_mode:
        source = Path(bash_backend) / "configs" / "steam-rom-manager" / "userData" / "controllerTemplates.json"
    else:
        source = Path(emudeck_backend) / "configs" / "common" / "srm" / "userData" / "controllerTemplates.json"
    destination = copy_with_backup(source, Path(srm_path) / "userData" / "controllerTemplates.json")
    steam = srm_steam_path()
    if steam is None:
        print("Steam install not found")
        return False
    sed("/home/deck/.local/share/Steam", str(steam), destination)
    return True


def srm_add_steam_input_profiles():
    set_msg("Steam Rom Manager - Adding Steam input profiles")
    templates = home / ".steam" / "steam" / "controller_base" / "templates"
    for old in ("ares", "cemu", "citra", "duckstation", "emulationstation-de", "melonds", "mGBA", "pcsx2", "ppsspp", "rmg"):
        (templates / f"{old}_controller_config.vdf").unlink(missing_ok=True)
    return add_steam_input_templates()


def srm_flush_tool_launcher():
    source = get_launchers_source_dir() / "srm" / "steamrommanager.sh"
    destination = Path(tools_path) / "launchers" / "srm" / "steamrommanager.sh"
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)
    destination.chmod(destination.stat().st_mode | 0o111)
    return True


def srm_flush_old_symlinks():
    for name in ("mame2003", "mamecurrent"):
        link = Path(roms_path) / name
        if link.is_symlink():
            link.unlink()
    return True


def srm_add_extra_parsers():
    if hybrid_mode:
        copy_with_backup(Path(bash_backend) / "configs" / "steam-rom-manager" / "userData" / "userConfigurations.json",
                         Path(srm_path) / "userData" / "userConfigurations.json")
    else:
        copy_and_set_settings_file("common/srm/userData/userConfigurations.json", f"{srm_path}/userData")
    srm_add_custom_parsers()
    custom_parsers = Path(emudeck_folder) / "customParsers"
    if custom_parsers.is_dir():
        for parser in sorted(custom_parsers.glob("*.json")):
            add_parser(parser.stem)
    srm_set_emulation_folder()
    return True


def srm_check_parsers():
    user_data = Path(srm_path) / "userData"
    try:
        settings_data = json.loads((user_data / "userSettings.json").read_text(encoding="utf-8"))
        steam_dir = settings_data.get("environmentVariables", {}).get("steamDirectory") or ""
    except (OSError, ValueError):
        steam_dir = ""
    if not steam_dir:
        print("Steam ROM Manager steamDirectory is empty, running srm_init...")
        srm_init()
    try:
        parsers = json.loads((user_data / "userConfigurations.json").read_text(encoding="utf-8"))
    except (OSError, ValueError):
        parsers = []
    if not parsers:
        print("Steam ROM Manager has no parsers, restoring configuration...")
        srm_add_extra_parsers()
        srm_set_emulation_folder()
    return True


def srm_delete_cache():
    steam = srm_steam_path()
    if steam is None:
        print("Steam install not found")
        return False
    for config in (steam / "userdata").glob("*/config"):
        if config.is_dir():
            shutil.rmtree(config, ignore_errors=True)
    print("Cache deleted successfully.")
    return True


def srm_frame_settings():
    if system != "linux" or get_product_name() != "frame":
        return
    user_settings = Path(srm_path) / "userData" / "userSettings.json"
    if not user_settings.is_file():
        return
    data = json.loads(user_settings.read_text(encoding="utf-8"))
    data["autoKillSteam"] = False
    data["autoRestartSteam"] = False
    user_settings.write_text(json.dumps(data, indent=2), encoding="utf-8")


def srm_windows_paths():
    sed(':\\',':\\\\',f"{srm_path}/userData/userConfigurations.json")
    sed('/','\\\\',f"{srm_path}/userData/userConfigurations.json")
    sed('${\\\\}','${/}',f"{srm_path}/userData/userConfigurations.json")


    sed('\\','\\\\',f"{srm_path}/userData/userSettings.json")
    sed('/','\\\\',f"{srm_path}/userData/userSettings.json")





def srm_install_init():
    srm_install()
    srm_init()

def srm_add_custom_parsers():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
        and name.endswith('_add_custom_parser')
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()
