import urllib.request
import json
import sys
import os
from difflib import SequenceMatcher
from datetime import datetime, timedelta

def similar(a, b):
    return SequenceMatcher(None, a, b).ratio()

def find_best_match(search_title, games):
    best_match = None
    highest_similarity = 0

    for game in games:
        similarity = similar(search_title, game)  # Asegúrate de que estás comparando con el nombre del juego
        if similarity > highest_similarity:
            highest_similarity = similarity
            best_match = game  # Devolver solo el nombre del juego o el objeto completo si prefieres

    return best_match

def is_file_older_than(file_path, days):
    file_time = datetime.fromtimestamp(os.path.getmtime(file_path))
    return datetime.now() - file_time > timedelta(days=days)

# URL del JSON
url = "https://steamgriddb.com/api/games"

# Título para buscar
search_title = sys.argv[1]
#print(f"{search_title}")
#sys.exit()

# Directorio para guardar el archivo JSON
home_dir = os.path.expanduser("~")
emudeck_dir = os.path.join(home_dir, "emudeck")
os.makedirs(emudeck_dir, exist_ok=True)
json_file_path = os.path.join(emudeck_dir, "games.json")

# Descargar o cargar el JSON
if not os.path.exists(json_file_path) or is_file_older_than(json_file_path, 5):
    # Configurar la solicitud con un User-Agent
    request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    # Descargar el JSON
    with urllib.request.urlopen(request) as response:
        data = response.read().decode()

    # Guardar el JSON en el disco duro
    with open(json_file_path, "w") as json_file:
        json_file.write(data)
else:
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
