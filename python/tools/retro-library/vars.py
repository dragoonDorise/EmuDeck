import os

home_dir = os.environ.get("HOME")
msg_file = os.path.join(home_dir, ".config/EmuDeck/logs/msg.log")

if os.name == 'nt':
    home_dir = os.environ.get("USERPROFILE")
    msg_file = os.path.join(home_dir, 'AppData', 'Roaming', 'EmuDeck', 'logs/msg.log')

excluded_systems = ["/model2", "/genesiswide", "/mame", "/emulators", "/desktop", "/sneswide"]
