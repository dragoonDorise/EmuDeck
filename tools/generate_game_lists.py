import os
import json
import sys
import re

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
                    if "wiiu" in system_dir:
                        if extension == "wux":
                            name = name
                        else:
                            parts = root.split(os.sep)
                            if len(parts) >= 2:
                                name = parts[-2]
                            else:
                                name = name

                            if name == "roms":
                               name = name

                            if name == "wiiu":
                               name = parts[-1]

                    name_cleaned = re.sub(r'\(.*?\)', '', name)
                    name_cleaned = re.sub(r'\[.*?\]', '', name_cleaned)
                    name_cleaned = name_cleaned.strip()

                    name_cleaned = name_cleaned.replace(' ', '_')
                    name_cleaned = name_cleaned.replace('-', '_')
                    name_cleaned = re.sub(r'_+', '_', name_cleaned)
                    name_cleaned = name_cleaned.replace('+', '')
                    name_cleaned = name_cleaned.replace('&', '')
                    name_cleaned = name_cleaned.replace('!', '')
                    name_cleaned = name_cleaned.replace("'", '')
                    name_cleaned = name_cleaned.replace('.', '')
                    name_cleaned_pegasus = name.replace(',_', ',')

                    clean_name = name_cleaned
                    game_img = f"/customimages/emudeck/{clean_name}.jpg"
                    game_info = {
                        "name": clean_name,
                        "filename": file_path,
                        "file": name_cleaned_pegasus,
                        "img": game_img
                    }
                    game_data.append(game_info)
        game_data_sorted = sorted(game_data, key=lambda x: x['name'])
        return game_data_sorted

    roms_dir = roms_path
    valid_system_dirs = []

    for system_dir in os.listdir(roms_dir):
        if system_dir == "xbox360":
            system_dir = "xbox360/roms"
        full_path = os.path.join(roms_dir, system_dir)
        if os.path.isdir(full_path) and not os.path.islink(full_path) and os.path.isfile(os.path.join(full_path, 'metadata.txt')):
            file_count = sum([len(files) for r, d, files in os.walk(full_path) if not os.path.islink(r)])
            if file_count > 2:
                valid_system_dirs.append(full_path)

    game_list = []

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in ["/ps3", "/model2", "/genesiswide", "/mame", "/emulators", "/desktop"]):
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
            game_list_sorted = sorted(game_list, key=lambda x: x['title'])


    json_output = json.dumps(game_list_sorted, indent=4)
    home_directory = os.path.expanduser("~")
    output_file = os.path.join(home_directory, 'emudeck', 'cache', 'roms_games.json')
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(json_output)

roms_path = sys.argv[1]

generate_game_lists(f"{roms_path}")
