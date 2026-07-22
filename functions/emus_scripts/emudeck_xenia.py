import shutil
import zipfile

from core.all import *


def xenia_install():
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
        return (emus_folder / "xenia.app").exists()

    return False


def xenia_init():
    set_msg("Setting up Xenia")

    if system == "linux":
        destination = roms_path / "xbox360"
        (destination / "roms" / "xbla").mkdir(parents=True, exist_ok=True)

    if system.startswith("win"):
        destination = f"{emus_folder}/xenia/"

    if system == "darwin":
        destination = f"{home}/.config/xenia/"

    copy_and_set_settings_file("common/xenia/xenia-canary.config.toml", destination)
    copy_and_set_settings_file("common/xenia/xenia.config.toml", destination)
    copy_and_set_settings_file("common/xenia/portable.txt", destination)

    xenia_setup_saves()

    if system == "linux":
        addProtonLaunch()

    return True


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
        origin_saves = f"{home}/.share/xenia/sdmc"

    move_contents_and_link(origin_saves, f"{saves_path}/xenia/saves")


def xenia_get_patches():
    xenia_path = roms_path / "xbox360"
    patches_zip = xenia_path / "game-patches.zip"
    patches_url = (
        "https://github.com/xenia-canary/game-patches/releases/latest/"
        "download/game-patches.zip"
    )

    if not safeDownload("Xenia patches", patches_url, patches_zip, False):
        print("Xenia patches could not be downloaded.")
        return False

    try:
        with zipfile.ZipFile(patches_zip) as archive:
            archive.extractall(xenia_path)
        print("Xenia patches updated.")
        return True
    except (OSError, zipfile.BadZipFile) as error:
        print(f"Error extracting Xenia patches: {error}")
        return False
    finally:
        patches_zip.unlink(missing_ok=True)