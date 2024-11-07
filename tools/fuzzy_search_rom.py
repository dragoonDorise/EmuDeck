import urllib.request
import json
import sys
import os
import subprocess
from difflib import SequenceMatcher
from datetime import datetime, timedelta

def similar(a, b):
    return SequenceMatcher(None, a, b).ratio()

def simple_similarity(a, b):
        # Calcula la longitud de la coincidencia de prefijo más larga
        match_length = len([i for i in range(min(len(a), len(b))) if a[i] == b[i]])
        # Normaliza en función de la longitud del título de búsqueda
        return match_length / max(len(a), len(b))

def find_best_match(search_title, games):
    best_match = None
    highest_similarity = 0

    for game in games:
        # Calcula la similitud basada en el prefijo
        similarity = simple_similarity(search_title, game)
        if similarity > highest_similarity:
            highest_similarity = similarity
            best_match = game

    return best_match




def is_file_older_than(file_path, days):
    file_time = datetime.fromtimestamp(os.path.getmtime(file_path))
    return datetime.now() - file_time > timedelta(days=days)

# URL del JSON
url = "https://steamgriddb.com/api/games"

# Título para buscar
search_title = sys.argv[1]
images_path = sys.argv[2]
#print(f"{search_title}")
#sys.exit()

# Directorio para guardar el archivo JSON
home_dir = os.path.expanduser("~")
emudeck_dir = os.path.join(home_dir, "emudeck")
os.makedirs(emudeck_dir, exist_ok=True)
json_file_path = os.path.join(emudeck_dir, "games.json")

# Descargar o cargar el JSON
if not os.path.exists(json_file_path) or is_file_older_than(json_file_path, 5):

    bash_command = 'wget --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36" "https://steamgriddb.com/api/games" -O "$HOME/emudeck/games.json"'
    try:
        result = subprocess.run(bash_command, shell=True, check=True, text=True, capture_output=True)
        print("Salida del comando:", result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Ocurrió un error al ejecutar el comando: {e}")

else:
    for root, _, files in os.walk(images_path):
        for file in files:
            file_path = os.path.join(root, file)
            # Verifica si el archivo tiene un tamaño de 0 bytes
            if os.path.getsize(file_path) == 0:
                os.remove(file_path)

    # Cargar el JSON desde el disco duro
    with open(json_file_path, "r") as json_file:
        data = json_file.read()

# Intentar cargar el JSON
try:
    json_data = json.loads(data)
except json.JSONDecodeError as e:
    print(f"Error al decodificar JSON: {e}")
    json_data = {}

# Asegúrate de que esta parte esté adaptada a la estructura real del JSON
if isinstance(json_data, list):
    games = [game for game in json_data if "name" in game]
elif isinstance(json_data, dict) and 'games' in json_data:
    games = [game for game in json_data['games']]
else:
    print("No se encontraron juegos en el JSON o la estructura no es la esperada.")
    games = []

# Buscar el título más parecido
if games:
    best_match = find_best_match(search_title, games)
    # Mostrar el resultado
    print(f"{best_match}")
else:
    print("null")
