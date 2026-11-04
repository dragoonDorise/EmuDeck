from core.all import *

ghostship_folder = ports_folder / "ghostship"


def ghostship_install():
    set_msg("Installing Ghostship")
    if system == "darwin":
        look_for = "Mac"
    if system == "linux":
        look_for = "Linux"
    if system.startswith("win"):
        look_for = "Win64"

    temp = Path(tempfile.mkdtemp())
    try:
        url = get_latest_release_gh("HarbourMasters/Ghostship", "zip", look_for)
        archive = temp / "ghostship.zip"
        if not url or not safeDownload("Ghostship", url, archive):
            return False

        shutil.rmtree(ghostship_folder, ignore_errors=True)
        ghostship_folder.mkdir(parents=True, exist_ok=True)

        if system == "darwin":
            subprocess.run(["ditto", "-x", "-k", str(archive), str(ghostship_folder)], check=True)
            dmg = ghostship_folder / "Ghostship.dmg"
            mount_point = mount_dmg(dmg)
            if not mount_point:
                return False
            try:
                app = next(mount_point.glob("*.app"))
                shutil.copytree(app, ghostship_folder / "Ghostship.app", symlinks=True)
            finally:
                subprocess.run(["hdiutil", "detach", str(mount_point)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                dmg.unlink(missing_ok=True)
        else:
            extract(archive, ghostship_folder)

        return ghostship_is_installed()
    except Exception as error:
        print(f"Error installing Ghostship: {error}")
        return False
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def ghostship_init():
    set_msg("Setting up Ghostship")
    if system == "darwin":
        darwin_trust_app(ghostship_folder / "Ghostship.app")
    if system == "linux":
        (ghostship_folder / "ghostship.appimage").chmod(0o755)
    return True


def ghostship_install_init():
    return ghostship_install() and ghostship_init()


def ghostship_uninstall():
    shutil.rmtree(ghostship_folder, ignore_errors=True)
    return True


def ghostship_is_available():
    return True


def ghostship_is_installed():
    if system == "darwin":
        return (ghostship_folder / "Ghostship.app").exists()
    if system == "linux":
        return (ghostship_folder / "ghostship.appimage").exists()
    if system.startswith("win"):
        return (ghostship_folder / "Ghostship.exe").exists()


def ghostship_launch():
    if system == "darwin":
        command = ["open", str(ghostship_folder / "Ghostship.app")]
    if system == "linux":
        command = [str(ghostship_folder / "ghostship.appimage")]
    if system.startswith("win"):
        command = [str(ghostship_folder / "Ghostship.exe")]
    subprocess.Popen(command, cwd=ghostship_folder, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    return True
