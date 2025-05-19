from core.all import *

def check_usb() -> Path | None:
    """
    Busca el directorio /run/media/*/EMUDECK y devuelve el primero encontrado.
    Si no hay ninguno, devuelve None.
    """
    base = Path("/run/media")
    if base.is_dir():
        for user_dir in base.iterdir():
            candidate = user_dir / "EMUDECK"
            if candidate.is_dir():
                return candidate
    return None


def create_structure_usb(destination: Path) -> bool:
    """
    Crea la estructura básica en USB (bios/, bios/dc, roms/) y copia
    los roms de emudeck_backend/roms (ignorando *.txt).
    Devuelve True si todo ha ido bien.
    """
    dest = Path(destination)
    if (dest / "roms").is_dir():
        _show_info("USB Check", "USB already has a `roms/` folder, structure valid.")
        return True

    try:
        # Crear carpetas
        for sub in ["bios", "bios/dc", "roms"]:
            (dest / sub).mkdir(parents=True, exist_ok=True)

        # Escribir README
        readme = dest / "bios" / "readme.txt"
        lines = [
            "# Where to put your bios?",
            "First of all, don't create any new subdirectory. ***",
            "# System -> folder",
            "Playstation 1 / Duckstation -> bios/",
            "Playstation 2 / PCSX2 -> bios/",
            "Nintendo DS / melonDS -> bios/",
            "Playstation 3 / RPCS3 -> Download it from https://www.playstation.com/en-us/support/hardware/ps3/system-software/",
            "Dreamcast / RetroArch -> bios/dc",
            "Switch / Yuzu -> bios/yuzu/firmware and bios/yuzu/keys",
            "Those are the only mandatory bios, the rest are optional"
        ]
        readme.write_text("\n".join(lines), encoding="utf-8")

        # Copiar roms desde el backend (ignora *.txt y no sobreescribe)
        src = emudeck_backend / "roms"
        dst = dest / "roms"
        for f in src.rglob("*"):
            if f.is_file() and not f.suffix.lower() == ".txt":
                rel = f.relative_to(src)
                target = dst / rel
                if not target.exists():
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(f, target)

        _show_info("USB Setup", "Structure created successfully.")
        return True

    except Exception as e:
        _show_info("USB Setup Error", f"Failed to create structure:\n{e}")
        return False


def copy_games(origin: Path) -> bool:
    """
    Copia recursivamente los roms desde origin/roms → roms_path,
    y bios desde origin/bios → bios_path.
    Comprueba espacio libre y pide confirmación si falta.
    Devuelve True si todo ok.
    """
    origin = Path(origin)
    roms_src = origin / "roms"

    # Calcula espacio necesario y libre (en bytes)
    needed = sum(f.stat().st_size for f in roms_src.rglob("*") if f.is_file())
    free   = shutil.disk_usage(emulation_path).free

    if free < needed:
        ans = _ask_conflict(
            "Low Disk Space",
            f"You need at least {needed // (1024**2)} MB free in {emulation_path}, but only have {free // (1024**2)} MB.\nContinue?"
        )
        if not ans:
            return False

    # Copiar cada subcarpeta con archivos
    for entry in roms_src.iterdir():
        if not entry.is_dir():
            continue
        count = sum(1 for f in entry.rglob("*") if f.is_file() and not f.name.startswith("."))
        if count == 0:
            continue

        folder = entry.name
        # casos especiales
        if folder.lower() in ("wiiu","xenia"):
            entry = entry / "roms"

        dst_dir = roms_path / folder
        dst_dir.mkdir(parents=True, exist_ok=True)

        for f in entry.rglob("*"):
            if f.is_file() and not f.name.startswith("."):
                rel = f.relative_to(entry)
                tgt = dst_dir / rel
                tgt.parent.mkdir(parents=True, exist_ok=True)
                if not tgt.exists():
                    shutil.copy2(f, tgt)

        _show_info("Copy Games", f"Imported '{folder}' → {dst_dir}")

    # Copiar bios
    bios_src = origin / "bios"
    for f in bios_src.rglob("*"):
        if f.is_file():
            rel = f.relative_to(bios_src)
            tgt = bios_path / rel
            tgt.parent.mkdir(parents=True, exist_ok=True)
            if not tgt.exists():
                shutil.copy2(f, tgt)

    _show_info("Copy BIOS", f"BIOS imported → {bios_path}")
    return True


def auto_copy() -> None:
    """
    Lógica principal: detecta USB, crea estructura si falta y copia juegos.
    """
    usb = check_usb()
    if usb is None:
        _show_info(
            "USB Error",
            "USB Drive not found.\nMake sure the drive is named EMUDECK (all caps)."
        )
        return

    if not (usb / "bios").is_dir():
        _show_info("USB", "Creating folder structure on USB…")
        if create_structure_usb(usb):
            _show_info(
                "USB Ready",
                "USB folders created.\nNow copy your ROMs & BIOS on another computer, then re-plug USB."
            )
        else:
            return

    # si llegamos aquí, ya hay bios → copiamos juegos
    copy_games(usb)