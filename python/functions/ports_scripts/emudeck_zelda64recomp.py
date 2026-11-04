from core.all import *

zelda64recomp_folder = ports_folder / "zelda64recomp"


def zelda64recomp_install():
    set_msg("Installing Zelda 64: Recompiled")
    if system == "darwin":
        look_for = "macOS"
    if system == "linux":
        look_for = "Linux-X64"
    if system.startswith("win"):
        look_for = "Windows"

    temp = Path(tempfile.mkdtemp())
    try:
        url = get_latest_release_gh("Zelda64Recomp/Zelda64Recomp", "zip", look_for)
        archive = temp / "zelda64recomp.zip"
        if not url or not safeDownload("Zelda 64: Recompiled", url, archive):
            return False

        shutil.rmtree(zelda64recomp_folder, ignore_errors=True)
        zelda64recomp_folder.mkdir(parents=True, exist_ok=True)

        if system == "darwin":
            subprocess.run(["ditto", "-x", "-k", str(archive), str(temp)], check=True)
            subprocess.run(["ditto", "-x", "-k", str(temp / "Zelda64Recompiled.zip"), str(zelda64recomp_folder)], check=True)
        if system == "linux":
            extract(archive, temp)
            extract_tar_gz(temp / "Zelda64Recompiled.tar.gz", zelda64recomp_folder)
        if system.startswith("win"):
            extract(archive, zelda64recomp_folder)

        return zelda64recomp_is_installed()
    except Exception as error:
        print(f"Error installing Zelda 64: Recompiled: {error}")
        return False
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def zelda64recomp_init():
    set_msg("Setting up Zelda 64: Recompiled")
    if system == "darwin":
        darwin_trust_app(zelda64recomp_folder / "Zelda64Recompiled.app")
    if system == "linux":
        (zelda64recomp_folder / "Zelda64Recompiled").chmod(0o755)
    return True


def zelda64recomp_install_init():
    return zelda64recomp_install() and zelda64recomp_init()


def zelda64recomp_uninstall():
    shutil.rmtree(zelda64recomp_folder, ignore_errors=True)
    return True


def zelda64recomp_is_available():
    return True


def zelda64recomp_is_installed():
    if system == "darwin":
        return (zelda64recomp_folder / "Zelda64Recompiled.app").exists()
    if system == "linux":
        return (zelda64recomp_folder / "Zelda64Recompiled").exists()
    if system.startswith("win"):
        return (zelda64recomp_folder / "Zelda64Recompiled.exe").exists()


def zelda64recomp_launch():
    if system == "darwin":
        command = ["open", str(zelda64recomp_folder / "Zelda64Recompiled.app")]
    if system == "linux":
        command = [str(zelda64recomp_folder / "Zelda64Recompiled")]
    if system.startswith("win"):
        command = [str(zelda64recomp_folder / "Zelda64Recompiled.exe")]
    subprocess.Popen(command, cwd=zelda64recomp_folder, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
    return True
