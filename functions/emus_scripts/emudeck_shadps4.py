from core.all import *
from pathlib import Path


def shadps4_install():
    set_msg("Installing shadps4")

    if system == "linux":
        try:
            api_url = "https://api.github.com/repos/shadps4-emu/shadps4-qtlauncher/releases"
            headers = {"User-Agent": "EmuDeck"}

            resp = requests.get(api_url, headers=headers, timeout=30)
            resp.raise_for_status()
            releases = resp.json()
            if not releases:
                print("ShadPS4: no releases found.")
                return False

            release = releases[0]
            url = None
            for asset in release.get("assets", []):
                name = (asset.get("name") or "").lower()
                dl = (asset.get("browser_download_url") or "")
                if ("linux-qt" in name) and name.endswith(".zip"):
                    url = dl
                    break

            if not url:
                print("ShadPS4: no linux-qt ZIP files were found in the latest release.")
                return False

            dest_dir = Path(emus_folder)
            dest_dir.mkdir(parents=True, exist_ok=True)

            tmp = Path(tempfile.mkdtemp())
            try:
                zip_path = tmp / "ShadPS4.zip"

                r = requests.get(url, stream=True, headers=headers, timeout=60)
                r.raise_for_status()
                with open(zip_path, "wb") as f:
                    for chunk in r.iter_content(chunk_size=1024 * 1024):
                        if chunk:
                            f.write(chunk)

                with zipfile.ZipFile(zip_path, "r") as zf:
                    zf.extractall(path=dest_dir)

            finally:
                shutil.rmtree(tmp, ignore_errors=True)

            target = dest_dir / "Shadps4-qt.AppImage"
            if target.exists():
                target.unlink()

            appimages = sorted(dest_dir.glob("shadPS4QtLauncher-qt*.AppImage"))
            if not appimages:
                appimages = sorted(dest_dir.glob("*.AppImage"))

            if not appimages:
                print("ShadPS4: no AppImage found after extracting zip.")
                return False

            appimages[0].rename(target)
            target.chmod(0o755)

            create_app_shortcut("ShadPS4")
            return True

        except Exception as e:
            print(f"Error during install: {e}")
            return False

    elif system.startswith("win"):
        try:
            api_url = "https://api.github.com/repos/shadps4-emu/shadps4-qtlauncher/releases"
            headers = {"User-Agent": "EmuDeck"}

            resp = requests.get(api_url, headers=headers, timeout=30)
            resp.raise_for_status()
            releases = resp.json()
            if not releases:
                print("ShadPS4: no releases found.")
                return False

            release = releases[0]
            url = None
            for asset in release.get("assets", []):
                dl = asset.get("browser_download_url", "")
                if ("win64" in dl.lower()) and dl.lower().endswith(".zip"):
                    url = dl
                    break

            if not url:
                print("ShadPS4: no Win64 ZIP files were found in the latest release.")
                return False

            destination = emus_folder / "ShadPS4-qt"
            return install_emu("shadps4", url, "zip", destination)

        except Exception as e:
            print(f"Error during install: {e}")
            return False

    elif system == "darwin":
        type_ = "zip"
        look_for = "macos-qt"
        path = emus_folder

    else:
        print(f"Unsupported system: {system}")
        return False

    try:
        repo = get_latest_release_gh("shadps4-emu/shadPS4", type_, look_for)
        return install_emu("shadps4", repo, type_, path)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def shadps4_uninstall():
    try:
        if system == "linux":
            uninstall_emu("Shadps4-qt", "AppImage")

            base = Path.home() / ".local" / "share"
            for p in (
                base / "applications" / "ShadPS4.desktop",
                base / "shadPS4",
                base / "shadPS4QtLauncher",
            ):
                if p.is_dir():
                    shutil.rmtree(p, ignore_errors=True)
                elif p.exists():
                    p.unlink()

        elif system.startswith("win"):
            uninstall_emu("ShadPS4-qt", "dir")

            start_menu = Path(os.environ["APPDATA"]) / "Microsoft" / "Windows" / "Start Menu" / "Programs" / "EmuDeck" / "shadps4.lnk"
            if start_menu.exists():
                start_menu.unlink()

        elif system == "darwin":
            uninstall_emu("shadps4", "app")

        else:
            return False

        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def shadps4_is_installed():
    if system == "linux":
        return (emus_folder / "Shadps4-qt.AppImage").exists()

    if system.startswith("win"):
        base = emus_folder / "ShadPS4-qt"
        return (base / "shadPS4QtLauncher.exe").exists() or (base / "shadps4.exe").exists()

    if system == "darwin":
        return (emus_folder / "shadps4.app").exists()

    return False


def shadps4_install_init():
    if not shadps4_install():
        return False
    return shadps4_init()


def shadps4_init():
    set_msg("Setting up shadps4")

    if system == "linux":
        destination = f"{home}/.local/share/shadPS4"

    elif system.startswith("win"):
        destination = f"{emus_folder}/ShadPS4-qt/user"

    elif system == "darwin":
        destination = f"{home}/Library/Application Support/shadPS4"

    else:
        return False

    shadps4_setup_storage()
    copy_and_set_settings_file("common/shadps4/config.toml", destination)
    shadps4_set_emulation_folder()
    shadps4_setup_saves()

    esde_set_emu("ShadPS4 Shortcuts (Standalone)", "ps4")
    return True


def shadps4_setup_storage():
    base = Path(storage_path) / "shadps4"
    (base / "games").mkdir(parents=True, exist_ok=True)
    (base / "dlc").mkdir(parents=True, exist_ok=True)


def shadps4_setup_saves():
    origin_saves = None

    if system == "linux":
        origin_saves = f"{home}/.local/share/shadPS4/savedata"

    elif system.startswith("win"):
        base_user = Path(emus_folder) / "ShadPS4-qt" / "user"
        savedata_path = base_user / "savedata"
        savedata_path.mkdir(parents=True, exist_ok=True)
        origin_saves = str(savedata_path)

    elif system == "darwin":
        origin_saves = f"{home}/Library/Application Support/shadPS4/savedata"

    else:
        return False

    move_contents_and_link(origin_saves, f"{saves_path}/shadps4/saves")
    return True


def shadps4_set_emulation_folder():
    if system == "linux":
        config_path = Path(home) / ".local" / "share" / "shadPS4" / "config.toml"
        if not config_path.exists():
            print(f"ShadPS4: config.toml not found at {config_path}")
            return False

        txt = config_path.read_text(encoding="utf-8", errors="ignore")
        txt = txt.replace("/run/media/mmcblk0p1/Emulation", str(emulation_path))
        config_path.write_text(txt, encoding="utf-8")

        (Path(bios_path) / "shadps4").mkdir(parents=True, exist_ok=True)
        sys_modules = Path(home) / ".local" / "share" / "shadPS4" / "sys_modules"
        sys_modules.mkdir(parents=True, exist_ok=True)

        link_dst = Path(bios_path) / "shadps4" / "sys_modules"
        if link_dst.is_symlink() or link_dst.exists():
            link_dst.unlink()
        link_dst.symlink_to(sys_modules, target_is_directory=True)
        return True

    if system.startswith("win"):
        config_path = Path(emus_folder) / "ShadPS4-qt" / "user" / "config.toml"
        if not config_path.exists():
            print(f"ShadPS4: config.toml not found at {config_path}")
            return False

        txt = config_path.read_text(encoding="utf-8", errors="ignore")
        txt = txt.replace("/run/media/mmcblk0p1/Emulation", str(emulation_path))
        txt = txt.replace("\\", "/")
        config_path.write_text(txt, encoding="utf-8")
        return True

    return True