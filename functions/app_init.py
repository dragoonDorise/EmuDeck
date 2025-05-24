from core.all import *

def init_sync_launchers() -> None:
    launchers_dir = tools_path / "launchers"
    unix_dir      = emudeck_backend / "tools" / "launchers" / "unix"

    if not launchers_dir.is_dir():
        print(f"❌ Launchers directory not found: {launchers_dir}", file=sys.stderr)
        return

    if not unix_dir.is_dir():
        print(f"❌ Backend unix-dir not found: {unix_dir}", file=sys.stderr)
        return

    for sh_path in launchers_dir.rglob("*.sh"):
        rel = sh_path.relative_to(launchers_dir)
        src = unix_dir / rel
        if src.exists():
            try:
                shutil.copy2(src, sh_path)
                print(f"✔️  Synced {rel}")
            except Exception as e:
                print(f"❌ Failed to copy {src} → {sh_path}: {e}", file=sys.stderr)
        else:
            print(f"⚠️  No backend file for {rel}; skipping")

def app_init():
    if system == "linux":
        init_sync_launchers()
