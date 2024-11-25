import os
import json
import sys
import re
import hashlib

# Define the log file path
home_dir = os.environ.get("HOME")
msg_file = os.path.join(home_dir, ".config/EmuDeck/msg.log")

# Function to write messages to the log file
def log_message(message):
    with open(msg_file, "w") as log_file:  # "a" to append messages without overwriting
        log_file.write(message + "\n")

def generate_game_lists(roms_path, images_path):
    def calculate_hash(file_path):
        hash_md5 = hashlib.md5()
        try:
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)
            return hash_md5.hexdigest()
        except Exception as e:
            log_message(f"Error calculating hash for {file_path}: {e}")
            return None

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
                    # Custom logic for specific systems
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

                    rom_hash = calculate_hash(file_path)

                    # Check for missing images
                    for img_type, ext in [("box2dfront", ".jpg"), ("wheel", ".png"), ("screenshot", ".jpg")]:
                        img_path = os.path.join(images_path, f"{platform}/media/{img_type}/{name_cleaned}{ext}")
                        if not os.path.exists(img_path):
                            game_info = {
                                "name": name_cleaned,
                                "platform": platform,
                                "hash": rom_hash,
                                "type": img_type
                            }
                            game_data.append(game_info)
                            log_message(f"Missing {img_type} image: {img_path}")

        game_data_sorted = sorted(game_data, key=lambda x: x['name'])
        return game_data_sorted

    roms_dir = roms_path
    valid_system_dirs = []

    # Validate system directories
    for system_dir in os.listdir(roms_dir):
        if system_dir == "xbox360":
            system_dir = "xbox360/roms"
        full_path = os.path.join(roms_dir, system_dir)
        if os.path.isdir(full_path) and not os.path.islink(full_path) and os.path.isfile(os.path.join(full_path, 'metadata.txt')):
            file_count = sum([len(files) for r, d, files in os.walk(full_path) if not os.path.islink(r)])
            if file_count > 2:
                valid_system_dirs.append(full_path)
                log_message(f"Valid system directory found: {full_path}")

    game_list = []

    # Process each system directory
    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in ["/model2", "/genesiswide", "/mame", "/emulators", "/desktop"]):
            log_message(f"Skipping directory: {system_dir}")
            continue

        with open(os.path.join(system_dir, 'metadata.txt')) as f:
            metadata = f.read()
        extensions = next((line.split(':')[1].strip().replace(',', ' ') for line in metadata.splitlines() if line.startswith('extensions:')), '').split()

        games = collect_game_data(system_dir, extensions)
        if games:
            game_list.extend(games)
            log_message(f"Collected {len(games)} games from {system_dir}")

    # Save the JSON output
    json_output = json.dumps(game_list, indent=4)
    home_directory = os.path.expanduser("~")
    output_file = os.path.join(home_directory, 'emudeck', 'cache', 'missing_artwork.json')
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(json_output)
        log_message(f"JSON output saved to: {output_file}")

# Read ROMs and images paths from command-line arguments
roms_path = sys.argv[1]
images_path = sys.argv[2]

log_message("Starting game list generation process...")
generate_game_lists(roms_path, images_path)
log_message("Game list generation process completed.")
