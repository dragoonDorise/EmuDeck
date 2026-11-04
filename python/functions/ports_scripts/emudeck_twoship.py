from core.all import *

twoship_folder = ports_folder / "twoship"


def twoship_install():
    set_msg("Installing 2 Ship 2 Harkinian")
    if system == "darwin":
        look_for = "Mac"
    if system == "linux":
        look_for = "Linux"
    if system.startswith("win"):
        look_for = "Win64"

    temp = Path(tempfile.mkdtemp())
    try:
        url = get_latest_release_gh("2ship2harkinian/2ship2harkinian", "zip", look_for)
        archive = temp / "twoship.zip"
        if not url or not safeDownload("2 Ship 2 Harkinian", url, archive):
            return False

        shutil.rmtree(twoship_folder, ignore_errors=True)
        twoship_folder.mkdir(parents=True, exist_ok=True)

        if system == "darwin":
            subprocess.run(["ditto", "-x", "-k", str(archive), str(temp)], check=True)
            mount_point = mount_dmg(temp / "2Ship.dmg")
            try:
                shutil.copytree(mount_point / "2s2h.app", twoship_folder / "2s2h.app", symlinks=True)
            finally:
                subprocess.run(["hdiutil", "detach", str(mount_point)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            extract(archive, twoship_folder)

        return twoship_is_installed()
    except Exception as error:
        print(f"Error installing 2 Ship 2 Harkinian: {error}")
        return False
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def twoship_init():
    set_msg("Setting up 2 Ship 2 Harkinian")
    if system == "darwin":
        darwin_trust_app(twoship_folder / "2s2h.app")
    if system == "linux":
        (twoship_folder / "2ship.appimage").chmod(0o755)
    return True


def twoship_install_init():
    return twoship_install() and twoship_init()


def twoship_uninstall():
    shutil.rmtree(twoship_folder, ignore_errors=True)
    return True


def twoship_is_available():
    return True


def twoship_is_installed():
    if system == "darwin":
        return (twoship_folder / "2s2h.app").exists()
    if system == "linux":
        return (twoship_folder / "2ship.appimage").exists()
    if system.startswith("win"):
        return (twoship_folder / "2ship.exe").exists()


def twoship_launch():
    if system == "darwin":
        command = ["open", str(twoship_folder / "2s2h.app")]
    if system == "linux":
        command = [str(twoship_folder / "2ship.appimage")]
    if system.startswith("win"):
        command = [str(twoship_folder / "2ship.exe")]
    subprocess.Popen(command, cwd=twoship_folder, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    return True
