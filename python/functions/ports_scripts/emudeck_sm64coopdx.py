from core.all import *

sm64coopdx_folder = ports_folder / "sm64coopdx"


def sm64coopdx_install():
    set_msg("Installing Super Mario 64 Coop Deluxe")
    if system == "darwin":
        look_for = "macOS_ARM"
    if system == "linux":
        look_for = "Linux"
    if system.startswith("win"):
        look_for = "Windows"

    temp = Path(tempfile.mkdtemp())
    try:
        url = get_latest_release_gh("coop-deluxe/sm64coopdx", "zip", look_for)
        archive = temp / "sm64coopdx.zip"
        if not url or not safeDownload("Super Mario 64 Coop Deluxe", url, archive):
            return False

        shutil.rmtree(sm64coopdx_folder, ignore_errors=True)
        sm64coopdx_folder.mkdir(parents=True, exist_ok=True)

        if system == "darwin":
            subprocess.run(["ditto", "-x", "-k", str(archive), str(sm64coopdx_folder)], check=True)
        else:
            extract(archive, sm64coopdx_folder)

        return sm64coopdx_is_installed()
    except Exception as error:
        print(f"Error installing Super Mario 64 Coop Deluxe: {error}")
        return False
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def sm64coopdx_init():
    set_msg("Setting up Super Mario 64 Coop Deluxe")
    if system == "darwin":
        darwin_trust_app(sm64coopdx_folder / "sm64coopdx.app")
    if system == "linux":
        (sm64coopdx_folder / "sm64coopdx").chmod(0o755)
    return True


def sm64coopdx_install_init():
    return sm64coopdx_install() and sm64coopdx_init()


def sm64coopdx_uninstall():
    shutil.rmtree(sm64coopdx_folder, ignore_errors=True)
    return True


def sm64coopdx_is_available():
    return True


def sm64coopdx_is_installed():
    if system == "darwin":
        return (sm64coopdx_folder / "sm64coopdx.app").exists()
    if system == "linux":
        return (sm64coopdx_folder / "sm64coopdx").exists()
    if system.startswith("win"):
        return (sm64coopdx_folder / "sm64coopdx.exe").exists()


def sm64coopdx_launch():
    if system == "darwin":
        command = ["open", str(sm64coopdx_folder / "sm64coopdx.app")]
    if system == "linux":
        command = [str(sm64coopdx_folder / "sm64coopdx")]
    if system.startswith("win"):
        command = [str(sm64coopdx_folder / "sm64coopdx.exe")]
    subprocess.Popen(command, cwd=sm64coopdx_folder, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    return True
