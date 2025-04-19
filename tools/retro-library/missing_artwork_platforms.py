import os
import json
import sys
from vars import excluded_systems
from utils import get_settings, log_message, get_valid_system_dirs


settings = get_settings()
storage_path = os.path.expandvars(settings["storagePath"])


def generate_systems_with_missing_images(roms_path, images_path):
    def has_missing_images(system_dir, extensions):
        platform = os.path.basename(system_dir)  # Extrae el nombre de la plataforma del directorio
        media_folder_path = os.path.join(images_path, platform, "media")  # Ruta de la carpeta 'media'

        file_count = sum(
            1 for root, _, files in os.walk(system_dir)
            for file in files
            if not os.path.islink(os.path.join(root, file))
        )

        if file_count <= 3:
            return False

        if not os.path.isdir(media_folder_path):
            return True

        return False

    roms_dir = roms_path
    valid_system_dirs = []

    valid_system_dirs = get_valid_system_dirs(roms_dir, valid_system_dirs)

    systems_with_missing_images = set()

    for system_dir in valid_system_dirs:
        if any(x in system_dir for x in excluded_systems):
            log_message(f"MAP: Skipping directory: {system_dir}")
            continue

        with open(os.path.join(system_dir, 'metadata.txt')) as f:
            metadata = f.read()
        extensions = next((line.split(':')[1].strip().replace(',', ' ') for line in metadata.splitlines() if line.startswith('extensions:')), '').split()

        if has_missing_images(system_dir, extensions):
            systems_with_missing_images.add(os.path.basename(system_dir))
            log_message(f"MAP: System with missing images: {os.path.basename(system_dir)}")

    json_output = json.dumps(list(systems_with_missing_images), indent=4)

    output_file = os.path.join(storage_path, "retrolibrary/cache/missing_systems.json")
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(json_output)

# Pasar la ruta de las ROMs y de las imágenes desde los argumentos de línea de comandos
roms_path = sys.argv[1]
images_path = sys.argv[2]

log_message("MAP: Searching missing artwork in bundles...")
generate_systems_with_missing_images(roms_path, images_path)
log_message("MAP: Completed missing artwork in bundles")
