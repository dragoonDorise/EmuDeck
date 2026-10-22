import shutil
import zipfile

from core.all import *

xenia_mac_app = emus_folder / "xenia.app"
xenia_mac_data_path = home / ".local" / "share" / "Xenia"
xenia_mac_settings_file = xenia_mac_data_path / "xenia-edge.config.toml"


def xenia_install():
    stat_install("xenia")
    set_msg("Installing Xenia")

    if system == "linux":
        type = "zip"
        look_for = "windows"
        path = roms_path / "xbox360"
        zip_path = path / "xenia.zip"

        path.mkdir(parents=True, exist_ok=True)

        try:
            repo = get_latest_release_gh(
                "xenia-canary/xenia-canary-releases",
                type,
                look_for,
            )

            if not safeDownload("Xenia", repo, zip_path, True):
                return False

            with zipfile.ZipFile(zip_path) as archive:
                archive.extractall(path)

            license_file = path / "LICENSE"
            if license_file.is_file():
                license_file.replace(path / "LICENSE.TXT")

            create_app_shortcut("xenia")
            xenia_get_patches()
            return True

        except (OSError, zipfile.BadZipFile) as error:
            print(f"Error during Xenia installation: {error}")
            return False

        finally:
            zip_path.unlink(missing_ok=True)

    if system.startswith("win"):
        type = "zip"
        look_for = "windows"
        path = f"{emus_folder}/xenia"

    if system == "darwin":
        try:
            repo = get_latest_release_gh("has207/xenia-edge", "dmg", "macos")
            if not repo:
                print("Could not find latest Xenia macOS release.")
                return False
            install_emu("xenia", repo, "dmg", emus_folder)
            edge_app = emus_folder / "Xenia-edge.app"
            if edge_app.exists():
                shutil.rmtree(xenia_mac_app, ignore_errors=True)
                edge_app.rename(xenia_mac_app)
            return xenia_is_installed()
        except Exception as error:
            print(f"Error during install: {error}")
            return False

    try:
        repo = get_latest_release_gh(
            "xenia-canary/xenia-canary-releases",
            type,
            look_for,
        )
        install_emu("xenia", repo, type, path)
        return True
    except Exception as error:
        print(f"Error during install: {error}")
        return False


def xenia_uninstall():
    try:
        srm_remove_emulator_parsers("xenia")
        if system == "linux":
            xenia_path = roms_path / "xbox360"

            if xenia_path.is_dir():
                for item in xenia_path.iterdir():
                    if item.name in {"roms", "content"}:
                        continue

                    if item.is_dir():
                        shutil.rmtree(item, ignore_errors=True)
                    else:
                        item.unlink(missing_ok=True)

            (tools_path / "launchers" / "xenia.sh").unlink(missing_ok=True)
            (
                home / ".local" / "share" / "applications" / "xenia.desktop"
            ).unlink(missing_ok=True)

        if system.startswith("win"):
            uninstall_emu("xenia", "dir")

        if system == "darwin":
            uninstall_emu("xenia", "app")

        return True
    except Exception as error:
        print(f"Error during uninstall: {error}")
        return False


def xenia_is_installed():
    if system == "linux":
        return (roms_path / "xbox360" / "xenia_canary.exe").is_file()

    if system.startswith("win"):
        return (emus_folder / "xenia" / "xenia_canary.exe").is_file()

    if system == "darwin":
        return xenia_mac_app.exists()

    return False


def xenia_init():
    set_msg("Setting up Xenia")
    flush_emulator_launchers("xenia")

    if system == "linux":
        destination = roms_path / "xbox360"
        (destination / "roms" / "xbla").mkdir(parents=True, exist_ok=True)

    if system.startswith("win"):
        destination = f"{emus_folder}/xenia/"

    if system == "darwin":
        xenia_mac_data_path.mkdir(parents=True, exist_ok=True)
        (roms_path / "xbox360" / "roms" / "xbla").mkdir(parents=True, exist_ok=True)
        copy_and_set_settings_file("common/xenia/xenia-edge.config.toml", xenia_mac_data_path)
        if xenia_mac_settings_file.is_file():
            text = xenia_mac_settings_file.read_text(encoding="utf-8")
            text = re.sub(r"^gpu = .*$", 'gpu = "metal"', text, flags=re.M)
            text = re.sub(r"^apu = .*$", 'apu = "sdl"', text, flags=re.M)
            text = re.sub(r"^hid = .*$", 'hid = "sdl"', text, flags=re.M)
            text = re.sub(r"^fullscreen = .*$", "fullscreen = true", text, flags=re.M)
            text = re.sub(r"^log_file = .*$", f'log_file = "{xenia_mac_data_path / "xenia.log"}"', text, flags=re.M)
            xenia_mac_settings_file.write_text(text, encoding="utf-8")
        (xenia_mac_app / "Contents" / "MacOS" / "xenia.log").unlink(missing_ok=True)
        xenia_get_patches()
    else:
        copy_and_set_settings_file("common/xenia/xenia-canary.config.toml", destination)
        copy_and_set_settings_file("common/xenia/xenia.config.toml", destination)
        copy_and_set_settings_file("common/xenia/portable.txt", destination)

    xenia_setup_saves()
    srm_add_emulator_parsers("xenia")

    if esde_is_installed():
        xenia_add_es_config()
    return True


def xenia_set_resolution():
    print("NYI")


def xenia_install_init():
    if not xenia_install():
        return False

    return xenia_init()


def xenia_setup_saves():
    if system == "linux":
        origin_saves = f"{roms_path}/xbox360/content"

    if system.startswith("win"):
        origin_saves = f"{emus_folder}/xenia/content"

    if system == "darwin":
        origin_saves = xenia_mac_data_path / "content"

    link_to_saves_folder(origin_saves, "xenia/saves")


def xenia_get_patches():
    xenia_path = xenia_mac_data_path if system == "darwin" else roms_path / "xbox360"
    patches_path = xenia_path / "patches"
    patches_zip = xenia_path / "game-patches.zip"
    patches_url = "https://github.com/xenia-canary/game-patches/archive/refs/heads/main.zip"

    patches_path.mkdir(parents=True, exist_ok=True)
    if not safeDownload("Xenia patches", patches_url, patches_zip, False):
        print("Xenia patches could not be downloaded.")
        return False

    try:
        with zipfile.ZipFile(patches_zip) as archive:
            archive.extractall(xenia_path)
        extracted = xenia_path / "game-patches-main" / "patches"
        if extracted.is_dir():
            for patch in extracted.iterdir():
                target = patches_path / patch.name
                if not target.exists():
                    shutil.move(str(patch), str(target))
        shutil.rmtree(xenia_path / "game-patches-main", ignore_errors=True)
        print("Xenia patches updated.")
        return True
    except (OSError, zipfile.BadZipFile) as error:
        print(f"Error extracting Xenia patches: {error}")
        return False
    finally:
        patches_zip.unlink(missing_ok=True)

def xenia_add_to_steam():
    set_msg("Adding Xenia to Steam")
    launcher = tools_path / "launchers" / ("xenia.bat" if system.startswith("win") else "xenia.sh")
    add_steam_shortcut("xenia", "Xenia", str(launcher), str(emus_folder), str(icons_path / "ico/xenia.ico"))


def xenia_add_es_config():
    return esde_add_custom_systems_file()
