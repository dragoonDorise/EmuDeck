#!/usr/bin/env python3

import json
import os
import platform
import re
import shutil
import socket
import subprocess
import sys

system = platform.system().lower()

emulationPath = os.environ.get("emulationPath")
ESDEscrapData = os.environ.get("ESDEscrapData")

PERCENT_RE = re.compile(r"(\d+)%")

WINDOWS_NESTED_ROMS = ("wiiu", "xbox360")
KEEP_AT_SYSTEM_LEVEL = ("media", "xbla")

#OK
def log_to_frontend(payload):
    port = int(os.environ.get("EMUDECK_BACKEND_PORT") or 8099)    
    with socket.create_connection(("127.0.0.1", port), timeout=2) as sock:
        sock.sendall((payload.replace("\r", "").replace("\n", "") + "\n").encode("utf-8"))

#OK
def check_free_space(origin, destination, label):
    log_to_frontend(json.dumps({"key": "importExport.calculatingSize", "params": {"item": label},
                              "percentage": 0, "finished": False}))

    neededSpace = 0
    for dirpath, _dirnames, filenames in os.walk(origin):
        for filename in filenames:
            neededSpace += os.lstat(os.path.join(dirpath, filename)).st_size


    freeSpace = shutil.disk_usage(destination).free

    if freeSpace < neededSpace:
        log_to_frontend(json.dumps({"key": "importExport.noSpace",
                                  "params": {"item": label, "destination": destination},
                                  "percentage": 100, "finished": True}))
        return 1

    return 0

#OK
def get_external_drives():
    if system.startswith("win"):
        import ctypes
        import string

        drives = []
        mask = ctypes.windll.kernel32.GetLogicalDrives()
        for index, letter in enumerate(string.ascii_uppercase):
            if mask >> index & 1:
                drives.append(letter + ":\\")
        return sorted(set(drives))

    user = os.environ.get("USER") or os.environ.get("USERNAME") or ""
    mounts = ["/run/media/" + user, "/run/media", "/media/" + user, "/media", "/mnt", "/Volumes"]

    drives = []
    for mount in mounts:
        if not os.path.isdir(mount):
            continue
        try:
            entries = os.listdir(mount)
        except OSError:
            continue
        for entry in entries:
            path = os.path.join(mount, entry)
            if os.path.isdir(path) and not os.path.islink(path):
                drives.append(path)
    return sorted(set(drives))

#OK
def get_locations():
    entries = []

    for mount in get_external_drives():
        if system.startswith("win"):
            import ctypes

            driveType = ctypes.windll.kernel32.GetDriveTypeW(ctypes.c_wchar_p(mount))
            if driveType not in (2, 3, 4):
                continue
            buffer = ctypes.create_unicode_buffer(261)
            ctypes.windll.kernel32.GetVolumeInformationW(
                ctypes.c_wchar_p(mount), buffer, len(buffer), None, None, None, None, 0)
            label = (buffer.value or "").strip() or "No label"
            if driveType == 2:
                name, driveKind = "SD Card", "External"
            else:
                name = label
                driveKind = "Internal" if driveType == 3 else "External"
        elif system == "darwin":
            label = os.path.basename(mount) or "No label"
            name = label
            driveKind = "Internal" if mount == "/" else "External"
        else:
            source = subprocess.run(["findmnt", "-no", "SOURCE", mount],
                                    capture_output=True, text=True).stdout.split("\n")[0].strip()
            label = subprocess.run(["lsblk", "-no", "LABEL", source],
                                   capture_output=True, text=True).stdout.split("\n")[0].strip()
            removable = subprocess.run(["lsblk", "-no", "RM", source],
                                       capture_output=True, text=True).stdout.split("\n")[0].strip()
            if not label:
                label = "No name"
            if "mmcblk" in source:
                name, driveKind = "SD Card", "External"
            else:
                name = label
                driveKind = "External" if removable == "1" else "Internal"

        entries.append({"letter": mount, "name": name, "label": label, "type": driveKind})

    if not entries:
        if system == "darwin":
            home = os.path.expanduser("~")
            entries.append({"letter": home, "name": "User folder",
                            "label": "User folder", "type": "Internal"})
        else:
            entries = []
    sys.stdout.write(json.dumps(entries) + "\n")
    return 0

# testar windows
def copy_with_robocopy(action, item, origin, destination, rsyncParams):
    excludes = []
    for param in rsyncParams.split():
        if param.startswith("--exclude="):
            excludes.append(param.split("=", 1)[1])

    total = 0
    for _dirpath, _dirnames, filenames in os.walk(origin):
        total += len(filenames)

    command = ["robocopy", origin.rstrip("\\/"), destination.rstrip("\\/"),
               "/S", "/NJH", "/NJS", "/NDL", "/NC", "/NS", "/NP", "/R:1", "/W:1"]
    if excludes:
        command.append("/XF")
        command.extend(excludes)

    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    copied = 0
    last = 0
    for raw in process.stdout:
        if not raw.strip():
            continue
        copied += 1
        percent = 100 if total <= 0 else min(int(copied * 100 / total), 100)
        if percent == last:
            continue
        last = percent
        log_to_frontend(json.dumps({"key": "importExport." + action, "params": {"item": item},
                                  "percentage": percent, "finished": False}))
    process.stdout.close()
    status = process.wait()
    return 0 if status < 8 else status

#OK
def copy_with_rsync(action, item, origin, destination, rsyncParams):
    command = ["rsync", "-a", "-m", "--info=progress2", "--no-inc-recursive"]
    command.extend(rsyncParams.split())
    command.append(origin.rstrip(os.sep) + os.sep)
    command.append(destination.rstrip(os.sep) + os.sep)

    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    last = 0
    buffer = ""
    while True:
        chunk = process.stdout.read(256)
        if not chunk:
            break
        buffer += chunk.decode("utf-8", "replace")
        lines = re.split(r"[\r\n]", buffer)
        buffer = lines.pop()
        for line in lines:
            found = PERCENT_RE.search(line)
            if not found:
                continue
            percent = min(int(found.group(1)), 100)
            if percent == last:
                continue
            last = percent
            log_to_frontend(json.dumps({"key": "importExport." + action, "params": {"item": item},
                                      "percentage": percent, "finished": False}))
    process.stdout.close()
    return process.wait()

# Revisar lo q devuelve
def rsync_progress(action, item, origin, destination, rsyncParams=""):
    try:
        os.makedirs(destination, exist_ok=True)
    except OSError as error:
        log_to_frontend(json.dumps({"key": "importExport.failed",
                                  "params": {"item": item, "code": error.errno},
                                  "percentage": 100, "finished": False}))
        return error.errno or 1

    log_to_frontend(json.dumps({"key": "importExport." + action, "params": {"item": item},
                              "percentage": 0, "finished": False}))

    if system.startswith("win"):
        status = copy_with_robocopy(action, item, origin, destination, rsyncParams)
    else:
        status = copy_with_rsync(action, item, origin, destination, rsyncParams)

    if status != 0:
        log_to_frontend(json.dumps({"key": "importExport.failed",
                                  "params": {"item": item, "code": status},
                                  "percentage": 100, "finished": False}))
        return status

    log_to_frontend(json.dumps({"key": "importExport." + action, "params": {"item": item},
                              "percentage": 100, "finished": False}))
    return 0

def fix_windows_roms_layout(romsPath, nested):
    for name in WINDOWS_NESTED_ROMS:
        systemPath = os.path.join(romsPath, name)
        if not os.path.isdir(systemPath):
            continue

        nestedPath = os.path.join(systemPath, "roms")

        if nested:
            entries = [entry for entry in os.listdir(systemPath)
                       if entry != "roms" and entry not in KEEP_AT_SYSTEM_LEVEL]
            if not entries:
                continue
            os.makedirs(nestedPath, exist_ok=True)
            for entry in entries:
                shutil.move(os.path.join(systemPath, entry), os.path.join(nestedPath, entry))
        else:
            if not os.path.isdir(nestedPath):
                continue
            for entry in os.listdir(nestedPath):
                shutil.move(os.path.join(nestedPath, entry), os.path.join(systemPath, entry))
            os.rmdir(nestedPath)


# Pendiente
def import_emudeck(items, origin):
    failed = 0
    failedItems = []

    if not origin or not os.path.isdir(origin):
        log_to_frontend(json.dumps({"key": "importExport.invalidOrigin",
                                  "params": {"path": origin or ""},
                                  "percentage": 100, "finished": True}))
        return 1

    backup_origin = os.path.join(origin, "EmuDeckBackup")
    if not backup_origin or not os.path.isdir(backup_origin):
        log_to_frontend(json.dumps({"key": "importExport.invalidOrigin",
                                "params": {"path": backup_origin or ""},
                                "percentage": 100, "finished": True}))
        return 1
    
    selected = json.loads(items)

    if not any(selected.values()):
        log_to_frontend(json.dumps({"key": "importExport.nothingSelectedImport", "params": {},
                                  "percentage": 100, "finished": True}))
        return 0

    for item, value in selected.items():
        if value is not True:
            continue
        item = item.lower()
        if item == "saves":
            if check_free_space(os.path.join(backup_origin, "saves"), emulationPath, "saves") != 0:
                return 1
            if rsync_progress("importing", "saves",
                              os.path.join(backup_origin, "saves"),
                              os.path.join(emulationPath, "saves")) != 0:
                failed = 1
                failedItems.append("saves")
        elif item == "storage":
            if check_free_space(os.path.join(backup_origin, "storage"), emulationPath, "storage") != 0:
                return 1
            if rsync_progress("importing", "storage",
                              os.path.join(backup_origin, "storage"),
                              os.path.join(emulationPath, "storage")) != 0:
                failed = 1
                failedItems.append("storage")
        elif item in ("esdeartwork", "esdemedia", "es-de media"):
            if check_free_space(os.path.join(backup_origin, "tools", "downloaded_media"), emulationPath, "esdeArtwork") != 0:
                return 1
            if rsync_progress("importing", "esdeArtwork",
                              os.path.join(backup_origin, "tools", "downloaded_media"),
                              ESDEscrapData) != 0:
                failed = 1
                failedItems.append("esdeArtwork")
        elif item == "bios":
            if check_free_space(os.path.join(backup_origin, "bios"), emulationPath, "bios") != 0:
                return 1
            if rsync_progress("importing", "bios",
                              os.path.join(backup_origin, "bios"),
                              os.path.join(emulationPath, "bios")) != 0:
                failed = 1
                failedItems.append("bios")
        elif item == "roms":
            if check_free_space(os.path.join(backup_origin, "roms"), emulationPath, "roms") != 0:
                return 1
            if rsync_progress("importing", "roms",
                              os.path.join(backup_origin, "roms"),
                              os.path.join(emulationPath, "roms"),
                              "--exclude=*.txt") != 0:
                failed = 1
                failedItems.append("roms")
            elif system.startswith("win"):
                fix_windows_roms_layout(os.path.join(emulationPath, "roms"), False)

    if failed == 0:
        log_to_frontend(json.dumps({"key": "importExport.importFinished", "params": {},
                                  "percentage": 100, "finished": True}))
    else:
        log_to_frontend(json.dumps({"key": "importExport.importFinishedWithErrors",
                                  "params": {"items": failedItems},
                                  "percentage": 100, "finished": True}))

    return failed


def export_emudeck(items, destination):
    failed = 0
    failedItems = []

    if not destination or not os.path.isdir(destination):
        log_to_frontend(json.dumps({"key": "importExport.invalidDestination",
                                  "params": {"path": destination or ""},
                                  "percentage": 100, "finished": True}))
        return 1

    backup_destination = os.path.join(destination, "EmuDeckBackup")
    selected = json.loads(items)

    if not any(selected.values()):
        log_to_frontend(json.dumps({"key": "importExport.nothingSelectedExport", "params": {},
                                  "percentage": 100, "finished": True}))
        return 0

    for item, value in selected.items():
        if value is not True:
            continue
        item = item.lower()
        if item == "saves":
            if check_free_space(os.path.join(emulationPath, "saves"), destination, "saves") != 0:
                return 1
            if rsync_progress("exporting", "saves",
                              os.path.join(emulationPath, "saves"),
                              os.path.join(backup_destination, "saves"), "-L") != 0:
                failed = 1
                failedItems.append("saves")
        elif item == "storage":
            if check_free_space(os.path.join(emulationPath, "storage"), destination, "storage") != 0:
                return 1
            if rsync_progress("exporting", "storage",
                              os.path.join(emulationPath, "storage"),
                              os.path.join(backup_destination, "storage"), "-L") != 0:
                failed = 1
                failedItems.append("storage")
        elif item in ("esdeartwork", "esdemedia", "es-de media"):
            if check_free_space(ESDEscrapData, destination, "esdeArtwork") != 0:
                return 1
            if rsync_progress("exporting", "esdeArtwork", ESDEscrapData,
                              os.path.join(backup_destination, "tools", "downloaded_media"), "-L") != 0:
                failed = 1
                failedItems.append("esdeArtwork")
        elif item == "bios":
            if check_free_space(os.path.join(emulationPath, "bios"), destination, "bios") != 0:
                return 1
            if rsync_progress("exporting", "bios",
                              os.path.join(emulationPath, "bios"),
                              os.path.join(backup_destination, "bios"), "-L") != 0:
                failed = 1
                failedItems.append("bios")
        elif item == "roms":
            if check_free_space(os.path.join(emulationPath, "roms"), destination, "roms") != 0:
                return 1
            if rsync_progress("exporting", "roms",
                              os.path.join(emulationPath, "roms"),
                              os.path.join(backup_destination, "roms"), "-L --exclude=*.txt") != 0:
                failed = 1
                failedItems.append("roms")
            elif system.startswith("win"):
                fix_windows_roms_layout(os.path.join(backup_destination, "roms"), True)

    if failed == 0:
        log_to_frontend(json.dumps({"key": "importExport.exportFinished", "params": {},
                                  "percentage": 100, "finished": True}))
    else:
        log_to_frontend(json.dumps({"key": "importExport.exportFinishedWithErrors",
                                  "params": {"items": failedItems},
                                  "percentage": 100, "finished": True}))

    return failed


if __name__ == "__main__":
    functions = {
        "import_emudeck": import_emudeck,
        "export_emudeck": export_emudeck,
        "get_locations": get_locations,
    }
    if len(sys.argv) < 2 or sys.argv[1] not in functions:
        sys.stderr.write("usage: importExport.py {%s} [args]\n" % "|".join(functions))
        sys.exit(2)

    try:
        sys.exit(functions[sys.argv[1]](*sys.argv[2:]))
    except SystemExit:
        raise
    except BaseException as error:
        log_to_frontend(json.dumps({"key": "importExport.unexpectedError",
                                  "params": {"error": "%s: %s" % (type(error).__name__, error)},
                                  "percentage": 100, "finished": True}))
        raise
