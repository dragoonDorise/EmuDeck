from core.all import *

spaghettikart_folder = ports_folder / "spaghettikart"


def spaghettikart_install():
    set_msg("Installing SpaghettiKart")
    if system == "darwin":
        look_for = "mac-arm64"
    if system == "linux":
        look_for = "linux"
    if system.startswith("win"):
        look_for = "windows"

    temp = Path(tempfile.mkdtemp())
    try:
        url = get_latest_release_gh("HarbourMasters/SpaghettiKart", "zip", look_for)
        archive = temp / "spaghettikart.zip"
        if not url or not safeDownload("SpaghettiKart", url, archive):
            return False

        shutil.rmtree(spaghettikart_folder, ignore_errors=True)
        spaghettikart_folder.mkdir(parents=True, exist_ok=True)

        if system == "darwin":
            subprocess.run(["ditto", "-x", "-k", str(archive), str(spaghettikart_folder)], check=True)
        else:
            extract(archive, spaghettikart_folder)

        return spaghettikart_is_installed()
    except Exception as error:
        print(f"Error installing SpaghettiKart: {error}")
        return False
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def spaghettikart_init():
    set_msg("Setting up SpaghettiKart")
    if system == "darwin":
        darwin_trust_app(spaghettikart_folder)
        (spaghettikart_folder / "Spaghettify").chmod(0o755)
    if system == "linux":
        (spaghettikart_folder / "spaghetti.appimage").chmod(0o755)
    return True


def spaghettikart_install_init():
    return spaghettikart_install() and spaghettikart_init()


def spaghettikart_uninstall():
    shutil.rmtree(spaghettikart_folder, ignore_errors=True)
    return True


def spaghettikart_is_available():
    return True


def spaghettikart_is_installed():
    if system == "darwin":
        return (spaghettikart_folder / "Spaghettify").exists()
    if system == "linux":
        return (spaghettikart_folder / "spaghetti.appimage").exists()
    if system.startswith("win"):
        return (spaghettikart_folder / "Spaghettify.exe").exists()


def spaghettikart_launch():
    if system == "darwin":
        command = [str(spaghettikart_folder / "Spaghettify")]
    if system == "linux":
        command = [str(spaghettikart_folder / "spaghetti.appimage")]
    if system.startswith("win"):
        command = [str(spaghettikart_folder / "Spaghettify.exe")]
    subprocess.Popen(command, cwd=spaghettikart_folder, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    return True
