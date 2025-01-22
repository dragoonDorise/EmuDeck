import os
import json
import subprocess
import requests
import zipfile
from io import BytesIO
import sys
import re
from vars import home_dir, msg_file
from utils import getSettings, log_message

settings = getSettings()
storage_path = os.path.expandvars(settings["storagePath"])

def download_and_extract(output_dir):
    # Fixed path to the JSON file
    json_file_path = os.path.join(storage_path, "retrolibrary/cache/missing_systems.json")

    # Check if the JSON file exists
    if not os.path.exists(json_file_path):
        log_message(f"JSON file not found: {json_file_path}")
        print(f"JSON file not found: {json_file_path}")
        return

    # Read the JSON
    with open(json_file_path, 'r') as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            log_message(f"Error reading JSON file: {e}")
            print(f"Error reading JSON file: {e}")
            return

    # Verify that the JSON contains a list
    if not isinstance(data, list):
        log_message("The JSON file does not contain a valid list.")
        print("The JSON file does not contain a valid list.")
        return

    if not data:
        log_message("No platforms found in the JSON file.")
        print("No platforms found in the JSON file.")
        return

    # Process each platform
    for platform in data:
        extracted_folder = os.path.join(output_dir, platform)
        if os.path.exists(extracted_folder):
            num_files = len([f for f in os.listdir(extracted_folder) if os.path.isfile(os.path.join(extracted_folder, f))])
            if num_files >= 3:
                log_message(f"Skipped: {platform} already extracted at {extracted_folder} with {num_files} files.")
                print(f"Skipped: {platform} already extracted at {extracted_folder} with {num_files} files.")
                continue

        url = f"https://bot.emudeck.com/artwork_deck/{platform}.zip"
        log_message(f"Downloading: {platform}")
        print(f"Downloading: {platform}")

        try:
            # Download the ZIP file
            response = requests.get(url, stream=True)
            response.raise_for_status()  # Raise an error if the download fails

            # Read the ZIP content in memory
            with zipfile.ZipFile(BytesIO(response.content)) as zip_file:
                print(f"Extracting content from {platform}.zip to {output_dir}")
                zip_file.extractall(output_dir)  # Overwrite by default

            log_message(f"Extracted: {platform} to {output_dir}")
            print(f"Extracted: {platform} to {output_dir}")

        except requests.exceptions.RequestException as e:
            log_message(f"Error downloading {platform}: {e}")
            print(f"Error downloading {url}: {e}")
        except zipfile.BadZipFile as e:
            log_message(f"Error processing the ZIP file for {platform}: {e}")
            print(f"Error processing the ZIP file for {platform}: {e}")

    print("Process completed.")

# Verify command-line arguments
if len(sys.argv) != 2:
    print("Usage: python3 download_and_extract.py <destination_path>")
    sys.exit(1)

# Output directory passed as an argument
output_dir = sys.argv[1]

# Create the output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

log_message("Starting download and extraction process for bundles...")
download_and_extract(output_dir)
log_message("Download and extraction process completed for bundles.")
