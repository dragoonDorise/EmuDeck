from core.all import *

def remix_target(system):
    """Returns the folder a Remix pack for this platform is extracted into."""
    if system == "nes":
        return Path(bios_path) / "HdPacks"
    return Path(roms_path) / system

def remix_manifest(system, name):
    """Returns the file that lists what a Remix pack installed."""
    return Path(storage_path) / "remix" / system / f"{name}.json"

remix_articles = r"The|A|An|Le|La|Les|El|Los|Las|Il|Lo|Gli|Die|Der|Das"

def remix_match_name(name):
    """Cleans a game name ignoring regions and articles, so 'The X', 'X, The' and 'X' match."""
    name = re.sub(r"\(.*?\)|\[.*?\]", "", name).strip()
    name = re.sub(rf",\s*(?:{remix_articles})(?=\s+-\s+|\s*:|$)", "", name, flags=re.IGNORECASE)
    name = re.sub(rf"^(?:{remix_articles})\s+", "", name, flags=re.IGNORECASE)
    return rl_clean_name(name).replace(",", "")

def remix_search_rom(system, name):
    """Returns the Retro Library game whose name matches the Remix pack."""
    games_file = Path(storage_path) / "retrolibrary" / "cache" / "roms_games.json"
    try:
        systems = json.loads(games_file.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None
    wanted = remix_match_name(name)
    for item in systems:
        for game in item.get("games", []):
            rom_name = game.get("og_name") or game.get("name", "")
            if game.get("platform") == system and remix_match_name(rom_name) == wanted:
                return game
    return None

def remix_find_rom(system, name):
    """Looks for the ROM of a Remix pack, regenerating the Retro Library list when it is missing or stale."""
    rom = remix_search_rom(system, name)
    if not rom:
        rl_generate_game_list()
        rom = remix_search_rom(system, name)
    return rom

def remix_destination(system, rom):
    """Returns where a pack is extracted: a folder named like the ROM for HD packs, the platform folder otherwise."""
    if system == "nes":
        return remix_target(system) / (rom.get("og_name") or Path(rom["filename"]).stem)
    return remix_target(system)

def remix_install_pack(system, name, url):
    """Downloads a Remix pack and extracts it into the emulator folder of its platform."""
    rom = remix_find_rom(system, name)
    if not rom:
        print(f"No ROM found for {name} in {system}")
        return "missing-rom"
    destination = remix_destination(system, rom)
    temp_dir = Path(tempfile.mkdtemp())
    zip_path = temp_dir / "pack.zip"
    try:
        if not safeDownload(name, url, zip_path):
            return False
        with zipfile.ZipFile(zip_path) as zf:
            files = [
                member for member in zf.namelist()
                if not member.endswith("/") and not member.startswith("__MACOSX/") and not member.endswith(".DS_Store")
            ]
            prefix = ""
            roots = {member.split("/")[0] for member in files}
            if len(roots) == 1 and all("/" in member for member in files):
                prefix = f"{roots.pop()}/"
            installed = []
            for member in files:
                out = destination / member[len(prefix):]
                if not out.resolve().is_relative_to(destination.resolve()):
                    print(f"Unsafe path in {name}: {member}")
                    return False
                installed.append(out)
            for member, out in zip(files, installed):
                out.parent.mkdir(parents=True, exist_ok=True)
                with zf.open(member) as src, open(out, "wb") as dst:
                    shutil.copyfileobj(src, dst)
        manifest = remix_manifest(system, name)
        manifest.parent.mkdir(parents=True, exist_ok=True)
        manifest.write_text(json.dumps([str(out) for out in installed]))
        return True
    except Exception as e:
        print(f"Error installing {name}: {e}")
        return False
    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)

def remix_uninstall_pack(system, name):
    """Deletes the files a Remix pack installed and the folders it leaves empty."""
    manifest = remix_manifest(system, name)
    if not manifest.exists():
        return False
    target = remix_target(system)
    files = [Path(file) for file in json.loads(manifest.read_text())]
    for file in files:
        file.unlink(missing_ok=True)
    folders = {folder for file in files for folder in file.parents if target in folder.parents}
    for folder in sorted(folders, key=lambda folder: len(folder.parts), reverse=True):
        if folder.is_dir() and not any(folder.iterdir()):
            folder.rmdir()
    manifest.unlink()
    return True
