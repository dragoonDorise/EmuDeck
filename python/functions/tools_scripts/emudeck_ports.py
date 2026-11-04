from core.all import *

ports_json = emudeck_backend / "ports.json"


def ports_run(action, port_id):
    """Runs <port_id>_<action> from the port's own script."""
    module = importlib.import_module(f"functions.ports_scripts.emudeck_{port_id}")
    return getattr(module, f"{port_id}_{action}")()


def ports_status():
    """Returns installed, available or unavailable for every game in ports.json."""
    status = {}
    for platform in json.loads(ports_json.read_text(encoding="utf-8")):
        for game in platform["games"]:
            port_id = game["id"]
            try:
                if not ports_run("is_available", port_id):
                    status[port_id] = "unavailable"
                elif ports_run("is_installed", port_id):
                    status[port_id] = "installed"
                else:
                    status[port_id] = "available"
            except Exception as error:
                print(f"Port {port_id} error: {error}")
                status[port_id] = "unavailable"
    return status
