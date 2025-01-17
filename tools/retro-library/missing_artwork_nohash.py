import os
import json
import sys
import re
import subprocess
import hashlib

from vars import home_dir, msg_file
from utils import getSettings, log_message, clean_name, collect_game_data

settings = getSettings()
storage_path = os.path.expandvars(settings["storagePath"])


def generate_game_lists(roms_path, images_path):
    def calculate_hash(file_path):
        import hashlib
        hash_md5 = hashlib.md5()
        try:
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(65536), b""):  # 64 KB chunks
                    hash_md5.update(chunk)
            print(file_path , hash_md5.hexdigest())
            return hash_md5.hexdigest()
        except Exception:
            return None

    roms_dir = roms_path
    valid_system_dirs = []

    for system_dir in os.listdir(roms_dir):
        if os.name != 'nt':
            if system_dir == "xbox360":
                system_dir = "xbox360/roms"
            if system_dir == "model2":
                system_dir = "model2/roms"
        if system_dir == "ps4":
            system_dir = "ps4/shortcuts"
        full_path = os.path.join(roms_dir, system_dir)
        if os.path.isdir(full_path) and not os.path.islink(full_path) and os.path.isfile(os.path.join(full_path, 'metadata.txt')):
            file_count = sum([len(files) for r, d, files in os.walk(full_path) if not os.path.islink(r)])
            if file_count > 2:
                valid_system_dirs.append(full_path)
                log_message(f"MA: Valid system directory found: {full_path}")

    game_list = []

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in ["/model2", "/genesiswide", "/mame", "/emulators", "/desktop", "/sneswide"]):
            log_message(f"MA: Skipping directory: {system_dir}")
            continue

        with open(os.path.join(system_dir, 'metadata.txt')) as f:
            metadata = f.read()
        collection = next((line.split(':')[1].strip() for line in metadata.splitlines() if line.startswith('collection:')), '')
        shortname = next((line.split(':')[1].strip() for line in metadata.splitlines() if line.startswith('shortname:')), '')
        launcher = next((line.split(':', 1)[1].strip() for line in metadata.splitlines() if line.startswith('launch:')), '').replace('"', '\\"')
        extensions = next((line.split(':')[1].strip().replace(',', ' ') for line in metadata.splitlines() if line.startswith('extensions:')), '').split()

        games = collect_game_data(system_dir, extensions, images_path)
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

roms_path = sys.argv[1]
images_path = sys.argv[2]

log_message("MA: Missing artwork list generation in progress...")
generate_game_lists(roms_path, images_path)
log_message("MA: Missing artwork list process completed.")