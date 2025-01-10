import json
import requests
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
import subprocess

# Define the log file path
if os.name == 'nt':
    home_dir = os.environ.get("USERPROFILE")
    msg_file = os.path.join(home_dir, 'AppData', 'Roaming', 'EmuDeck', "logs/msg.log")
else:
    home_dir = os.environ.get("HOME")
    msg_file = os.path.join(home_dir, ".config/EmuDeck/logs/msg.log")

def getSettings():
    pattern = re.compile(r'([A-Za-z_][A-Za-z0-9_]*)=(.*)')
    user_home = os.path.expanduser("~")

    if os.name == 'nt':
        config_file_path = os.path.join(user_home, 'AppData', 'Roaming', 'EmuDeck', 'settings.ps1')
    else:
        config_file_path = os.path.join(user_home, 'emudeck', 'settings.sh')

    configuration = {}

    with open(config_file_path, 'r') as file:
        for line in file:
            match = pattern.search(line)
            if match:
                variable = match.group(1)
                value = match.group(2).strip().strip('"')
                expanded_value = os.path.expandvars(value.replace('"', '').replace("'", ""))
                configuration[variable] = expanded_value

    # Obtener rama actual del repositorio backend
    if os.name == 'nt':
        bash_command = f"cd {os.path.join(user_home, 'AppData', 'Roaming', 'EmuDeck', 'backend')} && git rev-parse --abbrev-ref HEAD"
    else:
        bash_command = "cd $HOME/.config/EmuDeck/backend/ && git rev-parse --abbrev-ref HEAD"

    result = subprocess.run(bash_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    configuration["branch"] = result.stdout.strip()

    configuration["systemOS"] = os.name

    return configuration

settings = getSettings()
storage_path = os.path.expandvars(settings["storagePath"])

# Path for the JSON and target folder from command-line arguments
save_folder = sys.argv[1]
json_path = os.path.join(storage_path, "retrolibrary/cache/missing_artwork_no_hash.json")


# Function to write messages to the log file
def log_message(message):
    with open(msg_file, "a") as log_file:  # "a" to append messages without overwriting
        log_file.write(message + "\n")

def create_empty_image(name, platform, save_folder, type):
    extension = "jpg" if type != "wheel" else "png"
    folder_path = os.path.join(save_folder, platform, "media", type)
    os.makedirs(folder_path, exist_ok=True)
    img_path = os.path.join(folder_path, f"{name}.{extension}")
    with open(img_path, 'wb') as file:
        pass
    log_message(f"Empty file created: {img_path}")
    print(f"Empty file created: {img_path}")

def download_image(name, platform, img_url, save_folder, type):
    extension = "jpg" if type != "wheel" else "png"
    folder_path = os.path.join(save_folder, platform, "media", type)
    os.makedirs(folder_path, exist_ok=True)
    img_path = os.path.join(folder_path, f"{name}.{extension}")
    try:
        response = requests.get(img_url, timeout=10)
        response.raise_for_status()  # Raise an exception for HTTP error codes
        with open(img_path, 'wb') as file:
            file.write(response.content)
        log_message(f"Image saved: {img_path}")
        print(f"Image saved: {img_path}")
    except requests.RequestException as e:
        log_message(f"Error downloading image for {platform}/{name}: {e}")
        print(f"Error downloading image for {platform}/{name}: {e}")
        #create_empty_image(name, platform, save_folder, type)

def fetch_image_data(game):
    name = game['name']
    platform = game['platform']
    type = game['type']
    url = f"https://bot.emudeck.com/steamdbimg.php?name={name}&platform={platform}&type={type}"
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raise an exception for HTTP error codes
        data = response.json()
        img_url = data.get('img')
        if img_url:
            download_image(name, platform, img_url, save_folder, type)
        else:
            log_message(f"No URL found for {platform}/{name}. Creating empty file.")
            print(f"No URL found for {platform}/{name}. Creating empty file.")
            #create_empty_image(name, platform, save_folder, type)
    except requests.RequestException as e:
        log_message(f"Error processing {platform}/{name}: {e}")
        print(f"Error processing {platform}/{name}: {e}")
        #create_empty_image(name, platform, save_folder, type)

def process_json(save_folder):
    # Read the original JSON
    with open(json_path, 'r') as file:
        systems = json.load(file)

    games = []
    for system in systems:
        games.extend(system.get('games', []))  # Añade todos los juegos del sistema a la lista

    log_message(f"Starting processing for {len(games)} games...")
    print(f"Starting processing for {len(games)} games...")

    # Use ThreadPoolExecutor for parallel downloading
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(fetch_image_data, game) for game in games]
        for future in as_completed(futures):
            try:
                future.result()  # Process exceptions raised in tasks
            except Exception as e:
                log_message(f"Error in a task: {e}")
                print(f"Error in a task: {e}")

    log_message("Processing completed.")
    print("Processing completed.")


if __name__ == "__main__":
    log_message("Starting image processing script...")
    process_json(save_folder)
    log_message("Image processing script completed.")
