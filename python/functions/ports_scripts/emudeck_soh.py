from core.all import *

soh_folder = ports_folder / "soh"


def soh_install():
    set_msg("Installing Ship of Harkinian")
    if system == "darwin":
        file_type = "zip"
        look_for = "Mac"
    if system == "linux":
        file_type = "appimage"
        look_for = ""
    if system.startswith("win"):
        file_type = "zip"
        look_for = "Win64"

    temp = Path(tempfile.mkdtemp())
    try:
        url = get_latest_release_gh("HarbourMasters/Shipwright", file_type, look_for)
        archive = temp / f"soh.{file_type}"
        if not url or not safeDownload("Ship of Harkinian", url, archive):
            return False

        shutil.rmtree(soh_folder, ignore_errors=True)
        soh_folder.mkdir(parents=True, exist_ok=True)

        if system == "darwin":
            subprocess.run(["ditto", "-x", "-k", str(archive), str(temp)], check=True)
            mount_point = mount_dmg(temp / "SoH.dmg")
            try:
                shutil.copytree(mount_point / "soh.app", soh_folder / "soh.app", symlinks=True)
            finally:
                subprocess.run(["hdiutil", "detach", str(mount_point)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if system == "linux":
            shutil.move(str(archive), str(soh_folder / "soh.AppImage"))
        if system.startswith("win"):
            extract(archive, soh_folder)

        return soh_is_installed()
    except Exception as error:
        print(f"Error installing Ship of Harkinian: {error}")
        return False
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def soh_init():
    set_msg("Setting up Ship of Harkinian")
    if system == "darwin":
        darwin_trust_app(soh_folder / "soh.app")
    if system == "linux":
        (soh_folder / "soh.AppImage").chmod(0o755)
    return True


def soh_install_init():
    return soh_install() and soh_init()


def soh_uninstall():
    shutil.rmtree(soh_folder, ignore_errors=True)
    return True


def soh_is_available():
    return True


def soh_is_installed():
    if system == "darwin":
        return (soh_folder / "soh.app").exists()
    if system == "linux":
        return (soh_folder / "soh.AppImage").exists()
    if system.startswith("win"):
        return (soh_folder / "soh.exe").exists()


def soh_launch():
    if system == "darwin":
        command = ["open", str(soh_folder / "soh.app")]
    if system == "linux":
        command = [str(soh_folder / "soh.AppImage")]
    if system.startswith("win"):
        command = [str(soh_folder / "soh.exe")]
    subprocess.Popen(command, cwd=soh_folder, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    return True
