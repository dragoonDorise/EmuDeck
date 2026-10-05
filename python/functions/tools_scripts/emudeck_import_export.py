from core.all import *


def import_export_script() -> Path:
    base = Path(bash_backend) if hybrid_mode else Path(emudeck_backend)
    return base / "tools" / "importExport.py"


def import_export_prepare(create_media: bool) -> None:
    if create_media:
        Path(ESDEscrapData).mkdir(parents=True, exist_ok=True)
    esde_link_downloaded_media()
    esde_symlink_gamelists()


def import_export_run(action: str, items: str, location: str) -> bool:
    env = {**os.environ, "emulationPath": str(emulation_path)}
    return subprocess.run([sys.executable, str(import_export_script()), action, items, location], env=env).returncode == 0


def import_emudeck(items: str, origin: str) -> bool:
    import_export_prepare(True)
    return import_export_run("import_emudeck", items, origin)


def export_emudeck(items: str, destination: str) -> bool:
    import_export_prepare(False)
    return import_export_run("export_emudeck", items, destination)
