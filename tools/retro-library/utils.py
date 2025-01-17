import os
import re
import subprocess
from vars import home_dir, msg_file

def getSettings():
    pattern = re.compile(r'([A-Za-z_][A-Za-z0-9_]*)=(.*)')
    user_home = os.path.expanduser("~")

    if os.name == 'nt':
        config_file_path = os.path.join(user_home, 'AppData', 'Roaming', 'EmuDeck', 'settings.ps1')
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

def log_message(message):
    with open(msg_file, "a") as log_file:  # "a" to append messages without overwriting
        log_file.write(message + "\n")

def clean_name(name):
    name_cleaned = re.sub(r'\(.*?\)', '', name)
    name_cleaned = re.sub(r'\[.*?\]', '', name_cleaned)
    name_cleaned = name_cleaned.strip().replace(' ', '_').replace('-', '_')
    name_cleaned = re.sub(r'_+', '_', name_cleaned)
    name_cleaned = name_cleaned.replace('+', '').replace('&', '').replace('!', '').replace("'", '').replace('.', '').replace('_decrypted','').replace('decrypted','').replace('.ps3', '')
    name_cleaned_pegasus = name.replace(',_', ',')
    name_cleaned = name_cleaned.lower()
    return name_cleaned

def collect_game_data(system_dir, extensions, images_path = None):
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

                platform = os.path.basename(system_dir)

                # Special cases for WiiU and PS3
                if os.name != 'nt':
                    if "wiiu" in system_dir:
                        parts = root.split(os.sep)
                        name = parts[-2] if len(parts) >= 2 else name
                        platform = "wiiu"
                    if "ps3" in system_dir:
                        parts = root.split(os.sep)
                        name = parts[-3] if len(parts) >= 3 else name
                        platform = "ps3"
                    if "xbox360" in system_dir:
                        platform = "xbox360"
                if "ps4" in system_dir:
                    parts = root.split(os.sep)
                    name = parts[-3] if len(parts) >= 3 else name
                    platform = "ps4"

                # Clean the game name
                name_cleaned = clean_name(name)

                if images_path:
                    # Check for missing images
                    for img_type, ext in [("box2dfront", ".jpg"), ("wheel", ".png"), ("box2dfront", ".jpg")]:
                        img_path = os.path.join(images_path, f"{platform}/media/{img_type}/{name_cleaned}{ext}")
                        if not os.path.exists(img_path):
                            log_message(f"Missing image: {img_path}")

                        game_info = {
                            "name": name_cleaned,
                            "platform": platform,
                            "type": img_type
                        }
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


def get_valid_system_dirs(roms_dir):
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
                log_message(f"GGL: Valid system directory found: {full_path}")
        return valid_system_dirs