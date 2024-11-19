import requests
import sys

# Credenciales y usuario
API_USERNAME = "dragoonDorise"
API_KEY = "mvLqoKB3JmbXrezCd7LIXzMnV42ApWzj"
USER = sys.argv[1]
md5_to_find = sys.argv[2]

# Endpoints
BASE_URL = "https://retroachievements.org/API/"
GAMES_LIST_ENDPOINT = f"{BASE_URL}API_GetGameList.php"
GAME_INFO_ENDPOINT = f"{BASE_URL}API_GetGameInfoAndUserProgress.php"

# Función para obtener la lista de juegos del sistema
def get_games(system_id=1):
    response = requests.get(GAMES_LIST_ENDPOINT, params={
        "i": system_id,
        "h": 1,
        "f": 1,
        "z": API_USERNAME,
        "y": API_KEY
    })
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error al obtener los juegos: {response.status_code}")
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
        if md5_to_find in hashes:
            game_id = game.get("ID")
            print(f"Juego encontrado: {game['Title']} (ID: {game_id})")
            break

    if game_id:
        # Obtener datos del juego y progreso del usuario
        game_data = get_game_info_and_progress(game_id)
        if game_data:
            print("Datos del juego y progreso del usuario:")
            print(game_data)
    else:
        print("Hash MD5 no encontrado en la lista de juegos.")

# Ejecutar script
if __name__ == "__main__":
    main()
