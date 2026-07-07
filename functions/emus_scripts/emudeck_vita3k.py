from core.all import *

def vita3k_install():
    set_msg(f"Installing Vita3K")

    if system == "linux":
        asset = "Vita3K-aarch64.AppImage" if cpu_arch == "arm" else "Vita3K-x86_64.AppImage"
        repo = get_latest_release_gh("Vita3K/Vita3K", "AppImage", asset)
        if not repo:
            print(f"Error: could not find {asset}")
            return False

        install_path = emus_folder / "Vita3K"
        binary_path = install_path / "Vita3K"

        temp_dir = Path(tempfile.mkdtemp())
        appimage_path = temp_dir / "Vita3K.AppImage"

        try:
            response = requests.get(repo, stream=True, timeout=30)
            response.raise_for_status()

            with open(appimage_path, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)

            shutil.rmtree(install_path, ignore_errors=True)
            install_path.mkdir(parents=True, exist_ok=True)

            shutil.move(str(appimage_path), str(binary_path))
            binary_path.chmod(
                binary_path.stat().st_mode |
                stat.S_IXUSR |
                stat.S_IXGRP |
                stat.S_IXOTH
            )

            create_app_shortcut("Vita3K")
            return True

        finally:
            shutil.rmtree(temp_dir, ignore_errors=True)

    if system.startswith("win"):
        type="zip"
        look_for="windows-latest"
        path=f"{emus_folder}/vita3k"

    if system == "darwin":
        type="dmg"
        look_for="macos-latest"
        path=emus_folder

    try:
        repo=get_latest_release_gh("Vita3K/Vita3K",type,look_for)
        install_emu("vita3k", repo, type, path)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def vita3k_uninstall():
    try:
        if system == "linux":
            uninstall_emu("Vita3K", "dir")
        if system.startswith("win"):
            uninstall_emu("vita3k", "dir")
        if system == "darwin":
            uninstall_emu("Vita3K", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def vita3k_is_installed():
    if system == "linux":
        return (emus_folder / "Vita3K" / "Vita3K").exists()
    if system.startswith("win"):
        return (emus_folder / "vita3k" / "vita3k.exe").exists()
    if system == "darwin":
        return (emus_folder / "Vita3K.app").exists()


def vita3k_init():
    set_msg(f"Setting up Vita3K")
    if system == "linux":
        destination = f"{home}/.config/Vita3K"
    if system.startswith("win"):
        destination = f"{emus_folder}/vita3k/"
    if system == "darwin":
        destination = f"{home}/.config/vita3k/"

    copy_and_set_settings_file(f"common/vita3k/config.yml", destination)

    config_file = Path(destination) / "config.yml"
    sed("STORAGEPATH", str(storage_path).replace("\\", "/"), config_file)

    vita3k_setup_storage()
    vita3k_setup_saves()

def vita3k_install_init():
    vita3k_install()
    vita3k_init()


def vita3k_setup_saves():
    origin_saves=f"{storage_path}/Vita3K/ux0/user/00/savedata"
    move_contents_and_link(origin_saves,f"{saves_path}/Vita3K/saves")

def vita3k_setup_storage():
    installed_games = f"{roms_path}/psvita/InstalledGames"
    vita3k_apps = f"{storage_path}/Vita3K/ux0/app"
    move_contents_and_link(vita3k_apps, installed_games)