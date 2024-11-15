import json
import requests
import os
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

# Path del JSON y carpeta de destino desde los argumentos
save_folder = sys.argv[1]
json_path = os.path.expanduser(f'~/emudeck/cache/missing_artwork.json')

def create_empty_image(name, platform, save_folder):
    # Crear la carpeta si no existe
    os.makedirs(save_folder, exist_ok=True)
    # Definir la ruta de guardado para el archivo vacío
    img_path = os.path.join(save_folder, f"{platform}/{name}.jpg")
    print(img_path)
    # Crear un archivo vacío
    with open(img_path, 'wb') as file:
        pass  # No escribimos nada para que quede vacío
    print(f"Archivo vacío creado para {name}")

def download_image(name, platform, img_url, save_folder):
    # Crear la carpeta si no existe
    os.makedirs(save_folder, exist_ok=True)
    # Definir la ruta de guardado
    img_path = os.path.join(save_folder, f"{platform}/{name}.jpg")
    print(img_path)
    # Descargar y guardar la imagen
    response = requests.get(img_url)
    if response.status_code == 200:
        with open(img_path, 'wb') as file:
            file.write(response.content)
        print(f"Imagen guardada como {img_path}")
    else:
        print(f"Error al descargar la imagen para {platform}/{name}")

def fetch_image_data(game):
    name = game['name']
    platform = game['platform']
    url = f"https://bot.emudeck.com/steamdbimg.php?name={name}&platform={platform}"

    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            img_url = data.get('img')  # Usar get para evitar errores si 'img' no existe o es None
            if img_url:
                download_image(name, platform, img_url, save_folder)
            else:
                print(f"No se encontró una URL de imagen válida para {platform}/{name}. Creando archivo vacío.")
                create_empty_image(name, platform, save_folder)
        else:
            print(f"Error al llamar al servicio para {platform}/{name}")
            create_empty_image(name, platform, save_folder)
    except requests.RequestException as e:
        print(f"Excepción al procesar {platform}/{name}: {e}")
        create_empty_image(name, platform, save_folder)

def process_json(save_folder):
    # Leer el JSON original
    with open(json_path, 'r') as file:
        games = json.load(file)

    # Usar ThreadPoolExecutor para descargar en paralelo
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(fetch_image_data, game) for game in games]
        for future in as_completed(futures):
            future.result()  # Esperar a que cada tarea termine

process_json(save_folder)
