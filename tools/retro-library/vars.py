import os
if os.name == 'nt':
    home_dir = os.environ.get("USERPROFILE")
    msg_file = os.path.join(home_dir, 'AppData', 'Roaming', 'EmuDeck', 'logs/msg.log')
else:
    home_dir = os.environ.get("HOME")
    msg_file = os.path.join(home_dir, ".config/EmuDeck/logs/msg.log")
