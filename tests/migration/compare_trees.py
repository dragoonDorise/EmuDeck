import difflib, hashlib, json, os, re, sys
from pathlib import Path

IGNORED = (
    ".config/EmuDeck/logs",
    ".config/EmuDeck/python_virtual_env",
    ".cache",
    "__pycache__",
    ".git/index",
    ".git/logs",
)
INI_SUFFIXES = {".ini", ".cfg", ".conf", ".toml", ".opt", ""}


def ignored(rel: str) -> bool:
    """Tells if a relative path is outside what the comparison cares about."""
    return any(rel == p or rel.startswith(p + "/") or f"/{p}/" in f"/{rel}/" for p in IGNORED)


def scan(root: Path) -> dict:
    """Maps every relative path under root to ('dir'|'file'|'link', detail)."""
    entries = {}
    for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
        for name in dirnames + filenames:
            path = Path(dirpath) / name
            rel = path.relative_to(root).as_posix()
            if ignored(rel):
                continue
            if path.is_symlink():
                entries[rel] = ("link", os.readlink(path).replace(str(root), "$HOME").rstrip("/"))
            elif path.is_dir():
                entries[rel] = ("dir", None)
            else:
                entries[rel] = ("file", path)
    return entries


def normalized(path: Path, root: Path) -> bytes:
    """Reads a file replacing its sandbox HOME by $HOME so both sides are comparable."""
    return path.read_bytes().replace(str(root).encode(), b"$HOME")


def parse_ini(text: str):
    """Parses key=value lines per section, ignoring spacing around '=' and blank or comment lines."""
    data, section = {}, ""
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith(("#", ";")):
            continue
        match = re.fullmatch(r"\[(.+)\]", line)
        if match:
            section = match.group(1)
            continue
        if "=" not in line:
            return None
        key, value = line.split("=", 1)
        data[(section, key.strip())] = value.strip()
    return data


def equivalent(rel: str, a: bytes, b: bytes) -> bool:
    """Tells if two different files hold the same data once formatting is ignored."""
    try:
        ta, tb = a.decode(), b.decode()
    except UnicodeDecodeError:
        return False
    if rel.endswith(".json"):
        try:
            return json.loads(ta) == json.loads(tb)
        except ValueError:
            return False
    if Path(rel).suffix in INI_SUFFIXES:
        ia, ib = parse_ini(ta), parse_ini(tb)
        return ia is not None and ia == ib
    return ta.split() == tb.split()


def show_diff(rel: str, a: bytes, b: bytes) -> None:
    """Prints a short unified diff between the bash and python versions of a file."""
    try:
        la, lb = a.decode().splitlines(), b.decode().splitlines()
    except UnicodeDecodeError:
        print("      (binary file)")
        return
    diff = list(difflib.unified_diff(la, lb, "bash/" + rel, "python/" + rel, lineterm="", n=1))
    for line in diff[:40]:
        print("      " + line)
    if len(diff) > 40:
        print(f"      ... {len(diff) - 40} more lines")


def main() -> int:
    """Compares the bash and python sandboxes and prints a report; exit code 1 if they differ."""
    root_a, root_b = Path(sys.argv[1]), Path(sys.argv[2])
    a, b = scan(root_a), scan(root_b)
    identical, formatted, different, only_a, only_b = [], [], [], [], []

    for rel in sorted(set(a) | set(b)):
        if rel not in b:
            only_a.append(rel)
            continue
        if rel not in a:
            only_b.append(rel)
            continue
        (kind_a, detail_a), (kind_b, detail_b) = a[rel], b[rel]
        if kind_a != kind_b:
            different.append((rel, f"bash is a {kind_a}, python is a {kind_b}", None))
        elif kind_a == "dir":
            identical.append(rel)
        elif kind_a == "link":
            if detail_a == detail_b:
                identical.append(rel)
            else:
                different.append((rel, f"link -> {detail_a} (bash) vs {detail_b} (python)", None))
        elif kind_a == "file":
            data_a, data_b = normalized(detail_a, root_a), normalized(detail_b, root_b)
            if hashlib.sha256(data_a).digest() == hashlib.sha256(data_b).digest():
                identical.append(rel)
            elif equivalent(rel, data_a, data_b):
                formatted.append(rel)
            else:
                different.append((rel, "content differs", (data_a, data_b)))

    print(f"Identical: {len(identical)}  |  Same data, different format: {len(formatted)}  |  "
          f"Different: {len(different)}  |  Only bash: {len(only_a)}  |  Only python: {len(only_b)}")
    for rel in formatted:
        print(f"  ~ {rel}")
    for rel, reason, data in different:
        print(f"  ✗ {rel}: {reason}")
        if data:
            show_diff(rel, *data)
    for rel in only_a:
        print(f"  - {rel}  (only bash)")
    for rel in only_b:
        print(f"  + {rel}  (only python)")
    return 1 if (different or only_a or only_b) else 0


if __name__ == "__main__":
    sys.exit(main())
