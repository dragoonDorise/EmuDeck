from core.all import *

def human_readable(nbytes: int) -> str:
    for unit in ['B','KB','MB','GB','TB']:
        if nbytes < 1024:
            return f"{nbytes:.1f}{unit}"
        nbytes /= 1024
    return f"{nbytes:.1f}PB"

def replace_in_file(path: Path, old: str, new: str) -> None:
    txt = path.read_text(encoding="utf-8")
    txt2 = txt.replace(old, new)
    path.write_text(txt2, encoding="utf-8")

# ─── MIGRATION FUNCTIONS ────────────────────────────────────────────────────

def migration_init(destination: Path) -> bool:
    """
    1) Comprueba espacio libre vs usado en emulation_path.
    2) Pregunta con diálogo nativo si falta espacio.
    3) Si OK, mueve y actualiza rutas.
    """
    origin = emulation_path
    dest   = Path(destination)

    # Calculate sizes
    needed = sum(f.stat().st_size for f in origin.rglob("*") if f.is_file())
    free   = shutil.disk_usage(dest).free
    needed_h = human_readable(needed)
    free_h   = human_readable(free)

    if free < needed:
        ans = _ask_conflict(
            "EmuDeck Migration tool",
            f"Make sure you have enough space in {dest}.\n"
            f"You need at least {needed_h} (you have {free_h}). Continue?"
        )
        if not ans:
            return False

    # Move and update
    if migration_move(origin, dest, needed_h):
        migration_update_paths(origin, dest / "Emulation")
        return True
    return False


def migration_move(origin: Path, destination: Path, size_human: str) -> bool:
    """
    Lanza rsync para copiar origin → destination.
    """
    _show_info(
        "Migrating",
        f"Migrating your current {size_human} Emulation folder to {destination}"
    )
    try:
        subprocess.run(
            ["rsync", "-av", "--progress", f"{origin}/", str(destination)],
            check=True
        )
        return True
    except subprocess.CalledProcessError as e:
        _show_info("Migration Error", f"rsync failed:\n{e}")
        return False


def migration_update_paths(origin: Path, destination: Path) -> None:
    """
    Sustituye en múltiples ficheros de configuración la ruta `origin` por `destination`.
    """
    o = str(origin)
    d = str(destination)

    # Settings generales
    set_setting("emulationPath",   d)
    set_setting("toolsPath",       f"{d}/tools")
    set_setting("romsPath",        f"{d}/roms")
    set_setting("biosPath",        f"{d}/bios")
    set_setting("savesPath",       f"{d}/saves")
    set_setting("storagePath",     f"{d}/storage")
    set_setting("ESDEscrapData",   f"{d}/tools/downloaded_media")

    # Configs de emus
    for cfg in [
        Azahar_configFile, Citra_configFile, DuckStation_configFile,
        MAME_configFile, melonDS_configFile, mGBA_configFile,
        PCSX2QT_configFile, RetroArch_configFile, RMG_configFile,
        Vita3K_configFile, ScummVM_configFile
    ]:
        if cfg.exists():
            replace_in_file(cfg, o, d)

    # Ruta flatpak de Dolphin
    dolphin_ini = Path.home() / ".var" / "app" / "org.DolphinEmu.dolphin-emu" / \
                 "config" / "dolphin-emu" / "Dolphin.ini"
    if dolphin_ini.exists():
        replace_in_file(dolphin_ini, o, d)

    # RPCS3 vfs.yml
    rpcs3_vfs = Path.home() / ".var" / "app" / RPCS3_emuPath / \
                "config" / "rpcs3" / "vfs.yml"
    if rpcs3_vfs.exists():
        replace_in_file(rpcs3_vfs, o, d)

    # yuzu qt-config.ini
    yuzu_cfg = Path.home() / ".config" / "yuzu" / "qt-config.ini"
    if yuzu_cfg.exists():
        replace_in_file(yuzu_cfg, o, d)

    # Steam Rom Manager
    migration_update_srm(o, d)

    # Reinicializar saves según plugins instalados (mock)
    # for each emulator installed: llamar a *_setupSaves()

    # Symlinks de Dolphin/Citra (mock)
    # Dolphin_flushSymlinks()
    # Citra_flushSymlinks()

    _show_info(
        "Migration Success",
        f"Your library has been moved to {d}\nPlease restart to apply changes."
    )


def migration_update_srm(origin: str, destination: str) -> None:
    """
    Reemplaza origin→destination en shortcuts.vdf de Steam y actualiza
    userSettings.json de Steam Rom Manager.
    """
    # 1) shortcuts.vdf
    for path in steam_userdata_path.rglob("shortcuts.vdf"):
        txt = path.read_text(encoding="utf-8")
        path.write_text(txt.replace(origin, destination), encoding="utf-8")

    # 2) Steam Rom Manager settings
    srm_json = Path.home() / ".config" / "steam-rom-manager" / "userData" / \
               "userSettings.json"
    if srm_json.exists():
        data = json.loads(srm_json.read_text(encoding="utf-8"))
        data.setdefault("environmentVariables", {})["romsDirectory"] = str(roms_path)
        srm_json.write_text(json.dumps(data, indent=2), encoding="utf-8")


def migration_update_parsers(origin: str, destination: str) -> None:
    """
    Reemplaza origin→destination en userConfigurations.json de Steam Rom Manager.
    """
    parsers_json = Path.home() / ".config" / "steam-rom-manager" / "userData" / \
                   "userConfigurations.json"
    if parsers_json.exists():
        txt = parsers_json.read_text(encoding="utf-8")
        parsers_json.write_text(txt.replace(origin, destination), encoding="utf-8")


def migration_update_settings(origin: str, destination: str) -> None:
    """
    Igual que parsers: actualiza userConfigurations.json.
    """
    migration_update_parsers(origin, destination)


def migration_ESDE() -> None:
    """Invoca la migración interna de ES-DE."""
    ESDE_set_emulation_folder()


def migration_fix_SDPaths() -> bool:
    """
    Si detecta un nuevo SD con get_sd_path(), propone actualizar rutas.
    """
    new_path = get_sd_path()
    if not new_path:
        _show_info(
            "SD Card Error",
            "Please check that your SD Card is properly inserted and recognized by the system."
        )
        return False

    origin = str(emulation_path)
    destination = str(new_path / "Emulation")

    ans = _ask_conflict(
        "Confirm SD Path Fix",
        f"Your old path was:\n{origin}\n\nYour new path is:\n{destination}\n\n"
        "Do you want to apply these changes?"
    )
    if not ans:
        return False

    # Aplicar actualizaciones
    migration_update_srm(origin, destination)
    migration_update_paths(Path(origin), Path(destination))
    migration_update_parsers(origin, str(new_path) + "/")
    migration_ESDE()
    return True