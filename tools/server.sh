#!/usr/bin/env bash
venv_python="$HOME/.config/EmuDeck/python_virtual_env/bin/python"
if ! "$venv_python" -c "import python_multipart" &> /dev/null; then
	. "$HOME/.config/EmuDeck/backend/functions/all.sh"
	generate_pythonEnv &> /dev/null
fi
"$venv_python" "$HOME/.config/EmuDeck/backend/tools/server.py"
