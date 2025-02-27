import os
import json
import sys
import re
import subprocess
from vars import home_dir, msg_file, excluded_systems
from utils import getSettings, log_message, clean_name, collect_game_data, get_valid_system_dirs, parse_metadata_file

settings = getSettings()
storage_path = os.path.expandvars(settings["storagePath"])
saves_path = os.path.expandvars(settings["savesPath"])


def generate_saves_list(saves_path):

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
                cleaned_name = clean_name(os.path.splitext(file)[0])
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

def generate_game_lists(roms_path):
    roms_dir = roms_path
    valid_system_dirs = []
    valid_system_dirs = get_valid_system_dirs(roms_dir, valid_system_dirs)
    game_list = []

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in excluded_systems):
            log_message(f"GGL: Skipping directory: {system_dir}")
            continue

        metadata = parse_metadata_file(os.path.join(system_dir, 'metadata.txt'))
        collection = metadata["collection"]
        shortname = metadata["shortname"]
        launcher = metadata["launcher"]
        extensions = metadata["extensions"]

        games = collect_game_data(system_dir, extensions)
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

roms_path = sys.argv[1]

log_message("GGL: Starting game list generation...")
generate_game_lists(f"{roms_path}")
log_message("GGL: Game list generation completed.")

log_message("GGL: Starting saves list generation...")
generate_saves_list(saves_path)
log_message("GGL: Saves list generation completed.")