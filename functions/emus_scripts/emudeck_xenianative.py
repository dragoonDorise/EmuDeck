from core.all import *

xenianative_app_image = emus_folder / "Xenia.AppImage"
xenianative_data_path = home / ".local" / "share" / "Xenia"
xenianative_content_path = xenianative_data_path / "content"
xenianative_patches_path = xenianative_data_path / "patches"
xenianative_settings_file = xenianative_data_path / "xenia-edge.config.toml"


def xenianative_supported():
    return system == "linux"


def xenianative_install():
    if not xenianative_supported():
        return False
    set_msg("Installing Xenia")
    try:
        if cpu_arch == "arm":
            repo = get_latest_release_gh("dragoonDorise/xenia-edge-arm", ".AppImage", "xenia")
        else:
            repo = get_latest_release_gh("has207/xenia-edge", ".AppImage", "Xenia_canary")
        if not repo:
            print("Could not find latest Xenia Linux AppImage release.")
            return False
        emus_folder.mkdir(parents=True, exist_ok=True)
        (roms_path / "xbox360").mkdir(parents=True, exist_ok=True)
        if not safeDownload("Xenia", repo, xenianative_app_image, True):
            return False
        xenianative_app_image.chmod(xenianative_app_image.stat().st_mode | 0o111)
        return True
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def xenianative_uninstall():
    if not xenianative_supported():
        return False
    try:
        xenianative_app_image.unlink(missing_ok=True)
        (home / ".local" / "share" / "applications" / "xenia-emu.desktop").unlink(missing_ok=True)
        (tools_path / "launchers" / "xenia-emu.sh").unlink(missing_ok=True)
        (roms_path / "emulators" / "xenia-emu.sh").unlink(missing_ok=True)
        if xenianative_data_path.is_dir():
            for item in xenianative_data_path.iterdir():
                if item.name == "content":
                    continue
                if item.is_dir() and not item.is_symlink():
                    shutil.rmtree(item, ignore_errors=True)
                else:
                    item.unlink(missing_ok=True)
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False


def xenianative_is_installed():
    if not xenianative_supported():
        return False
    return xenianative_app_image.exists()


def xenianative_init():
    if not xenianative_supported():
        return False
    set_msg("Setting up Xenia")
    xenianative_data_path.mkdir(parents=True, exist_ok=True)
    (roms_path / "xbox360" / "xbla").mkdir(parents=True, exist_ok=True)
    copy_and_set_settings_file("common/xenia/xenia-edge.config.toml", xenianative_data_path)
    xenianative_set_config_defaults()
    xenianative_setup_saves()
    xenianative_get_patches()
    flush_emulator_launchers("xenia-emu")
    xenianative_add_es_config()
    xenianative_add_custom_parser()
    return True


def xenianative_install_init():
    if not xenianative_install():
        return False
    return xenianative_init()


def xenianative_set_config_defaults():
    if not xenianative_settings_file.is_file():
        return
    text = xenianative_settings_file.read_text(encoding="utf-8")
    text = re.sub(r"^gpu = .*$", 'gpu = "vulkan"', text, flags=re.M)
    text = re.sub(r"^fullscreen = .*$", "fullscreen = true", text, flags=re.M)
    xenianative_settings_file.write_text(text, encoding="utf-8")


def xenianative_setup_saves():
    xenianative_content_path.mkdir(parents=True, exist_ok=True)
    move_contents_and_link(xenianative_content_path, f"{saves_path}/xenia/saves")


def xenianative_get_patches():
    patches_url = "https://github.com/xenia-canary/game-patches/archive/refs/heads/main.zip"
    patches_zip = xenianative_data_path / "game-patches.zip"
    xenianative_patches_path.mkdir(parents=True, exist_ok=True)
    if not safeDownload("Xenia patches", patches_url, patches_zip, False):
        print("Xenia patches download failed.")
        return False
    try:
        with zipfile.ZipFile(patches_zip) as archive:
            archive.extractall(xenianative_data_path)
        extracted = xenianative_data_path / "game-patches-main" / "patches"
        if extracted.is_dir():
            for patch in extracted.iterdir():
                target = xenianative_patches_path / patch.name
                if not target.exists():
                    shutil.move(str(patch), str(target))
        shutil.rmtree(xenianative_data_path / "game-patches-main", ignore_errors=True)
        print("Xenia patches updated.")
        return True
    except (OSError, zipfile.BadZipFile) as e:
        print(f"Error extracting Xenia patches: {e}")
        return False
    finally:
        patches_zip.unlink(missing_ok=True)


def xenianative_add_custom_parser():
    if xenianative_is_installed() and srm_is_installed():
        add_parser("microsoft_xbox360_iso_xenia")
        add_parser("microsoft_xbox360_xbla_xenia")


def xenianative_add_es_config():
    if Path(esde_rules_file).is_file():
        sed("launchers/xenia.sh", "launchers/xenia-emu.sh", str(esde_rules_file))


def xenianative_set_resolution():
    print("NYI")


def xenianative_add_to_steam():
    if not xenianative_supported():
        return
    set_msg("Adding Xenia to Steam")
    launcher = tools_path / "launchers" / "xenia-emu.sh"
    add_steam_shortcut("xenia", "Xenia", str(launcher), str(emus_folder), str(emudeck_backend / "icons/ico/xenia.ico"))
