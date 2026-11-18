from core.all import *

def store_install_game(system,name,url,cover_url="",screenshot_url=""):
    name_cleaned=rl_clean_name(name)
    rom_dest = roms_path / system
    rom_dest.mkdir(parents=True, exist_ok=True)

    try:
        r1 = requests.get(url, stream=True, timeout=30)
        r1.raise_for_status()
        with open(rom_dest / f"{name}.zip", "wb") as f:
            for chunk in r1.iter_content(8192):
                f.write(chunk)
    except Exception as e:
        print(f"Error downloading {name}: {e}")
        return False

    for media, media_url in (("box2dfront", cover_url), ("screenshot", screenshot_url)):
        if not media_url:
            continue
        dest = storage_path / "retrolibrary" / "artwork" / system / "media" / media
        dest.mkdir(parents=True, exist_ok=True)
        try:
            r = requests.get(media_url, stream=True, timeout=30)
            r.raise_for_status()
            with open(dest / f"{name_cleaned}.jpg", "wb") as f:
                for chunk in r.iter_content(8192):
                    f.write(chunk)
        except Exception as e:
            print(f"No {media} for {name}: {e}")

    return True

def store_uninstall_game(system,name,url=""):
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


def store_is_game_installed(system: str, name: str, url: str = "") -> bool:
    game_file = roms_path / system / f"{name}.zip"
    return game_file.is_file()