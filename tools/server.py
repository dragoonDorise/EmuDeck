import http.server
import os
import socket
import re
import json
import subprocess
import threading
import tkinter as tk
import asyncio
from multipart import MultipartParser

roms_path = None
BASE_DIR = None

async def getSettings():
    global roms_path
    pattern = re.compile(r'([A-Za-z_][A-Za-z0-9_]*)=(.*)')
    user_home = os.path.expanduser("~")
    config_file_path = os.path.join(user_home, 'emudeck', 'settings.sh')
    configuration = {}

    with open(config_file_path, 'r') as file:
        for line in file:
            match = pattern.search(line)
            if match:
                variable = match.group(1)
                value = match.group(2).strip().replace('"', '')
                configuration[variable] = value
                if variable == "romsPath":
                    roms_path = value

    bash_command = "cd $HOME/.config/EmuDeck/backend/ && git rev-parse --abbrev-ref HEAD"
    result = subprocess.run(bash_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    configuration["branch"] = result.stdout.strip()

    json_configuration = json.dumps(configuration, indent=4)
    return json_configuration

class SimpleHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/upload':
            # Parse multipart form data using python-multipart library
            content_type = self.headers.get('Content-Type', '')
            content_length = int(self.headers.get('Content-Length', 0))

            folder = None
            uploaded_files = []

            def on_field(field):
                nonlocal folder
                if field.field_name == b'folder':
                    folder = field.value.decode('utf-8')

            def on_file(file):
                if file.field_name == b'files':
                    uploaded_files.append({
                        'filename': file.file_name.decode('utf-8') if file.file_name else None,
                        'content': file.file_object.read()
                    })

            parser = MultipartParser(self.rfile, content_type, content_length=content_length)
            parser.register_on_field(on_field)
            parser.register_on_file(on_file)
            parser.parse()

            if folder and uploaded_files:
                upload_folder = os.path.join(BASE_DIR, folder)
                os.makedirs(upload_folder, exist_ok=True)

                for file_item in uploaded_files:
                    if file_item['filename']:
                        file_path = os.path.join(upload_folder, os.path.basename(file_item['filename']))
                        with open(file_path, 'wb') as output_file:
                            output_file.write(file_item['content'])

                self.send_response(200)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.wfile.write(b'Files uploaded successfully')
            else:
                self.send_response(400)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.wfile.write(b'Error: Invalid form data')
        else:
            self.send_response(404)
            self.end_headers()

    def do_GET(self):
        if self.path == '/':
            self.path = 'index.html'
        return http.server.SimpleHTTPRequestHandler.do_GET(self)

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.254.254.254', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

def start_server(ip, port):
    home_config_dir = os.path.expanduser("~/.config/EmuDeck/backend/tools")
    os.chdir(home_config_dir)  # Cambiar el directorio de trabajo
    http.server.test(HandlerClass=SimpleHTTPRequestHandler, port=port, bind=ip)

def show_custom_popup(title, message, button_text):
    popup = tk.Tk()
    popup.title(title)
    label = tk.Label(popup, text=message, padx=20, pady=20, wraplength=400)
    label.pack()
    button = tk.Button(popup, text=button_text, command=popup.destroy, padx=20, pady=10)
    button.pack(pady=(0, 10))
    popup.update_idletasks()
    popup.lift()
    popup.focus_force()
    popup.mainloop()

async def main():
    global BASE_DIR
    await getSettings()
    BASE_DIR = roms_path

    ip = get_local_ip()
    port = 8000

    server_thread = threading.Thread(target=start_server, args=(ip, port))
    server_thread.daemon = True
    server_thread.start()

    # Show server info dialog
    show_custom_popup("Server loaded", f"Open http://{ip}:{port}/ in your computer's browser. Close this window when you are finished", "Close")

asyncio.run(main())
