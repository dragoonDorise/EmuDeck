import os
import json
import sys

def generate_game_lists(roms_path):
    def collect_game_data(system_dir, extensions):
        game_data = []
        for root, _, files in os.walk(system_dir):
            for file in files:
                filename = os.path.basename(file)
                extension = filename.split('.')[-1]
                name = '.'.join(filename.split('.')[:-1])
                if extension in extensions:
                    clean_name = ''.join(e if e.isalnum() else '_' for e in name)
                    game_img = f"/customimages/{clean_name}.jpg"
                    game_info = {
                        "name": name,
                        "filename": os.path.join(root, file),
                        "img": game_img
                    }
                    game_data.append(game_info)
        return game_data

    roms_dir = roms_path
    valid_system_dirs = []

    for system_dir in os.listdir(roms_dir):
        full_path = os.path.join(roms_dir, system_dir)
        if os.path.isdir(full_path) and os.path.isfile(os.path.join(full_path, 'metadata.txt')):
            file_count = sum([len(files) for r, d, files in os.walk(full_path)])
            if file_count > 2:
                valid_system_dirs.append(full_path)

    game_list = []

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in ["/ps3", "/xbox360", "/model2", "/genesiswide"]):
            continue

        with open(os.path.join(system_dir, 'metadata.txt')) as f:
            metadata = f.read()
        collection = next((line.split(':')[1].strip() for line in metadata.splitlines() if line.startswith('collection:')), '')
        shortname = next((line.split(':')[1].strip() for line in metadata.splitlines() if line.startswith('shortname:')), '')
        launcher = next((line.split(':')[1].strip() for line in metadata.splitlines() if line.startswith('launch:')), '').replace('"', '\\"')
        extensions = next((line.split(':')[1].strip().replace(',', ' ') for line in metadata.splitlines() if line.startswith('extensions:')), '').split()

        games = collect_game_data(system_dir, extensions)
        system_info = {
            "title": collection,
            "id": shortname,
            "launcher": launcher,
            "games": games
        }
        game_list.append(system_info)

    json_output = json.dumps(game_list, indent=4)
    home_directory = os.path.expanduser("~")
    output_file = os.path.join(home_directory, 'emudeck', 'roms_games.json')
    with open(output_file, 'w') as f:
        f.write(json_output)

    #print(f"JSON output saved to {output_file}")
    #return json_output

# Ejemplo de uso:
# roms_path = "/ruta/a/roms"
# output_file = "/ruta/al/archivo/output.json"
# generate_game_lists(roms_path, output_file)

roms_path = sys.argv[1]
print(f"{roms_path}")

generate_game_lists(f"{roms_path}")
