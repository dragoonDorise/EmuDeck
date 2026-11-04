from core.all import *

starship_folder = ports_folder / "starship"


def starship_install():
    set_msg("Installing Starship")
    if system == "darwin":
        print("Starship has no macOS release.")
        return False
    if system == "linux":
        look_for = "Linux"
    if system.startswith("win"):
        look_for = "Windows"

    temp = Path(tempfile.mkdtemp())
    try:
        url = get_latest_release_gh("HarbourMasters/Starship", "zip", look_for)
        archive = temp / "starship.zip"
        if not url or not safeDownload("Starship", url, archive):
            return False

        shutil.rmtree(starship_folder, ignore_errors=True)
        starship_folder.mkdir(parents=True, exist_ok=True)
        extract(archive, starship_folder)

        return starship_is_installed()
    except Exception as error:
        print(f"Error installing Starship: {error}")
        return False
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def starship_init():
    set_msg("Setting up Starship")
    if system == "linux":
        (starship_folder / "starship.appimage").chmod(0o755)
    return True


def starship_install_init():
    return starship_install() and starship_init()


def starship_uninstall():
    shutil.rmtree(starship_folder, ignore_errors=True)
    return True


def starship_is_available():
    return system != "darwin"


def starship_is_installed():
    if system == "linux":
        return (starship_folder / "starship.appimage").exists()
    if system.startswith("win"):
        return (starship_folder / "Starship.exe").exists()
    return False


def starship_launch():
    if system == "linux":
        command = [str(starship_folder / "starship.appimage")]
    if system.startswith("win"):
        command = [str(starship_folder / "Starship.exe")]
    subprocess.Popen(command, cwd=starship_folder, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    return True
