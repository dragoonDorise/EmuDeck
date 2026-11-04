from core.all import *

opengoal_folder = ports_folder / "opengoal"


def opengoal_install():
    set_msg("Installing OpenGOAL")
    if system == "darwin":
        file_type = "dmg"
        look_for = "aarch64"
    if system == "linux":
        file_type = "AppImage"
        look_for = "amd64"
    if system.startswith("win"):
        print("OpenGOAL only ships an msi installer on Windows.")
        return False

    temp = Path(tempfile.mkdtemp())
    try:
        url = get_latest_release_gh("open-goal/launcher", file_type, look_for)
        archive = temp / f"opengoal.{file_type}"
        if not url or not safeDownload("OpenGOAL", url, archive):
            return False

        shutil.rmtree(opengoal_folder, ignore_errors=True)
        opengoal_folder.mkdir(parents=True, exist_ok=True)

        if system == "darwin":
            mount_point = mount_dmg(archive)
            try:
                shutil.copytree(mount_point / "OpenGOAL-Launcher.app", opengoal_folder / "OpenGOAL-Launcher.app", symlinks=True)
            finally:
                subprocess.run(["hdiutil", "detach", str(mount_point)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if system == "linux":
            shutil.move(str(archive), str(opengoal_folder / "OpenGOAL-Launcher.AppImage"))

        return opengoal_is_installed()
    except Exception as error:
        print(f"Error installing OpenGOAL: {error}")
        return False
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def opengoal_init():
    set_msg("Setting up OpenGOAL")
    if system == "darwin":
        darwin_trust_app(opengoal_folder / "OpenGOAL-Launcher.app")
    if system == "linux":
        (opengoal_folder / "OpenGOAL-Launcher.AppImage").chmod(0o755)
    return True


def opengoal_install_init():
    return opengoal_install() and opengoal_init()


def opengoal_uninstall():
    shutil.rmtree(opengoal_folder, ignore_errors=True)
    return True


def opengoal_is_available():
    return not system.startswith("win")


def opengoal_is_installed():
    if system == "darwin":
        return (opengoal_folder / "OpenGOAL-Launcher.app").exists()
    if system == "linux":
        return (opengoal_folder / "OpenGOAL-Launcher.AppImage").exists()
    return False


def opengoal_launch():
    if system == "darwin":
        command = ["open", str(opengoal_folder / "OpenGOAL-Launcher.app")]
    if system == "linux":
        command = [str(opengoal_folder / "OpenGOAL-Launcher.AppImage")]
    subprocess.Popen(command, cwd=opengoal_folder, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    return True
