import http.server
import cgi
import os
import socket
import re
import json
import subprocess
import threading
import tkinter as tk
from tkinter import messagebox
import asyncio

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
            form = cgi.FieldStorage(fp=self.rfile, headers=self.headers, environ={'REQUEST_METHOD': 'POST'})
            folder = form.getvalue('folder')
            files = form['files']

            upload_folder = os.path.join(BASE_DIR, folder)
            os.makedirs(upload_folder, exist_ok=True)

            if not isinstance(files, list):
                files = [files]

            for file_item in files:
                if file_item.filename:
                    file_path = os.path.join(upload_folder, os.path.basename(file_item.filename))
                    with open(file_path, 'wb') as output_file:
                        output_file.write(file_item.file.read())

            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'Archivos subidos exitosamente')
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
    popup.wm_title(title)
    label = tk.Label(popup, text=message, padx=20, pady=20)
    label.pack(side="top", fill="x")
    button = tk.Button(popup, text=button_text, command=popup.destroy, padx=10, pady=15)
    button.pack()
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

    # Mostrar el mensaje en el popup personalizado
    show_custom_popup("Server loaded", f"Open http://{ip}:{port}/ in your computer's browser. Close this window when you are finished", "Close")

asyncio.run(main())
