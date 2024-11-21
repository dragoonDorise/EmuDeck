import os
import json
import requests
import zipfile
from io import BytesIO
import sys

def download_and_extract(output_dir):
    # Ruta fija del archivo JSON
    json_file_path = os.path.expanduser("~/emudeck/cache/missing_artwork.json")

    # Verificar que el archivo JSON exista
    if not os.path.exists(json_file_path):
        print(f"Archivo JSON no encontrado: {json_file_path}")
        return

    # Leer el JSON
    with open(json_file_path, 'r') as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Error al leer el archivo JSON: {e}")
            return

    # Extraer las plataformas incompletas
    incomplete_platforms = data.get("incomplete_platforms", [])
    if not isinstance(incomplete_platforms, list):
        print("El archivo JSON no contiene una lista válida en 'incomplete_platforms'.")
        return

    if not incomplete_platforms:
        print("No hay plataformas incompletas en el archivo JSON.")
        return

    # Crear el directorio de salida si no existe
    os.makedirs(output_dir, exist_ok=True)

    # Procesar cada plataforma
    for platform in incomplete_platforms:
        url = f"https://bot.emudeck.com/artwork_deck/{platform}.zip"
        print(f"Descargando: {url}")

        try:
            # Descargar el archivo ZIP
            response = requests.get(url, stream=True)
            response.raise_for_status()  # Lanza un error si la descarga falla

            # Leer el contenido del ZIP en memoria
            with zipfile.ZipFile(BytesIO(response.content)) as zip_file:
                print(f"Extrayendo contenido de {platform}.zip a {output_dir}")
                zip_file.extractall(output_dir)  # Sobrescribe por defecto

        except requests.exceptions.RequestException as e:
            print(f"Error al descargar {url}: {e}")
        except zipfile.BadZipFile as e:
            print(f"Error al procesar el ZIP para {platform}: {e}")

    print("Proceso completado.")

# Verificar argumentos de línea de comandos
if len(sys.argv) != 2:
    print("Uso: python3 download_and_extract.py <ruta_destino>")
    sys.exit(1)

# Directorio de salida pasado como argumento
output_dir = sys.argv[1]

download_and_extract(output_dir)
