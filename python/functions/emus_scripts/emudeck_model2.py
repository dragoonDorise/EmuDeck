from core.all import *
from pathlib import Path


def model2_install():
    set_msg(f"Installing model2")
    if system == "linux":
        roms_model2 = roms_path / "model2"
        (roms_model2 / "roms").mkdir(parents=True, exist_ok=True)

        archive = roms_model2 / "Model2.7z"

        if safeDownload(
            "Model2",
            "https://github.com/SeongGino/edc-repo0004/raw/master/m2emulator/1.1c.7z",
            str(archive),
            True,
        ):
            subprocess.run(["7za", "e", "-y", str(archive), f"-o{roms_model2}"], check=True)
            archive.unlink(missing_ok=True)
        else:
            return False

        src_launcher = (
            Path(emudeck_backend) / "tools" / "launchers" / "unix" / "model-2-emulator.sh"
        )

        destinations = [
            tools_path / "launchers" / "model-2-emulator.sh",
            roms_model2 / "model-2-emulator.sh",
        ]

        for dest in destinations:
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src_launcher, dest)
            dest.chmod(dest.stat().st_mode | 0o111)

        icon_path = Path(emudeck_backend) / "icons" / "ico" / "model2.ico"
        launcher_path = tools_path / "launchers" / "model-2-emulator.sh"

        desktop_entry = "\n".join(
            [
                "[Desktop Entry]",
                "Type=Application",
                "Name=Model-2-Emulator (Proton)",
                f"Icon={icon_path}",
                f"Exec={launcher_path}",
                "Terminal=false",
                "Categories=Game;",
            ]
        ) + "\n"

        applications_dir = Path.home() / ".local" / "share" / "applications"
        desktop_file = applications_dir / "Model 2 Emulator (Proton).desktop"
        desktop_file.parent.mkdir(parents=True, exist_ok=True)
        desktop_file.write_text(desktop_entry, encoding="utf-8")
        desktop_file.chmod(0o755)

        return True

    if system.startswith("win"):
        type = "7z"
        path = f"{emus_folder}/m2emulator"
        url = "https://github.com/PhoenixInteractiveNL/edc-repo0004/raw/master/m2emulator/1.1a.7z"
    if system == "darwin":
        type = "dmg"
        look_for = "macos"
        path = emus_folder

    try:
        install_emu("model2", url, type, path)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def model2_is_installed():
    if system.startswith("win"):
        return (Path(emus_folder) / "m2emulator" / "EMULATOR.EXE").exists()
    if system == "linux":
        return (roms_path / "model2" / "emulator_multicpu.exe").exists()
    if system == "darwin":
        return False  # NYI


def model2_init():
    set_msg("Setting up model2")

    if system == "linux":
        destination = roms_path / "model2"
        destination.mkdir(parents=True, exist_ok=True)

        copy_and_set_settings_file("common/model2/EMULATOR.INI", destination)

        copy_setting_dir("common/model2/CFG", destination / "CFG")
        copy_setting_dir("common/model2/NVDATA", destination / "NVDATA")
        copy_setting_dir("common/model2/scripts", destination / "scripts")

        return True

    if system == "darwin":
        return True  # NYI

    if system.startswith("win"):
        destination = f"{emus_folder}/m2emulator"
        Path(f"{destination}/pfx").mkdir(parents=True, exist_ok=True)
        copy_and_set_settings_file("common/model2/EMULATOR.INI", destination)

        ini_path = Path(destination) / "EMULATOR.INI"
        model2_set_emulation_folder(ini_path)

        copy_setting_dir("common/model2/CFG", f"{destination}/CFG")
        copy_setting_dir("common/model2/NVDATA", f"{destination}/NVDATA")
        copy_setting_dir("common/model2/scripts", f"{destination}/scripts")


def model2_install_init():
    model2_install()
    model2_init()


def model2_update():
    model2_install()
    model2_init()


def model2_set_emulation_folder(ini_path: Path) -> None:
    win_roms_dir = (emulation_path / "roms" / "model2")
    win_roms_dir_str = str(win_roms_dir).replace("/", "\\")

    text = ini_path.read_text(encoding="utf-8", errors="ignore")
    text = text.replace("Dir1=roms", f"Dir1={win_roms_dir_str}")
    text = text.replace(':\\"', ':\\\\')

    ini_path.write_text(text, encoding="utf-8")


def model2_uninstall():
    if system.startswith("win"):
        uninstall_emu("m2emulator", "dir")
        return True

    if system == "linux":
        model2_dir = roms_path / "model2"
        if model2_dir.exists():
            shutil.rmtree(model2_dir, ignore_errors=True)

        launcher = tools_path / "launchers" / "model-2-emulator.sh"
        launcher.unlink(missing_ok=True)

        launcher_copy = roms_path / "model2" / "model-2-emulator.sh"
        launcher_copy.unlink(missing_ok=True)

        desktop = Path.home() / ".local" / "share" / "applications" / "Model 2 Emulator (Proton).desktop"
        desktop.unlink(missing_ok=True)

        return True

    if system == "darwin":
        return True  # NYI