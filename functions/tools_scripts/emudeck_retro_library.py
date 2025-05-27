from core.all import *

rl_excluded_systems = ["/model2", "/genesiswide", "/mame", "/emulators", "/desktop", "/sneswide"]
json_path = os.path.join(storage_path, "retrolibrary/cache/missing_artwork_no_hash.json")

warnings.filterwarnings("ignore", category=RequestsDependencyWarning)

#RA INIT
USER = ""
md5_to_find = ""
LOCAL_PATH = ""
GAMES_LIST_ENDPOINT = f"{LOCAL_PATH}"

def count_visible_files(system_dir: str) -> int:
    file_count = 0
    # topdown=True para poder modificar dirs antes de descender
    for root, dirs, files in os.walk(system_dir, topdown=True):
        # 1) Filtrar dirs: quitamos los que empiezan por '.' o son symlinks
        dirs[:] = [
            d for d in dirs
            if not d.startswith('.')
            and not os.path.islink(os.path.join(root, d))
        ]
        # 2) Contar sólo los archivos visibles no symlink
        for fname in files:
            if fname.startswith('.'):
                continue
            full = os.path.join(root, fname)
            if os.path.islink(full):
                continue
            file_count += 1
    return file_count

def log_message(value):
    print(value)

def rl_clean_name(name):
    name_cleaned = re.sub(r'\(.*?\)', '', name)
    name_cleaned = re.sub(r'\[.*?\]', '', name_cleaned)
    name_cleaned = name_cleaned.strip().replace(' ', '_').replace('-', '_')
    name_cleaned = re.sub(r'_+', '_', name_cleaned)
    name_cleaned = name_cleaned.replace('+', '').replace('&', '').replace('!', '').replace("'", '').replace('.', '').replace('_decrypted', '').replace('decrypted', '').replace('.ps3', '')
    name_cleaned = name_cleaned.lower()
    return name_cleaned

def rl_collect_game_data(system_dir, extensions, images_path=None):
    #images_path = os.path.join(storage_path ,"/retrolibrary/artwork")
    game_data = []

    #PS3
    for root, files, dirs in os.walk(system_dir):

        #print(game_data)
        for file in files:
            file_path = os.path.join(root, file)
            if os.path.islink(file_path):
                continue

            filename = os.path.basename(file)
            extension = filename.split('.')[-1]
            name = '.'.join(filename.split('.')[:-1])
            if extension in extensions:

                if any(f"Disc {i}" in name for i in range(2, 9)):
                    log_message(f"Ignoring file with disc name: {file}")
                    continue

                if extension.lower() == "bin":
                    log_message(f"Ignoring .bin file: {file}")
                    continue

                platform = os.path.basename(system_dir)

                # Clean the game name
                name_cleaned = rl_clean_name(name)

                if images_path:
                    # Check for missing images
                    missing_images = False
                    for img_type, ext in [("box2dfront", ".jpg"), ("wheel", ".png"), ("screenshot", ".jpg")]:
                        img_path = os.path.join(images_path, f"{platform}/media/{img_type}/{name_cleaned}{ext}")

                        if not os.path.exists(img_path):
                            #print(f"Missing image: {img_path}")
                            log_message(f"Missing image: {img_path}")
                            missing_images = True

                    if missing_images:
                        game_info = {
                            "name": name_cleaned,
                            "platform": platform,
                            "type": img_type,
                            "filename": file_path
                        }
                        game_data.append(game_info)
                else:
                    game_info = {
                        "name": name_cleaned,
                        "og_name": name,
                        "filename": file_path,
                        "file": name_cleaned,
                        "img": f"/customimages/retrolibrary/artwork/{platform}/media",
                        "platform": platform
                    }
                    game_data.append(game_info)

    for root, _, files in os.walk(system_dir):

        #print(game_data)
        for file in files:
            file_path = os.path.join(root, file)
            if os.path.islink(file_path):
                continue

            filename = os.path.basename(file)
            extension = filename.split('.')[-1]
            name = '.'.join(filename.split('.')[:-1])
            if extension in extensions:

                if any(f"Disc {i}" in name for i in range(2, 9)):
                    log_message(f"Ignoring file with disc name: {file}")
                    continue

                if extension.lower() == "bin":
                    log_message(f"Ignoring .bin file: {file}")
                    continue

                platform = os.path.basename(system_dir)

                # Special cases for WiiU and PS3
                if os.name != 'nt':
                    if "wiiu" in system_dir:
                        parts = root.split(os.sep)
                        name = name
                        if ".rpx" in file_path:
                            name = parts[-2] if len(parts) >= 2 else name
                        platform = "wiiu"
                    if "ps3" in system_dir:
                        parts = root.split(os.sep)
                        name = parts[-3] if len(parts) >= 3 else name
                        platform = "ps3"
                    if "xbox360" in system_dir:
                        platform = "xbox360"
                    if "ps4" in system_dir:
                        platform = "ps4"

                # Clean the game name
                name_cleaned = rl_clean_name(name)

                if images_path:
                    # Check for missing images
                    missing_images = False
                    for img_type, ext in [("box2dfront", ".jpg"), ("wheel", ".png"), ("screenshot", ".jpg")]:
                        img_path = os.path.join(images_path, f"{platform}/media/{img_type}/{name_cleaned}{ext}")

                        if not os.path.exists(img_path):
                            #print(f"Missing image: {img_path}")
                            log_message(f"Missing image: {img_path}")
                            game_info = {
                                "name": name_cleaned,
                                "platform": platform,
                                "type": img_type,
                                "filename": file_path
                            }
                            game_data.append(game_info)
                else:
                    game_info = {
                        "name": name_cleaned,
                        "og_name": name,
                        "filename": file_path,
                        "file": name_cleaned,
                        "img": f"/customimages/retrolibrary/artwork/{platform}/media",
                        "platform": platform
                    }
                    game_data.append(game_info)

    return sorted(game_data, key=lambda x: x['name'])

def rl_get_valid_system_dirs(valid_system_dirs):
    roms_dir = roms_path
    for system_dir in os.listdir(roms_dir):
        if os.name != 'nt':
            if system_dir == "xbox360":
                system_dir = "xbox360/roms"
            if system_dir == "model2":
                system_dir = "model2/roms"
        if system_dir == "ps4":
            system_dir = "ps4/shortcuts"
        full_path = os.path.join(roms_path, system_dir)

        if os.path.isdir(full_path) and not os.path.islink(full_path):

            if system_dir == "ps3":

                valid_system_dirs.append(full_path)
                log_message(f"GGL: Valid system directory found (PS3): {full_path}")
            else:
                # Lógica original para los demás sistemas
                has_metadata = os.path.isfile(os.path.join(full_path, 'metadata.txt'))
                file_count = count_visible_files(full_path)
                if has_metadata and file_count > 2:
                    valid_system_dirs.append(full_path)
                    log_message(f"GGL: Valid system directory found: {full_path}")
    return valid_system_dirs

def rl_parse_metadata_file(metadata_path):
    if not os.path.exists(metadata_path):
        raise FileNotFoundError(f"Metadata file not found: {metadata_path}")

    with open(metadata_path, 'r') as f:
        metadata = f.read()

    collection = next((line.split(':')[1].strip() for line in metadata.splitlines() if line.startswith('collection:')), '')
    shortname = next((line.split(':')[1].strip() for line in metadata.splitlines() if line.startswith('shortname:')), '')
    launcher = next((line.split(':', 1)[1].strip() for line in metadata.splitlines() if line.startswith('launch:')), '').replace('"', '\\"')
    extensions = next((line.split(':')[1].strip().replace(',', ' ') for line in metadata.splitlines() if line.startswith('extensions:')), '').split()

    return {
        "collection": collection,
        "shortname": shortname,
        "launcher": launcher,
        "extensions": extensions
    }

def rl_generate_saves_list():

    saves_list = []
    states_dir = os.path.join(saves_path, "retroarch", "states")

    if not os.path.exists(states_dir):
        log_message(f"Saves path does not exist: {states_dir}")
        return

    for root, _, files in os.walk(states_dir):
        for file in files:
            file_path = os.path.join(root, file)
            if os.path.isfile(file_path):
                # Clean and prepare data for the JSON
                cleaned_name = rl_clean_name(os.path.splitext(file)[0])
                save_info = {
                    "name": cleaned_name,
                    "path": file_path
                }
                saves_list.append(save_info)
                log_message(f"Found save state: {cleaned_name} at {file_path}")

    # Sort and write the JSON
    saves_list_sorted = sorted(saves_list, key=lambda x: x['name'])
    json_output = json.dumps(saves_list_sorted, indent=4)

    output_file = os.path.join(storage_path, "retrolibrary/cache/saves_states.json")
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(json_output)
        log_message(f"Saved states JSON written to {output_file}")

def rl_generate_game_list():
    roms_dir = roms_path
    valid_system_dirs = []
    valid_system_dirs = rl_get_valid_system_dirs(valid_system_dirs)
    game_list = []

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in rl_excluded_systems):
            log_message(f"GGL: Skipping directory: {system_dir}")
            continue

        metadata = rl_parse_metadata_file(os.path.join(system_dir, 'metadata.txt'))
        collection = metadata["collection"]
        shortname = metadata["shortname"]
        launcher = metadata["launcher"]
        extensions = metadata["extensions"]

        games = rl_collect_game_data(system_dir, extensions)
        if games:
            system_info = {
                "title": collection,
                "id": shortname,
                "launcher": launcher,
                "games": games
            }
            game_list.append(system_info)
            log_message(f"GGL: Detected {len(games)} games from {system_dir}")

    json_output = json.dumps(sorted(game_list, key=lambda x: x['title']), indent=4)

    output_file = os.path.join(storage_path, "retrolibrary/cache/roms_games.json")

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(json_output)
        #print(json_output)

def rl_download_achievements():
    achievements_dir = storage_path / "retrolibrary" / "achievements"

    if not achievements_dir.is_dir():
        # 2) Escribir mensaje de inicio

        # 3) Crear carpeta
        achievements_dir.mkdir(parents=True, exist_ok=True)

        # 4) Crear (o forzar) symlink:
        target = achievements_dir

        userdata_dir = home / ".steam" / "steam" / "userdata"

        if not userdata_dir.exists():
            raise FileNotFoundError(f"{userdata_dir!s} no existe")

        account_folders = sorted(
            [p for p in userdata_dir.iterdir() if p.is_dir()],
            key=lambda p: p.stat().st_mtime,
            reverse=True
        )
        if not account_folders:
            raise RuntimeError("No se encontró ninguna carpeta de userdata de Steam")

        account_folder = account_folders[0]

        link = account_folder / "config" / "grid" / "retrolibrary" / "achievements"
        link.parent.mkdir(parents=True, exist_ok=True)
        if link.exists() or link.is_symlink():
            link.unlink()
        link.symlink_to(target, target_is_directory=True)

        zip_path = achievements_dir / "achievements.zip"
        url = "https://artwork.emudeck.com/achievements/achievements.zip"
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
        zip_path.write_bytes(resp.content)

        with zipfile.ZipFile(zip_path, 'r') as zf:
            zf.extractall(achievements_dir)
        zip_path.unlink()

def rl_download_data() -> None:
    # 1) Definir carpeta de destino
    data_dir = storage_path / "retrolibrary" / "data"

    # 2) Obtener carpeta de usuario Steam más reciente
    userdata_root = Path.home() / ".steam" / "steam" / "userdata"
    steam_accounts = [p for p in userdata_root.iterdir() if p.is_dir()]
    if not steam_accounts:
        return  # No hay userdata, salimos
    # Ordenar por última modificación y tomar la más reciente
    account_folder = sorted(
        steam_accounts,
        key=lambda p: p.stat().st_mtime,
        reverse=True
    )[0]

    if not data_dir.is_dir():

        # 4) Crear carpeta y symlink
        data_dir.mkdir(parents=True, exist_ok=True)
        link_target = data_dir
        link_path = account_folder / "config" / "grid" / "retrolibrary" / "data"
        link_path.parent.mkdir(parents=True, exist_ok=True)
        if link_path.exists() or link_path.is_symlink():
            link_path.unlink()
        link_path.symlink_to(link_target, target_is_directory=True)

        # 5) Descargar ZIP
        zip_path = data_dir / "data.zip"
        url = "https://artwork.emudeck.com/data/data.zip"
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
        zip_path.write_bytes(resp.content)

        # 6) Descomprimir y eliminar ZIP
        with zipfile.ZipFile(zip_path, 'r') as zf:
            zf.extractall(data_dir)
        zip_path.unlink()

def rl_download_assets() -> None:
    # 1) Encontrar carpeta Steam userdata más reciente
    userdata_root = Path.home() / ".steam" / "steam" / "userdata"
    steam_accounts = [p for p in userdata_root.iterdir() if p.is_dir()]
    if not steam_accounts:
        return
    account_folder = sorted(
        steam_accounts, key=lambda p: p.stat().st_mtime, reverse=True
    )[0]

    # 2) Rutas de carpetas
    assets_dir     = storage_path / "retrolibrary" / "assets"
    dest_dir       = account_folder / "config" / "grid" / "retrolibrary" / "assets"
    default_dir    = assets_dir / "default"
    bezels_dir     = assets_dir / "bezels"
    wii_dir        = assets_dir / "wii"

    # 3) Crear carpeta assets y symlink
    assets_dir.mkdir(parents=True, exist_ok=True)
    dest_dir.parent.mkdir(parents=True, exist_ok=True)
    if dest_dir.exists() or dest_dir.is_symlink():
        dest_dir.unlink()
    dest_dir.symlink_to(assets_dir, target_is_directory=True)

    # 4) Función auxiliar de descarga y extracción
    def _download_and_extract(name: str, url: str, target_subdir: Path):
        if not target_subdir.is_dir():
            zip_path = assets_dir / f"{name}.zip"
            resp = requests.get(url, timeout=30)
            resp.raise_for_status()
            zip_path.write_bytes(resp.content)
            with zipfile.ZipFile(zip_path, 'r') as zf:
                zf.extractall(assets_dir)
            zip_path.unlink()

    # 5) Descargar los tres zips si no existen
    _download_and_extract(
        "default",
        "https://artwork.emudeck.com/assets/default.zip",
        default_dir
    )
    _download_and_extract(
        "bezels",
        "https://artwork.emudeck.com/assets/bezels.zip",
        bezels_dir
    )
    _download_and_extract(
        "wii",
        "https://artwork.emudeck.com/assets/wii.zip",
        wii_dir
    )

    # 6) Descargar imágenes puntuales (siempre)
    # extras = [
    #     ("default/backgrounds/store.jpg",
    #      "https://artwork.emudeck.com/assets/default/backgrounds/store.jpg"),
    #     ("default/carousel-icons/store.jpg",
    #      "https://artwork.emudeck.com/assets/default/carousel-icons/store.jpg"),
    #     ("default/logo/store.png",
    #      "https://artwork.emudeck.com/assets/default/logo/store.png"),
    # ]
    # for rel_path, url in extras:
    #     dest_path = assets_dir / rel_path
    #     dest_path.parent.mkdir(parents=True, exist_ok=True)
    #     resp = requests.get(url, timeout=30)
    #     resp.raise_for_status()
    #     dest_path.write_bytes(resp.content)

def rl_generate_systems_with_missing_images():
    images_path = Path(storage_path / "retrolibrary/artwork")

    def has_missing_images(system_dir, extensions):
        platform = os.path.basename(system_dir)  # Extrae el nombre de la plataforma del directorio
        media_folder_path = os.path.join(images_path, platform, "media")  # Ruta de la carpeta 'media'

        print(media_folder_path)

        file_count = count_visible_files(system_dir)

        if file_count <= 2:
            return False

        if not os.path.isdir(media_folder_path):
            return True

        return False

    roms_dir = roms_path
    valid_system_dirs = []

    valid_system_dirs = rl_get_valid_system_dirs(valid_system_dirs)

    systems_with_missing_images = set()

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in rl_excluded_systems):
            log_message(f"MAP: Skipping directory: {system_dir}")
            continue

        with open(os.path.join(system_dir, 'metadata.txt')) as f:
            metadata = f.read()
        extensions = next((line.split(':')[1].strip().replace(',', ' ') for line in metadata.splitlines() if line.startswith('extensions:')), '').split()

        if has_missing_images(system_dir, extensions):
            systems_with_missing_images.add(os.path.basename(system_dir))
            log_message(f"MAP: System with missing images: {os.path.basename(system_dir)}")

    json_output = json.dumps(list(systems_with_missing_images), indent=4)

    output_file = os.path.join(storage_path, "retrolibrary/cache/missing_systems.json")
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(json_output)

def rl_generate_missing_artwork_lists():
    images_path = os.path.join(storage_path ,"/retrolibrary/artwork")
    roms_dir = roms_path
    valid_system_dirs = []
    valid_system_dirs = rl_get_valid_system_dirs(valid_system_dirs)
    game_list = []

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in rl_excluded_systems):
            log_message(f"MA: Skipping directory: {system_dir}")
            continue

        metadata = rl_parse_metadata_file(os.path.join(system_dir, 'metadata.txt'))
        collection = metadata["collection"]
        shortname = metadata["shortname"]
        launcher = metadata["launcher"]
        extensions = metadata["extensions"]

        games = rl_collect_game_data(system_dir, extensions, images_path)
        if games:
            system_info = {
                "title": collection,
                "id": shortname,
                "launcher": launcher,
                "games": games
            }
            game_list.append(system_info)
            log_message(f"MA: Detected {len(games)} games from {system_dir}")

    json_output = json.dumps(sorted(game_list, key=lambda x: x['title']), indent=4)

    output_file = os.path.join(storage_path, "retrolibrary/cache/missing_artwork_no_hash.json")

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(json_output)
        #print(json_output)

def rl_download_and_extract_artwork_platforms():
    output_dir = Path(storage_path / "retrolibrary/artwork")

    # Fixed path to the JSON file
    json_file_path = Path(storage_path / "retrolibrary/cache/missing_systems.json")

    # Check if the JSON file exists
    if not os.path.exists(json_file_path):
        log_message(f"JSON file not found: {json_file_path}")
        print(f"JSON file not found: {json_file_path}")
        return

    # Read the JSON
    with open(json_file_path, 'r') as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            log_message(f"Error reading JSON file: {e}")
            print(f"Error reading JSON file: {e}")
            return

    # Verify that the JSON contains a list
    if not isinstance(data, list):
        log_message("The JSON file does not contain a valid list.")
        print("The JSON file does not contain a valid list.")
        return

    if not data:
        log_message("No platforms found in the JSON file.")
        print("No platforms found in the JSON file.")
        return

    # Process each platform
    for platform in data:
        extracted_folder = os.path.join(output_dir, platform)
        if os.path.exists(extracted_folder):
            num_files = len([f for f in os.listdir(extracted_folder) if os.path.isfile(os.path.join(extracted_folder, f))])
            if num_files >= 3:
                log_message(f"Skipped: {platform} already extracted at {extracted_folder} with {num_files} files.")
                print(f"Skipped: {platform} already extracted at {extracted_folder} with {num_files} files.")
                continue

        url = f"https://artwork.emudeck.com/artwork_deck/{platform}.zip"
        log_message(f"Downloading: {platform}")
        print(f"Downloading: {platform}")

        try:
            # Download the ZIP file
            response = requests.get(url, stream=True)
            response.raise_for_status()  # Raise an error if the download fails

            # Read the ZIP content in memory
            with zipfile.ZipFile(BytesIO(response.content)) as zip_file:
                print(f"Extracting content from {platform}.zip to {output_dir}")
                zip_file.extractall(output_dir)  # Overwrite by default

            log_message(f"Extracted: {platform} to {output_dir}")
            print(f"Extracted: {platform} to {output_dir}")

        except requests.exceptions.RequestException as e:
            log_message(f"Error downloading {platform}: {e}")
            print(f"Error downloading {url}: {e}")
        except zipfile.BadZipFile as e:
            log_message(f"Error processing the ZIP file for {platform}: {e}")
            print(f"Error processing the ZIP file for {platform}: {e}")

    print("Process completed.")

def rl_rom_parser_ss_get_alias(system):
    system_map = {
        "genesis": "1", "ps3": "59", "ngp": "25", "genesiswide": "1", "mastersystem": "2",
        "nes": "3", "snes": "4", "sneshd": "4", "gb": "9", "gbc": "10", "virtualboy": "11",
        "gba": "12", "gc": "13", "n64": "14", "nds": "15", "wii": "16", "n3ds": "17",
        "sega32x": "19", "segacd": "20", "gamegear": "21", "saturn": "22", "dreamcast": "23",
        "atari2600": "26", "atarijaguar": "27", "atarijaguarcd": "27", "lynx": "28", "3do": "29",
        "pcengine": "31", "bbcmicro": "37", "atari5200": "40", "atari7800": "41", "atarist": "42",
        "atari800": "43", "wonderswan": "45", "wonderswancolor": "46", "colecovision": "48",
        "gw": "52", "psx": "57", "ps2": "58", "psp": "61", "amiga600": "64", "amstradcpc": "65",
        "c64": "66", "scv": "67", "neogeocd": "70", "pcfx": "72", "vic20": "73", "zxspectrum": "76",
        "zx81": "77", "x68000": "79", "channelf": "80", "ngpc": "82", "apple2": "86", "gx4000": "87",
        "dragon": "91", "bk": "93", "vectrex": "102", "supergrafx": "105", "fds": "106", "satellaview": "107",
        "sufami": "108", "sg1000": "109", "amiga1200": "111", "msx": "113", "pcenginecd": "114",
        "intellivision": "115", "msx2": "116", "msxturbor": "118", "n64dd": "122", "scummvm": "123",
        "amigacdtv": "129", "amigacd32": "130", "oricatmos": "131", "amiga": "134", "dos": "135",
        "prboom": "135", "thomson": "141", "neogeo": "142", "sneswide": "202", "megadrive": "203",
        "ti994a": "205", "lutro": "206", "supervision": "207", "pc98": "208", "pokemini": "211",
        "samcoupe": "213", "openbor": "214", "uzebox": "216", "apple2gs": "217", "spectravideo": "218",
        "palm": "219", "x1": "220", "pc88": "221", "tic80": "222", "solarus": "223", "mame": "230",
        "easyrpg": "231", "pico8": "234", "pcv2": "237", "pet": "240", "lowresnx": "244", "switch": "225",
        "wiiU": "18", "primehacks": "16", "naomi": "56", "xbox": "32", "xbox360": "33", "ps4": "60",
        "doom": "135", "atomiswave": "53"
    }
    return system_map.get(system, "unknown")

def rl_fetch_game_artwork(name, platform, media_type):
    username_ss = "djrodtc"
    password_ss = "diFay35WElL"
    api_url_ss = "https://www.screenscraper.fr/api2/"

    s_id = rl_rom_parser_ss_get_alias(platform)
    params = {
        "devid": username_ss,
        "devpassword": password_ss,
        "softname": "EmuDeckRetroLibrary",
        "romnom": name,
        "systemeid": s_id,
        "output": "json"
    }

    response = requests.get(f"{api_url_ss}jeuInfos.php", params=params)
    if response.status_code == 200:
        data = response.json()
        result = {"name": None, "img": None}

        if "response" in data and "jeu" in data["response"] and "medias" in data["response"]["jeu"]:
            medias = data["response"]["jeu"]["medias"]

            for media in medias:
                if media.get("type") == "ss" and media_type == 'screenshot':
                    result["name"] = name
                    result["img"] = media["url"]
                    break
                if media.get("type") == "ss-title" and media_type == 'screenshot':
                    result["name"] = name
                    result["img"] = media["url"]
                    break
                if media.get("type") == media_type:
                    result["name"] = name
                    result["img"] = media["url"]
                    break
                if media.get("type") == "box-2D" and media_type == 'box2dfront':
                    result["name"] = name
                    result["img"] = media["url"]
                    break


        return json.dumps(result)
    else:
        return json.dumps({"name": None, "img": None})

def rl_fetch_game_artwork_md5(filename, platform, media_type):
    username_ss = "djrodtc"
    password_ss = "diFay35WElL"
    api_url_ss = "https://www.screenscraper.fr/api2/"

    s_id = rl_rom_parser_ss_get_alias(platform)
    rom_md5 = calculate_md5(filename)

    params = {
        "devid": username_ss,
        "devpassword": password_ss,
        "softname": "EmuDeckRetroLibrary",
        "rommd5": rom_md5,
        "systemeid": s_id,
        "output": "json"
    }

    response = requests.get(f"{api_url_ss}jeuInfos.php", params=params)
    if response.status_code == 200:
        data = response.json()
        result = {"name": None, "img": None}

        if "response" in data and "jeu" in data["response"] and "medias" in data["response"]["jeu"]:
            medias = data["response"]["jeu"]["medias"]

            for media in medias:
                if media.get("type") == "ss" and media_type == 'screenshot':
                    result["name"] = name
                    result["img"] = media["url"]
                    break
                if media.get("type") == "ss-title" and media_type == 'screenshot':
                    result["name"] = name
                    result["img"] = media["url"]
                    break
                if media.get("type") == media_type:
                    result["name"] = name
                    result["img"] = media["url"]
                    break
                if media.get("type") == "box-2D" and media_type == 'box2dfront':
                    result["name"] = name
                    result["img"] = media["url"]
                    break

        return json.dumps(result)
    else:
        return json.dumps({"name": None, "img": None})

def rl_create_empty_image(name, platform, save_folder, type):
    extension = "jpg" if type != "wheel" else "png"
    folder_path = os.path.join(save_folder, platform, "media", type)
    os.makedirs(folder_path, exist_ok=True)
    img_path = os.path.join(folder_path, f"{name}.{extension}")
    with open(img_path, 'wb') as file:
        pass
    log_message(f"Empty file created: {img_path}")
    print(f"Empty file created: {img_path}")

def rl_download_image(name, platform, img_url, save_folder, type):
    extension = "jpg" if type != "wheel" else "png"
    folder_path = os.path.join(save_folder, platform, "media", type)
    os.makedirs(folder_path, exist_ok=True)
    img_path = os.path.join(folder_path, f"{name}.{extension}")
    try:
        response = requests.get(img_url, timeout=10)
        response.raise_for_status()  # Raise an exception for HTTP error codes
        with open(img_path, 'wb') as file:
            file.write(response.content)
        log_message(f"Image saved: {img_path}")
        print(f"Image saved: {img_path}")
    except requests.RequestException as e:
        log_message(f"Error downloading image for {platform}/{name}: {e}")
        print(f"Error downloading image for {platform}/{name}: {e}")
        #rl_create_empty_image(name, platform, save_folder, type)

def rl_fetch_image_data(game):
    name = game['name']
    platform = game['platform']
    type = game['type']
    filename = game['filename']
    url = f"https://artwork.emudeck.com/steamdbimg.php?name={name}&platform={platform}&type={type}"
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raise an exception for HTTP error codes
        data = response.json()
        img_url = data.get('img')
        if img_url:
            rl_download_image(name, platform, img_url, save_folder, type)
        else:
            #Let's try name matching with SS
            ss_data = rl_fetch_game_artwork(name, platform, type)
            ss_data = json.loads(ss_data)
            if ss_data and ss_data.get('img'):
                rl_download_image(name, platform, ss_data.get('img'), save_folder, type)
            else:
                #Let's try MD5
                ss_data = rl_fetch_game_artwork_md5(filename, platform, type)
                ss_data = json.loads(ss_data)
                if ss_data and ss_data.get('img'):
                    rl_download_image(name, platform, ss_data.get('img'), save_folder, type)
                else:
                    print(f"No img found for {name} in {platform}.")

            #rl_create_empty_image(name, platform, save_folder, type)
    except requests.RequestException as e:
        log_message(f"Error processing {platform}/{name}: {e}")
        print(f"Error processing {platform}/{name}: {e}")
        #rl_create_empty_image(name, platform, save_folder, type)

def rl_process_json_artwork():
    save_folder = Path(storage_path / "retrolibrary/artwork")
    # Read the original JSON
    with open(json_path, 'r') as file:
        systems = json.load(file)

    games = []
    for system in systems:
        games.extend(system.get('games', []))  # Añade todos los juegos del sistema a la lista

    log_message(f"Starting processing for {len(games)} games...")
    print(f"Starting processing for {len(games)} games...")

    # Use ThreadPoolExecutor for parallel downloading
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(rl_fetch_image_data, game) for game in games]
        for future in as_completed(futures):
            try:
                future.result()  # Process exceptions raised in tasks
            except Exception as e:
                log_message(f"Error in a task: {e}")
                print(f"Error in a task: {e}")

    log_message("Processing completed.")
    print("Processing completed.")

def rl_generate_missing_artwork_lists():
    images_path = Path(storage_path / "retrolibrary/artwork")
    roms_dir = roms_path
    valid_system_dirs = []
    valid_system_dirs = rl_get_valid_system_dirs(valid_system_dirs)
    game_list = []

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in rl_excluded_systems):
            log_message(f"MA: Skipping directory: {system_dir}")
            continue

        metadata = rl_parse_metadata_file(os.path.join(system_dir, 'metadata.txt'))
        collection = metadata["collection"]
        shortname = metadata["shortname"]
        launcher = metadata["launcher"]
        extensions = metadata["extensions"]

        games = rl_collect_game_data(system_dir, extensions, images_path)
        if games:
            system_info = {
                "title": collection,
                "id": shortname,
                "launcher": launcher,
                "games": games
            }
            game_list.append(system_info)
            log_message(f"MA: Detected {len(games)} games from {system_dir}")

    json_output = json.dumps(sorted(game_list, key=lambda x: x['title']), indent=4)

    output_file = os.path.join(storage_path, "retrolibrary/cache/missing_artwork_no_hash.json")

    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(json_output)
        #print(json_output)

def rl_save_image(url: str, name: str, system: str) -> Path:
    # 1) Find most-recent Steam userdata folder (if you need it for symlinks later)
    userdata_root = Path.home() / ".steam" / "steam" / "userdata"
    account_folders = sorted(
        (p for p in userdata_root.iterdir() if p.is_dir()),
        key=lambda p: p.stat().st_mtime,
        reverse=True
    )
    account_folder = account_folders[0] if account_folders else None

    # 2) Build destination folder under EmuDeck storage
    dest_folder = storage_path / "retrolibrary" / "artwork" / system / "media" / "box2dfront"
    dest_folder.mkdir(parents=True, exist_ok=True)

    dest_path = dest_folder / f"{name}.jpg"

    # 3) Download
    try:
        import requests
        resp = requests.get(url, timeout=15)
        resp.raise_for_status()
        dest_path.write_bytes(resp.content)
    except Exception:
        # fallback to urllib
        try:
            from urllib.request import urlretrieve
            urlretrieve(url, dest_path)
        except Exception as e:
            print(f"Failed to download {url} → {dest_path}: {e}", file=sys.stderr)
            raise

    return dest_path

def rl_add_game_lists_artwork(
    filename: Union[str, Path],
    app_id: str,
    platform: str,
    storage_path: Union[str, Path]
) -> None:
    filename = Path(filename).stem  # strip any extension
    home = Path.home()
    userdata_root = home / ".steam" / "steam" / "userdata"

    # pick most recent userdata folder
    candidates = [p for p in userdata_root.iterdir() if p.is_dir()]
    if not candidates:
        raise RuntimeError(f"No userdata folders under {userdata_root!r}")
    accountfolder = max(candidates, key=lambda p: p.stat().st_mtime)

    # source artwork
    vertical = storage_path / "retrolibrary" / "artwork" / platform / "media" / "box2dfront" / f"{filename}.jpg"
    grid_src = vertical  # same image for both grid & hero

    # destinations
    dest_cfg = accountfolder / "config" / "grid"
    dest_vert = dest_cfg / f"{app_id}p.png"
    dest_hero = dest_cfg / f"{app_id}_hero.png"
    dest_grid = dest_cfg / f"{app_id}.png"

    # ensure config/grid folder exists
    dest_cfg.mkdir(parents=True, exist_ok=True)

    # remove any existing files or symlinks
    for path in (dest_vert, dest_hero, dest_grid):
        try:
            if path.is_symlink() or path.exists():
                path.unlink()
        except Exception:
            pass

    # create new symlinks
    # use os.replace on Windows (symlink may require admin), fallback to copy
    def _link_or_copy(src: Path, dst: Path):
        try:
            dst.symlink_to(src)
        except (NotImplementedError, OSError):
            shutil.copy2(src, dst)

    _link_or_copy(vertical, dest_vert)
    _link_or_copy(grid_src, dest_hero)
    _link_or_copy(grid_src, dest_grid)

def generate_game_lists_get_percentage() -> Optional[str]:
    # 1) ensure Python env (silently)
    try:
        generate_python_env()
    except Exception:
        pass

    # 2) regenerate missing-artwork lists
    rl_generate_missing_artwork_lists()

    # 3) locate JSON files
    cache_dir = storage_path / "retrolibrary" / "cache"
    json_all = cache_dir / "roms_games.json"
    json_missing = cache_dir / "missing_artwork_no_hash.json"

    if not json_all.exists():
        return None

    # 4) load and count
    with open(json_all, "r", encoding="utf-8") as f:
        data_all = json.load(f)

    # data_all is expected as a list of { ..., "games": [...] } entries
    total_games = sum(len(item.get("games", [])) for item in data_all)

    if total_games == 0:
        return None

    if not json_missing.exists():
        missing_games = 0
    else:
        with open(json_missing, "r", encoding="utf-8") as f:
            data_missing = json.load(f)
        # here data_missing is also list of entries with "games" lists
        missing_games = sum(len(item.get("games", [])) for item in data_missing)

    parsed_games = total_games - missing_games
    percentage = int((parsed_games * 100) / total_games)

    return f"{parsed_games} / {total_games} ({percentage}%)"


##
##RA
##


def rl_get_games():
    try:
        with open(GAMES_LIST_ENDPOINT, 'r') as file:
            # Leer y cargar el contenido JSON
            data = json.load(file)
        return data
    except FileNotFoundError:
        print(f"Error: El archivo {GAMES_LIST_ENDPOINT} no se encuentra.")
        return None
    except json.JSONDecodeError:
        print(f"Error: El archivo {GAMES_LIST_ENDPOINT} no contiene un JSON válido.")
        return None

# Función para obtener información del juego y progreso del usuario
def rl_get_game_info_and_progress(game_id):
    API_USERNAME = "dragoonDorise"
    API_KEY = "mvLqoKB3JmbXrezCd7LIXzMnV42ApWzj"
    BASE_URL = "https://retroachievements.org/API/"
    GAME_INFO_ENDPOINT = f"{BASE_URL}API_GetGameInfoAndUserProgress.php"

    response = requests.get(GAME_INFO_ENDPOINT, params={
        "g": game_id,
        "u": USER,
        "z": API_USERNAME,
        "y": API_KEY
    })
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error al obtener información del juego: {response.status_code}")
        return None

# Función principal
def rl_get_ra(user, md5, path):
    # Obtener lista de juegos
    games = get_games()
    if not games:
        return

    # Buscar juego por MD5
    game_id = None
    for game in games:
        hashes = game.get("Hashes", [])
        if isinstance(hashes, list) and md5_to_find in hashes:
            game_id = game.get("ID")
            break

    if game_id:
        # Obtener datos del juego y progreso del usuario
        game_data = rl_get_game_info_and_progress(game_id)
        if game_data:
            # Imprimir JSON en formato válido
            print(json.dumps(game_data, ensure_ascii=False, indent=4))
    else:
        print("Hash MD5 no encontrado en la lista de juegos.")


####################################################################################


def rl_init(): #generateGameLists
    userdata_dir = home / ".steam" / "steam" / "userdata"

    # 1) Encontrar la carpeta de usuario más reciente por fecha de modificación:
    if not userdata_dir.exists():
        raise FileNotFoundError(f"{userdata_dir!s} no existe")

    account_folders = sorted(
        [p for p in userdata_dir.iterdir() if p.is_dir()],
        key=lambda p: p.stat().st_mtime,
        reverse=True
    )
    if not account_folders:
        raise RuntimeError("No se encontró ninguna carpeta de userdata de Steam")

    accountfolder = account_folders[0]

    artwork_dir = storage_path / "retrolibrary" / "artwork"
    cache_dir   = storage_path / "retrolibrary" / "cache"
    artwork_dir.mkdir(parents=True, exist_ok=True)
    cache_dir.mkdir(parents=True, exist_ok=True)

    config_dir = accountfolder / "config" / "grid" / "retrolibrary"
    config_dir.mkdir(parents=True, exist_ok=True)

    def symlink_force(target: Path, link: Path):
        if link.exists() or link.is_symlink():
            link.unlink()
        link.symlink_to(target, target_is_directory=True)

    symlink_force(artwork_dir, config_dir / "artwork")
    symlink_force(cache_dir,   config_dir / "cache")

    rl_download_achievements()
    rl_download_data()
    rl_download_assets()

    rl_generate_metadata()
    rl_generate_saves_list()
    rl_generate_game_list()

    executor = ThreadPoolExecutor(max_workers=1)
    # lanzamos sin bloquear
    future = executor.submit(rl_get_artwork)

def rl_print_json(): #generateGameListsJson
    f = storage_path / "retrolibrary" / "cache" / "roms_games.json"
    data = json.loads(f.read_text(encoding="utf-8"))
    print(json.dumps(data, indent=2, ensure_ascii=False))

def rl_get_artwork(): #generateGameLists_artwork
    #missing_artwork_platforms
    rl_generate_systems_with_missing_images()
    #download_art_platforms
    rl_download_and_extract_artwork_platforms()
    #missing_artwork_nohash
    rl_generate_missing_artwork_lists()
    #download_art_nohash
    rl_process_json_artwork()

def rl_generate_metadata():
    shutil.copytree(f"{emudeck_backend}/configs/common/roms", roms_path, dirs_exist_ok=True)
    core_pattern = re.compile(r"\bCORESPATH\b")
    emu_pattern  = re.compile(r"\bEMULATIONPATH\b")

    for md in roms_path.rglob("metadata.txt"):
        try:
            text = md.read_text(encoding="utf-8")
        except Exception as e:
            print(f"❌ no pude leer {md!r}: {e}")
            continue
        text="$HOME/.var/app/org.libretro.RetroArch/config/retroarch/cores"
        if system.startswith("win"):
            text=f"{emus_folder}/RetroArch/cores"

        new_text = core_pattern.sub(new_core_key, text)
        new_text = emu_pattern.sub(new_emulation_key, emulation_path)

        if new_text != text:
            try:
                md.write_text(new_text, encoding="utf-8")
                print(f"✅ actualizado {md!r}")
            except Exception as e:
                print(f"❌ error al escribir {md!r}: {e}")