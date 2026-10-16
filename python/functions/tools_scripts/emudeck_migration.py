from core.all import *

def human_readable(nbytes: int) -> str:
    for unit in ['B','KB','MB','GB','TB']:
        if nbytes < 1024:
            return f"{nbytes:.1f}{unit}"
        nbytes /= 1024
    return f"{nbytes:.1f}PB"

def replace_in_file(path: Path, old: str, new: str) -> None:
    txt = path.read_text(encoding="utf-8")
    if old in txt:
        path.write_text(txt.replace(old, new), encoding="utf-8")

# ─── MIGRATION FUNCTIONS ────────────────────────────────────────────────────

def migration_init(destination: Path) -> bool:
    origin = emulation_path
    dest   = Path(destination)

    needed = sum(f.stat().st_size for f in origin.rglob("*") if f.is_file())
    if shutil.disk_usage(dest).free < needed:
        popup_show_info("EmuDeck Migration tool", f"Make sure you have enough space in {dest}. You need at least {human_readable(needed)} available")
        return False

    if migration_move(origin, dest, human_readable(needed)):
        migration_update_paths(origin, dest / "Emulation")
        return True
    return False


def migration_move(origin: Path, destination: Path, size_human: str) -> bool:
    result = {}
    popup_show_progress("EmuDeck Migration tool", f"Migrating your current {size_human} Emulation folder to {destination}", lambda: result.update(code=subprocess.run(["rsync", "-a", str(origin), str(destination)]).returncode))
    if result.get("code") != 0:
        popup_show_info("Migration Error", f"There was an error copying your Emulation folder to {destination}")
        return False
    return True


def migration_update_paths(origin: Path, destination: Path) -> None:
    o = str(origin)
    d = str(destination)

    set_setting("storagePath", str(destination.parent))
    if hybrid_mode:
        from core.settings_sh import write_setting_sh
        for var, value in {
            "emulationPath": d,
            "toolsPath": f"{d}/tools",
            "romsPath": f"{d}/roms",
            "biosPath": f"{d}/bios",
            "savesPath": f"{d}/saves",
            "storagePath": f"{d}/storage",
            "ESDEscrapData": f"{d}/tools/downloaded_media",
        }.items():
            write_setting_sh(settings_sh_path, json_to_bash_vars_path, f"sh.{var}", value)

    if system == "darwin":
        for launcher in Path("/Applications/EmuDeck").glob("*.app/Contents/MacOS/*"):
            replace_in_file(launcher, o, d)

    migration_update_srm(o, d)
    migration_update_parsers(o, d)


def migration_update_emus() -> None:
    ns = sys.modules["core.all"].__dict__
    def update():
        for name, fn in list(ns.items()):
            if not name.endswith("_is_installed") or not callable(fn):
                continue
            prefix = name[: -len("_is_installed")]
            try:
                if not fn():
                    continue
                for suffix in ("_set_emulation_folder", "_setup_saves"):
                    if callable(ns.get(prefix + suffix)):
                        ns[prefix + suffix]()
            except Exception as e:
                print(f"Migration: {prefix} failed: {e}")
    popup_show_progress("EmuDeck Migration tool", "Updating your emulators to the new location...", update)
    popup_show_info("Success", f"Your library has been moved to {emulation_path}. Please restart EmuDeck to apply the changes")


def migration_update_srm(origin: str, destination: str) -> None:
    for path in (Path(steam_install_path) / "userdata").rglob("shortcuts.vdf"):
        path.write_bytes(path.read_bytes().replace(origin.encode(), destination.encode()))

    srm_json = Path(srm_path) / "userData" / "userSettings.json"
    if srm_json.exists():
        data = json.loads(srm_json.read_text(encoding="utf-8"))
        data.setdefault("environmentVariables", {})["romsDirectory"] = f"{destination}/roms"
        srm_json.write_text(json.dumps(data, indent=2), encoding="utf-8")


def migration_update_parsers(origin: str, destination: str) -> None:
    parsers_json = Path(srm_path) / "userData" / "userConfigurations.json"
    if parsers_json.exists():
        txt = parsers_json.read_text(encoding="utf-8")
        parsers_json.write_text(txt.replace(origin, destination), encoding="utf-8")


def migration_update_settings(origin: str, destination: str) -> None:
    migration_update_parsers(origin, destination)


def migration_ESDE() -> None:
    ESDE_set_emulation_folder()


def migration_fix_SDPaths() -> bool:
    new_path = get_sd_path()
    if not new_path:
        popup_show_info(
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