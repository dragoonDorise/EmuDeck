import os
import json
import sys
import re
import hashlib

def generate_game_lists(roms_path, images_path):
    def calculate_hash(file_path):
        hash_md5 = hashlib.md5()
        try:
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)
            return hash_md5.hexdigest()
        except Exception as e:
            print(f"Error al calcular el hash para {file_path}: {e}")
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
                    if "wiiu" in system_dir:
                        if extension == "wux":
                            name = name
                        elif extension == "wua":
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

                    if "ps3" in system_dir:
                            parts = root.split(os.sep)
                            if len(parts) >= 3:
                                name = parts[-3]
                            else:
                                name = name

                            if name == "roms":
                               name = name

                            if name == "ps3":
                               name = parts[-1]

                    platform = os.path.basename(system_dir)

                    name_cleaned = re.sub(r'\(.*?\)', '', name)
                    name_cleaned = re.sub(r'\[.*?\]', '', name_cleaned)
                    name_cleaned = name_cleaned.strip()
                    name_cleaned = name_cleaned.replace(' ', '_').replace('-', '_')
                    name_cleaned = re.sub(r'_+', '_', name_cleaned)
                    name_cleaned = name_cleaned.replace('+', '').replace('&', '').replace('!', '').replace("'", '').replace('.', '')

                    game_img = f"/customimages/emudeck/{platform}/{name_cleaned}.jpg"
                    rom_hash = calculate_hash(file_path)
                    # Verificar si la imagen existe en el images_path

                    img_path = os.path.join(images_path, f"{platform}/{name_cleaned}.jpg")
                    #print(img_path)
                    if not os.path.exists(img_path):
                        game_info = {
                            "name": name_cleaned,
                            "platform": platform
                            "hash": rom_hash
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
        if any(x in system_dir for x in ["/model2", "/genesiswide", "/mame", "/emulators", "/desktop"]):
            continue

        with open(os.path.join(system_dir, 'metadata.txt')) as f:
            metadata = f.read()
        extensions = next((line.split(':')[1].strip().replace(',', ' ') for line in metadata.splitlines() if line.startswith('extensions:')), '').split()

        games = collect_game_data(system_dir, extensions)
        if games:
            game_list.extend(games)

    json_output = json.dumps(game_list, indent=4)
    home_directory = os.path.expanduser("~")
    output_file = os.path.join(home_directory, 'emudeck', 'cache', 'missing_artwork.json')
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(json_output)

# Pasar la ruta de las ROMs y de las imágenes desde los argumentos de línea de comandos
roms_path = sys.argv[1]
images_path = sys.argv[2]

generate_game_lists(roms_path, images_path)
