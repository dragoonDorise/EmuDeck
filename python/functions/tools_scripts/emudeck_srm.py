from core.all import *

def srm_steam_installed():
    if system == "darwin":
        return Path("/Applications/Steam.app").exists() or (home / "Applications" / "Steam.app").exists()
    if system.startswith("win"):
        return bool(steam_install_path) and (Path(steam_install_path) / "steam.exe").exists()
    return True

def srm_install_steam():
    set_msg("Installing Steam")
    temp = Path(tempfile.mkdtemp())
    if system == "darwin":
        manifest = requests.get("https://client-update.steamstatic.com/steam_client_osx", timeout=30).text
        package = re.search(r'appdmg_osx\.zip[^"\s]*', manifest).group(0)
        url = f"https://client-update.steamstatic.com/{package}"
        archive_path = temp / "steam.zip"
    else:
        url = "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"
        archive_path = temp / "SteamSetup.exe"
    response = requests.get(url, stream=True, timeout=30)
    response.raise_for_status()
    with open(archive_path, "wb") as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)
    if system.startswith("win"):
        subprocess.run([str(archive_path), "/S"], check=True)
        return True
    zipfile.ZipFile(archive_path).extractall(temp)
    subprocess.run(["tar", "-xzf", str(temp / "SteamMacBootstrapper.tar.gz"), "-C", str(temp)], check=True)
    for junk in (temp / "Steam.app").rglob("._*"):
        junk.unlink()
    try:
        shutil.copytree(temp / "Steam.app", "/Applications/Steam.app", symlinks=True)
    except PermissionError:
        (home / "Applications").mkdir(exist_ok=True)
        shutil.copytree(temp / "Steam.app", home / "Applications" / "Steam.app", symlinks=True)
    return True

def srm_wait_steam_users():
    def has_users():
        steam_dir = get_steam_paths()[0] if system.startswith("win") else steam_install_path
        userdata = Path(steam_dir) / "userdata"
        return userdata.is_dir() and any(d.is_dir() and d.name.isdigit() and d.name != "0" for d in userdata.iterdir())
    if has_users():
        return True
    if not srm_steam_installed():
        popup_show_progress("Steam", "Installing Steam, please wait...", srm_install_steam)
    try:
        if system == "darwin":
            steam_app = next(app for app in (Path("/Applications/Steam.app"), home / "Applications" / "Steam.app") if app.exists())
            subprocess.run(["open", str(steam_app)], check=True)
        elif system.startswith("win"):
            subprocess.Popen([get_steam_paths()[2]])
        else:
            subprocess.Popen(["steam"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception as e:
        print(f"Unable to launch Steam: {e}")
    def wait():
        deadline = time.time() + 1800
        while not has_users() and time.time() < deadline:
            time.sleep(2)
    popup_show_progress("Steam", "We are opening Steam for you, please log in with your account. Steam ROM Manager will open as soon as you do.", wait)
    return has_users()

def srm_install():
    stat_install("srm")
    set_msg(f"Installing Steam Rom Manager")

    if not srm_steam_installed():
        try:
            srm_install_steam()
        except Exception as e:
            print(f"Error installing Steam: {e}")

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
        look_for="arm64"
        destination = f"{emus_folder}"

    try:
        if system == "linux" and cpu_arch == "arm":
            repo=get_latest_release_gh("dragoonDorise/steam-rom-manager",type,"arm64.AppImage")
        else:
            repo=get_latest_release_gh("SteamGridDB/steam-rom-manager",type,look_for)

        if install_emu("srm", repo, type, destination) is False:
            return False
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
    if hybrid_mode and system == "linux":
        copy_and_set_settings_file("common/srm/userData/userSettings.json", f"{srm_path}/userData")
        srm_add_extra_parsers()
        srm_set_emulation_folder()
        srm_set_env()
    else:
        copy_setting_dir(f"common/srm/",f"{srm_path}")
        copy_and_set_settings_file(f"common/srm/userData/userSettings.json", f"{srm_path}/userData")
        copy_and_set_settings_file(f"common/srm/userData/userConfigurations.json", f"{srm_path}/userData")
        srm_frame_settings()
        srm_add_optional_parsers()
    if system == "linux":
        srm_add_controller_template()
        srm_add_steam_input_profiles()
        srm_flush_tool_launcher()
        add_steam_input_custom_icons()
        srm_flush_old_symlinks()
    if system.startswith("win"):
        srm_windows_paths()
    srm_set_steam_account()
    return True


def srm_set_steam_account():
    userdata = Path(steam_install_path) / "userdata"
    user_settings = Path(srm_path) / "userData" / "userSettings.json"
    if not userdata.is_dir() or not user_settings.is_file():
        return False
    accounts = [d for d in userdata.iterdir() if d.is_dir() and d.name.isdigit() and d.name != "0"]
    if not accounts:
        return False

    def last_used(account):
        localconfig = account / "config" / "localconfig.vdf"
        return max(account.stat().st_mtime, localconfig.stat().st_mtime if localconfig.is_file() else 0)

    account_id = max(accounts, key=last_used).name
    data = json.loads(user_settings.read_text(encoding="utf-8"))
    data.setdefault("environmentVariables", {})["userAccounts"] = [account_id]
    user_settings.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"SRM Steam account: {account_id}")
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
    copy_and_set_settings_file("common/srm/userData/userConfigurations.json", f"{srm_path}/userData")
    srm_add_optional_parsers()
    srm_set_emulation_folder()
    return True


def srm_get_parser(parser_path: Path) -> dict:
    text = parser_path.read_text(encoding="utf-8")
    text = text.replace("/run/media/mmcblk0p1/Emulation/tools", str(tools_path))
    text = text.replace("/run/media/mmcblk0p1/Emulation/storage", str(storage_path))
    text = text.replace("/home/deck", str(home))
    text = text.replace("EMULATIONPATH", str(emulation_path))
    text = text.replace(".EXT", ".bat" if system.startswith("win") else ".sh")
    return json.loads(text)


def srm_add_parser(parser_path: Path) -> bool:
    new_cfg = srm_get_parser(parser_path)
    parser_id = new_cfg.get("parserId")
    print(f"Parser ID: {parser_id}")

    srm_user_configurations = Path(srm_path) / "userData" / "userConfigurations.json"
    srm_user_configurations.parent.mkdir(parents=True, exist_ok=True)
    if not srm_user_configurations.exists():
        srm_user_configurations.write_text("[]", encoding="utf-8")

    configs = json.loads(srm_user_configurations.read_text(encoding="utf-8"))

    if any(item.get("parserId") == parser_id for item in configs):
        return True

    print("adding parser")
    configs.append(new_cfg)

    srm_user_configurations.write_text(
        json.dumps(configs, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return True


def srm_remove_parser(parser_path: Path) -> bool:
    srm_user_configurations = Path(srm_path) / "userData" / "userConfigurations.json"
    if not srm_user_configurations.exists():
        return False
    parser_id = srm_get_parser(parser_path).get("parserId")

    configs = json.loads(srm_user_configurations.read_text(encoding="utf-8"))
    remaining = [item for item in configs if item.get("parserId") != parser_id]
    if len(remaining) == len(configs):
        print(f"Parser {parser_id} not found in SRM configuration")
        return True

    srm_user_configurations.write_text(
        json.dumps(remaining, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return True


def srm_get_emulator_parsers(emu: str) -> list:
    parsers = []
    for os_dir in ("common", system):
        folder = Path(emudeck_backend) / "configs" / os_dir / "srm" / "userData" / "parsers" / "optional" / emu
        if folder.is_dir():
            parsers += sorted(folder.glob("*.json"))
    return parsers


def srm_add_emulator_parsers(emu: str) -> None:
    if not srm_is_installed():
        return
    for parser in srm_get_emulator_parsers(emu):
        srm_add_parser(parser)
    srm_sort_parsers()


def srm_remove_emulator_parsers(emu: str) -> None:
    for parser in srm_get_emulator_parsers(emu):
        srm_remove_parser(parser)


def srm_sort_parsers() -> None:
    srm_user_configurations = Path(srm_path) / "userData" / "userConfigurations.json"
    if not srm_user_configurations.is_file():
        return
    srm_top_parsers = (
        "Emulators - Emulators",
        "Cloud Services - Cloud Services",
        "Generic Applications - Generic Applications",
        "Remote Play Clients - Remote Play Clients",
        "Desktop Applications",
    )

    def natural(text):
        return [int(part) if part.isdigit() else part.casefold() for part in re.split(r"(\d+)", text)]

    def sort_key(cfg):
        title = cfg.get("configTitle", "")
        if title in srm_top_parsers:
            return (0, srm_top_parsers.index(title), [], [])
        system_name, _, emulator = title.partition(" - ")
        return (1, 0, natural(system_name), natural(emulator))

    configs = json.loads(srm_user_configurations.read_text(encoding="utf-8"))
    srm_user_configurations.write_text(
        json.dumps(sorted(configs, key=sort_key), indent=2, ensure_ascii=False), encoding="utf-8"
    )


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

def srm_add_optional_parsers():
    folders = [Path(emudeck_backend) / "configs" / os_dir / "srm" / "userData" / "parsers" / "optional" for os_dir in ("common", system)]
    emulators = sorted({d.name for folder in folders if folder.is_dir() for d in folder.iterdir() if d.is_dir()})
    for emu in emulators:
        is_installed = globals().get(f"{emu}_is_installed")
        if emu == "steam" or (is_installed and is_installed()):
            for parser in srm_get_emulator_parsers(emu):
                srm_add_parser(parser)
    srm_sort_parsers()
