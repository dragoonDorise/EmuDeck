import os
import json
import sys
import re
import subprocess

# Define the log file path
home_dir = os.environ.get("HOME")
msg_file = os.path.join(home_dir, ".config/EmuDeck/logs/msg.log")

def getSettings():
    pattern = re.compile(r'([A-Za-z_][A-Za-z0-9_]*)=(.*)')
    user_home = os.path.expanduser("~")

    if os.name == 'nt':
        config_file_path = os.path.join(user_home, 'emudeck', 'settings.ps1')
    else:
        config_file_path = os.path.join(user_home, 'emudeck', 'settings.sh')

    configuration = {}

    with open(config_file_path, 'r') as file:
        for line in file:
            match = pattern.search(line)
            if match:
                variable = match.group(1)
                value = match.group(2).strip().strip('"')
                expanded_value = os.path.expandvars(value.replace('"', '').replace("'", ""))
                configuration[variable] = expanded_value

    # Obtener rama actual del repositorio backend
    if os.name == 'nt':
        bash_command = f"cd {os.path.join(user_home, 'AppData', 'Roaming', 'EmuDeck', 'backend')} && git rev-parse --abbrev-ref HEAD"
    else:
        bash_command = "cd $HOME/.config/EmuDeck/backend/ && git rev-parse --abbrev-ref HEAD"

    result = subprocess.run(bash_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    configuration["branch"] = result.stdout.strip()

    configuration["systemOS"] = os.name

    return configuration

settings = getSettings()
storage_path = os.path.expandvars(settings["storagePath"])
saves_path = os.path.expandvars(settings["savesPath"])

# Function to write messages to the log file
def log_message(message):
    with open(msg_file, "a") as log_file:  # "a" to append messages without overwriting
        log_file.write(message + "\n")

def generate_saves_list(saves_path):
    def clean_name(filename):
        """Clean the game name using the same logic as in the ROM JSON."""
        name_cleaned = re.sub(r'\(.*?\)', '', filename)
        name_cleaned = re.sub(r'\[.*?\]', '', name_cleaned)
        name_cleaned = name_cleaned.strip().replace(' ', '_').replace('-', '_')
        name_cleaned = re.sub(r'_+', '_', name_cleaned)
        name_cleaned = name_cleaned.replace('+', '').replace('&', '').replace('!', '').replace("'", '').replace('.', '')
        return name_cleaned

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
    def collect_game_data(system_dir, extensions):
        game_data = []
        for root, _, files in os.walk(system_dir):
            for file in files:
                file_path = os.path.join(root, file)
                if os.path.islink(file_path):
                    continue

                filename = os.path.basename(file)
                extension = filename.split('.')[-1]
                name = '.'.join(filename.split('.')[:-1])
                if extension in extensions:
                    # Special cases for WiiU and PS3
                    if "wiiu" in system_dir:
                        parts = root.split(os.sep)
                        name = parts[-2] if len(parts) >= 2 else name
                    if "ps3" in system_dir:
                        parts = root.split(os.sep)
                        name = parts[-3] if len(parts) >= 3 else name

                    platform = os.path.basename(system_dir)

                    # Clean the game name
                    name_cleaned = re.sub(r'\(.*?\)', '', name)
                    name_cleaned = re.sub(r'\[.*?\]', '', name_cleaned)
                    name_cleaned = name_cleaned.strip().replace(' ', '_').replace('-', '_')
                    name_cleaned = re.sub(r'_+', '_', name_cleaned)
                    name_cleaned = name_cleaned.replace('+', '').replace('&', '').replace('!', '').replace("'", '').replace('.', '')
                    name_cleaned_pegasus = name.replace(',_', ',')
                    name_cleaned = name_cleaned.lower()


                    game_info = {
                        "name": name_cleaned,
                        "filename": file_path,
                        "file": name_cleaned,
                        "img": f"/customimages/retrolibrary/artwork/{platform}/media",
                        "platform": platform
                    }
                    game_data.append(game_info)
        return sorted(game_data, key=lambda x: x['name'])

    roms_dir = roms_path
    valid_system_dirs = []

    for system_dir in os.listdir(roms_dir):
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
                log_message(f"GGL: Valid system directory found: {full_path}")

    game_list = []

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in ["/model2", "/genesiswide", "/mame", "/emulators", "/desktop"]):
            log_message(f"GGL: Skipping directory: {system_dir}")
            continue

        with open(os.path.join(system_dir, 'metadata.txt')) as f:
            metadata = f.read()
        collection = next((line.split(':')[1].strip() for line in metadata.splitlines() if line.startswith('collection:')), '')
        shortname = next((line.split(':')[1].strip() for line in metadata.splitlines() if line.startswith('shortname:')), '')
        launcher = next((line.split(':', 1)[1].strip() for line in metadata.splitlines() if line.startswith('launch:')), '').replace('"', '\\"')
        extensions = next((line.split(':')[1].strip().replace(',', ' ') for line in metadata.splitlines() if line.startswith('extensions:')), '').split()

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