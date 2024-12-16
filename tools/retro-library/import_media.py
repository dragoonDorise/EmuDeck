import os
import re
import shutil
import argparse
from pathlib import Path

# Configuración de argumentos de línea de comandos
parser = argparse.ArgumentParser(description="Script para copiar archivos de medios normalizados.")
parser.add_argument("roms_dir", type=str, help="Ruta del directorio de roms")
parser.add_argument("target_dir", type=str, help="Ruta del directorio de destino")
args = parser.parse_args()

# Definir rutas desde los argumentos
roms_dir = Path(args.roms_dir)
target_dir = Path(args.target_dir)

# Crear la carpeta de destino si no existe
target_dir.mkdir(parents=True, exist_ok=True)

# Función para leer las extensiones del archivo metadata.txt
def get_extensions_from_metadata(file_path):
    extensions = []
    with open(file_path, 'r') as file:
        for line in file:
            if line.startswith("extensions:"):
                ext_string = line.split(":", 1)[1].strip()
                extensions = [ext.strip().lower() for ext in ext_string.split(",")]
                break
    return extensions

# Función para obtener los archivos de roms con las extensiones especificadas
def get_rom_files(directory, extensions):
    rom_files = []
    for file in directory.iterdir():
        if file.is_file() and any(file.name.lower().endswith(ext) for ext in extensions):
            rom_files.append(file)  # Guardamos la ruta completa del archivo ROM
    return rom_files

# Función para normalizar el nombre del archivo
def normalize_filename(name):
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
    name_cleaned = name_cleaned.replace(',_', ',')

    return name_cleaned

# Función para buscar coincidencias en media y copiar el archivo correspondiente con extensión forzada a jpg
def find_and_copy_media(rom_files, media_dir, target_dir):
    media_files = {media.stem: media for media in media_dir.iterdir() if media.is_file()}

    for rom in rom_files:
        rom_name = rom.stem
        # Buscar coincidencia exacta en media (basado en el nombre sin extensión)
        if rom_name in media_files:
            media_file = media_files[rom_name]  # Obtener el archivo de media correspondiente
            # Normalizar el nombre del archivo destino
            normalized_name = normalize_filename(rom.stem)
            target_path = target_dir / rom / f"{normalized_name}.jpg"
            shutil.copy(media_file, target_path)
            print(f"Copiado: {media_file} -> {target_path}")

# Iterar por cada subcarpeta de plataforma en el directorio de roms
for platform_dir in roms_dir.iterdir():
    if platform_dir.is_dir() and platform_dir.name != "media":
        metadata_file = platform_dir / "metadata.txt"

        if metadata_file.exists():
            extensions = get_extensions_from_metadata(metadata_file)
            rom_files = get_rom_files(platform_dir, extensions)

            # Definir el directorio de media específico para la plataforma
            media_dir = platform_dir / "media/box2dfront"

            if media_dir.exists():
                find_and_copy_media(rom_files, media_dir, target_dir)
            else:
                print(f"Advertencia: La carpeta de media {media_dir} no existe para la plataforma {platform_dir.name}.")
