import json
import requests
import os
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

# Path del JSON y carpeta de destino desde los argumentos
save_folder = sys.argv[1]
json_path = os.path.expanduser('~/emudeck/cache/missing_artwork.json')

def create_empty_image(name, platform, save_folder, type):
    extension = "jpg" if type != "wheel" else "png"
    # Crear la ruta completa para la carpeta
    folder_path = os.path.join(save_folder, platform, "media", type)
    os.makedirs(folder_path, exist_ok=True)
    img_path = os.path.join(folder_path, f"{name}.{extension}")
    # Crear archivo vacío
    with open(img_path, 'wb') as file:
        pass
    print(f"Archivo vacío creado: {img_path}")

def download_image(name, platform, img_url, save_folder, type):
    extension = "jpg" if type != "wheel" else "png"
    # Crear la ruta completa para la carpeta
    folder_path = os.path.join(save_folder, platform, "media", type)
    os.makedirs(folder_path, exist_ok=True)
    img_path = os.path.join(folder_path, f"{name}.{extension}")
    try:
        response = requests.get(img_url, timeout=10)
        response.raise_for_status()  # Lanza una excepción para códigos de error HTTP
        with open(img_path, 'wb') as file:
            file.write(response.content)
        print(f"Imagen guardada: {img_path}")
    except requests.RequestException as e:
        print(f"Error al descargar la imagen para {platform}/{name}: {e}")
        create_empty_image(name, platform, save_folder, type)

def fetch_image_data(game):
    name = game['name']
    platform = game['platform']
    hash = game['hash']
    type = game['type']
    url = f"https://bot.emudeck.com/steamdbimg.php?name={name}&platform={platform}&hash={hash}"

    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Lanza una excepción para códigos de error HTTP
        data = response.json()
        img_url = data.get('img')
        if img_url:
            download_image(name, platform, img_url, save_folder, type)
        else:
            print(f"No se encontró URL para {platform}/{name}. Creando archivo vacío.")
            create_empty_image(name, platform, save_folder, type)
    except requests.RequestException as e:
        print(f"Error procesando {platform}/{name}: {e}")
        create_empty_image(name, platform, save_folder, type)

def process_json(save_folder):
    # Leer el JSON original
    with open(json_path, 'r') as file:
        games = json.load(file)

    # Usar ThreadPoolExecutor para descargar en paralelo
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(fetch_image_data, game) for game in games]
        for future in as_completed(futures):
            try:
                future.result()  # Procesar excepciones lanzadas en cada tarea
            except Exception as e:
                print(f"Error en una tarea: {e}")

if __name__ == "__main__":
    process_json(save_folder)
