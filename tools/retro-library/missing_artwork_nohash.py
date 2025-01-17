import os
import json
import sys
import re
import subprocess
import hashlib

from vars import home_dir, msg_file
from utils import getSettings, log_message, clean_name, collect_game_data, get_valid_system_dirs, parse_metadata_file

settings = getSettings()
storage_path = os.path.expandvars(settings["storagePath"])


def generate_game_lists(roms_path, images_path):
    roms_dir = roms_path
    valid_system_dirs = []
    valid_system_dirs = get_valid_system_dirs(roms_dir, valid_system_dirs)
    game_list = []

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in ["/model2", "/genesiswide", "/mame", "/emulators", "/desktop", "/sneswide"]):
            log_message(f"MA: Skipping directory: {system_dir}")
            continue

        metadata = parse_metadata_file(os.path.join(system_dir, 'metadata.txt'))
        collection = metadata["collection"]
        shortname = metadata["shortname"]
        launcher = metadata["launcher"]
        extensions = metadata["extensions"]

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