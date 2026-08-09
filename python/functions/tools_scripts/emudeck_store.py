from core.all import *

def store_install_game(system,name,url):
    name_cleaned=rl_clean_name(name)
    rom_dest = roms_path / system
    ss_dest = storage_path / "retrolibrary" / "artwork" / system / "media" / "screenshot"
    bf_dest = storage_path / "retrolibrary" / "artwork" / system / "media" / "box2dfront"
    for d in (rom_dest, ss_dest, bf_dest):
        d.mkdir(parents=True, exist_ok=True)

    # name_cleaned: strip non-alphanumeric (to match your bash)
    name_cleaned = "".join(ch for ch in name if ch.isalnum())

    # 1) download ZIP
    try:
        r1 = requests.get(url, stream=True, timeout=30)
        r1.raise_for_status()
        zip_path = rom_dest / f"{name}.zip"
        with open(zip_path, "wb") as f:
            for chunk in r1.iter_content(8192):
                f.write(chunk)

        # 2) screenshot
        ss_url = (
            f"https://f005.backblazeb2.com/file/emudeck-artwork/"
            f"{system}/media/screenshot/{name}.png"
        )
        r2 = requests.get(ss_url, stream=True, timeout=30)
        r2.raise_for_status()
        with open(ss_dest / f"{name_cleaned}.jpg", "wb") as f:
            for chunk in r2.iter_content(8192):
                f.write(chunk)

        # 3) box2dfront
        bf_url = (
            f"https://f005.backblazeb2.com/file/emudeck-artwork/"
            f"{system}/media/box2dfront/{name}.png"
        )
        r3 = requests.get(bf_url, stream=True, timeout=30)
        r3.raise_for_status()
        with open(bf_dest / f"{name_cleaned}.jpg", "wb") as f:
            for chunk in r3.iter_content(8192):
                f.write(chunk)

        return True

    except Exception as e:
        # you could log e here
        return False

def store_uninstall_game(system,name,url):
    name_cleaned=rl_clean_name(name)
    paths = [
        roms_path / system / f"{name}.zip",
        storage_path / "retrolibrary" / "artwork" / system / "media" / "screenshot" / f"{name_cleaned}.jpg",
        storage_path / "retrolibrary" / "artwork" / system / "media" / "box2dfront" / f"{name_cleaned}.jpg",
    ]

    try:
        for p in paths:
            if p.exists() or p.is_symlink():
                # rmtree if it's a directory, else unlink
                if p.is_dir():
                    import shutil
                    shutil.rmtree(p)
                else:
                    p.unlink()
        return True
    except Exception:
        return False
    return True


def store_is_game_installed(system: str, name: str, url: str) -> bool:
    game_file = roms_path / system / f"{name}.zip"
    return game_file.is_file()