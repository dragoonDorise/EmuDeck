import json
import requests
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
import subprocess
import hashlib

from vars import home_dir, msg_file
from utils import getSettings, log_message

settings = getSettings()
storage_path = os.path.expandvars(settings["storagePath"])

# Path for the JSON and target folder from command-line arguments
save_folder = sys.argv[1]
json_path = os.path.join(storage_path, "retrolibrary/cache/missing_artwork_no_hash.json")

def rom_parser_ss_get_alias(system):
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

def calculate_md5(filename):
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def fetch_game_artwork(name, platform, media_type):
    username_ss = "djrodtc"
    password_ss = "diFay35WElL"
    api_url_ss = "https://www.screenscraper.fr/api2/"

    s_id = rom_parser_ss_get_alias(platform)
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

def fetch_game_artwork_md5(filename, platform, media_type):
    username_ss = "djrodtc"
    password_ss = "diFay35WElL"
    api_url_ss = "https://www.screenscraper.fr/api2/"

    s_id = rom_parser_ss_get_alias(platform)
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


def create_empty_image(name, platform, save_folder, type):
    extension = "jpg" if type != "wheel" else "png"
    folder_path = os.path.join(save_folder, platform, "media", type)
    os.makedirs(folder_path, exist_ok=True)
    img_path = os.path.join(folder_path, f"{name}.{extension}")
    with open(img_path, 'wb') as file:
        pass
    log_message(f"Empty file created: {img_path}")
    print(f"Empty file created: {img_path}")

def download_image(name, platform, img_url, save_folder, type):
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
        #create_empty_image(name, platform, save_folder, type)

def fetch_image_data(game):
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
            download_image(name, platform, img_url, save_folder, type)
        else:
            #Let's try name matching with SS
            ss_data = fetch_game_artwork(name, platform, type)
            ss_data = json.loads(ss_data)
            if ss_data and ss_data.get('img'):
                download_image(name, platform, ss_data.get('img'), save_folder, type)
            else:
                #Let's try MD5
                ss_data = fetch_game_artwork_md5(filename, platform, type)
                ss_data = json.loads(ss_data)
                if ss_data and ss_data.get('img'):
                    download_image(name, platform, ss_data.get('img'), save_folder, type)
                else:
                    print(f"No img found for {name} in {platform}.")

            #create_empty_image(name, platform, save_folder, type)
    except requests.RequestException as e:
        log_message(f"Error processing {platform}/{name}: {e}")
        print(f"Error processing {platform}/{name}: {e}")
        #create_empty_image(name, platform, save_folder, type)

def process_json(save_folder):
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
        futures = [executor.submit(fetch_image_data, game) for game in games]
        for future in as_completed(futures):
            try:
                future.result()  # Process exceptions raised in tasks
            except Exception as e:
                log_message(f"Error in a task: {e}")
                print(f"Error in a task: {e}")

    log_message("Processing completed.")
    print("Processing completed.")


if __name__ == "__main__":
    log_message("Starting image processing script...")
    process_json(save_folder)
    log_message("Image processing script completed.")
