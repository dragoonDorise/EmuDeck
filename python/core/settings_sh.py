import json, re, shlex
from pathlib import Path

_MAPPING_RE = re.compile(r'setSetting\s+(\w+)\s+"?\$\(jq\s+(\.[\w.\[\]]+)\s+"?\$json"?\)"?')
_LINE_RE = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$')
_PATH_RE = re.compile(r'([^.\[\]]+)|\[(\d+)\]')


def parse_settings_sh(path: Path) -> dict:
    """Reads settings.sh into a dict of bash variable -> python value."""
    values = {}
    if not path.exists():
        return values
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = _LINE_RE.match(line)
        if not match:
            continue
        key, raw = match.groups()
        try:
            parts = shlex.split(raw, posix=True)
            value = " ".join(parts) if parts else ""
        except ValueError:
            value = raw.strip()
        values[key] = _convert(value)
    return values


def _convert(value: str):
    """Converts bash literals to python types (true/false/null/ints)."""
    if value == "true":
        return True
    if value == "false":
        return False
    if value == "null":
        return None
    if re.fullmatch(r"-?\d+", value):
        return int(value)
    return value


def load_mapping(json_to_bash_vars: Path) -> dict:
    """Returns bash variable -> json path tokens, read from jsonToBashVars.sh."""
    mapping = {}
    if not json_to_bash_vars.exists():
        return mapping
    for var, jq_path in _MAPPING_RE.findall(json_to_bash_vars.read_text(encoding="utf-8")):
        tokens = [int(idx) if idx else name for name, idx in _PATH_RE.findall(jq_path)]
        if tokens:
            mapping.setdefault(var, tokens)
    return mapping


def _set_path(data: dict, tokens: list, value) -> None:
    """Sets value inside nested dicts/lists following the path tokens."""
    node = data
    for i, token in enumerate(tokens):
        last = i == len(tokens) - 1
        next_is_index = not last and isinstance(tokens[i + 1], int)
        if isinstance(token, int):
            if not isinstance(node, list):
                return
            while len(node) <= token:
                node.append(None)
            if last:
                node[token] = value
                return
            if not isinstance(node[token], (dict, list)):
                node[token] = [] if next_is_index else {}
            node = node[token]
        else:
            if last:
                node[token] = value
                return
            if not isinstance(node.get(token), (dict, list)):
                node[token] = [] if next_is_index else {}
            node = node[token]


def overlay_settings_sh(data: dict, settings_sh: Path, json_to_bash_vars: Path) -> dict:
    """Overlays settings.sh values on top of the settings.json dict."""
    values = parse_settings_sh(settings_sh)
    if not values:
        return data
    mapping = load_mapping(json_to_bash_vars)

    written = set()
    for var, tokens in mapping.items():
        key = tuple(tokens)
        if var in values and key not in written:
            _set_path(data, tokens, values[var])
            written.add(key)

    emulation_path = values.get("emulationPath")
    if isinstance(emulation_path, str) and emulation_path.endswith("/Emulation"):
        data["storagePath"] = emulation_path[: -len("/Emulation")]

    data["sh"] = values
    return data


def _format_value(value) -> str:
    """Formats a python value the way bash setSetting stores it."""
    if value is True:
        return "true"
    if value is False:
        return "false"
    if value is None:
        return "null"
    if isinstance(value, (int, float)):
        return str(value)
    return json.dumps(str(value))


def write_setting_sh(settings_sh: Path, json_to_bash_vars: Path, json_key: str, value) -> bool:
    """Writes a json dotted key into settings.sh using the reverse mapping."""
    tokens = [int(t) if t.isdigit() else t for t in json_key.split(".")]
    variables = [var for var, path in load_mapping(json_to_bash_vars).items() if path == tokens]
    if json_key.startswith("sh."):
        variables = [json_key[3:]]
    if not variables or not settings_sh.exists():
        return False

    lines = settings_sh.read_text(encoding="utf-8").splitlines()
    for var in variables:
        new_line = f"{var}={_format_value(value)}"
        for i, line in enumerate(lines):
            match = _LINE_RE.match(line)
            if match and match.group(1) == var:
                lines[i] = new_line
                break
        else:
            lines.append(new_line)
    settings_sh.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return True
