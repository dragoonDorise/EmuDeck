import requests
import sys
import warnings
import json
from requests.exceptions import RequestsDependencyWarning

warnings.filterwarnings("ignore", category=RequestsDependencyWarning)

# Credenciales y usuario
API_USERNAME = "dragoonDorise"
API_KEY = "mvLqoKB3JmbXrezCd7LIXzMnV42ApWzj"
USER = sys.argv[1]
md5_to_find = sys.argv[2]
LOCAL_PATH = sys.argv[3]

# Endpoints
BASE_URL = "https://retroachievements.org/API/"
GAMES_LIST_ENDPOINT = f"{LOCAL_PATH}"
GAME_INFO_ENDPOINT = f"{BASE_URL}API_GetGameInfoAndUserProgress.php"

# Función para cargar la lista de juegos
def get_games():
    try:
        with open(GAMES_LIST_ENDPOINT, 'r') as file:
            # Leer y cargar el contenido JSON
            data = json.load(file)
        print(f"Loaded {len(data)} games.")  # Mensaje de depuración
        return data
    except FileNotFoundError:
        print(f"Error: El archivo {GAMES_LIST_ENDPOINT} no se encuentra.")
        return None
    except json.JSONDecodeError:
        print(f"Error: El archivo {GAMES_LIST_ENDPOINT} no contiene un JSON válido.")
        return None

# Función para obtener información del juego y progreso del usuario
def get_game_info_and_progress(game_id):
    response = requests.get(GAME_INFO_ENDPOINT, params={
        "g": game_id,
        "u": USER,
        "z": API_USERNAME,
        "y": API_KEY
    })
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error al obtener información del juego: {response.status_code}")
        return None

# Función principal
def main():
    # Obtener lista de juegos
    games = get_games()
    if not games:
        return

    # Buscar juego por MD5
    game_id = None
    for game in games:
        hashes = game.get("Hashes", [])
        if isinstance(hashes, list) and md5_to_find in hashes:
            game_id = game.get("ID")
            break

    if game_id:
        # Obtener datos del juego y progreso del usuario
        game_data = get_game_info_and_progress(game_id)
        if game_data:
            # Imprimir JSON en formato válido
            print(json.dumps(game_data, ensure_ascii=False, indent=4))
    else:
        print("Hash MD5 no encontrado en la lista de juegos.")

# Ejecutar script
if __name__ == "__main__":
    main()
