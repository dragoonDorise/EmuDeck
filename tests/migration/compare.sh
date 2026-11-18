#!/usr/bin/env bash
set -u

testsDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$testsDir/../.." && pwd)"
target="${1:-}"
ref="${2:-main}"
fn="${target%%:*}"
pyFn=""
if [[ "$target" == *:* ]]; then
	pyFn="${target#*:}"
fi
prepare="${EMUDECK_TEST_PREPARE:-}"

if [ -z "$fn" ]; then
	echo "Usage: $0 <bash_function>[:<python_function>] [legacy_git_ref=main]"
	echo "Runs <bash_function> as it is in <legacy_git_ref> and, in another sandbox HOME, as it is now (or <python_function> through py_run), then compares the files they leave."
	echo "EMUDECK_TEST_PREPARE=<command> runs a legacy bash command in both sandboxes first (for example Eden_init)."
	exit 2
fi

work="$(mktemp -d "${TMPDIR:-/tmp}/$(date +%Y%m%d-%H%M%S)-${target//:/-}-XXXX")"
venv="${EMUDECK_TEST_VENV:-${XDG_CACHE_HOME:-$HOME/.cache}/emudeck-tests/venv}"
export EMUDECK_TEST_STUBLOG="$work/stubs.log"

# Creates the python venv shared by every test run
ensureVenv(){
	if [ -x "$venv/bin/python" ]; then
		return 0
	fi
	echo "Creating test venv in $venv"
	python3 -m venv "$venv" && "$venv/bin/pip" install -q requests vdf screeninfo
}

# Runs TEST_CMD in a sandbox HOME with the backend loaded, system commands stubbed and LEGACY_FILE sourced if set
runIn(){
	local home=$1
	HOME="$home" PATH="$testsDir/stubs:$PATH" emudeckBackend="$repo/" bash -c '
		. "$emudeckBackend/functions/all.sh" >/dev/null 2>&1
		if [ -n "${LEGACY_FILE:-}" ]; then
			. "$LEGACY_FILE"
		fi
		eval "$TEST_CMD"
	'
}

# Creates a sandbox HOME with the fixture settings.json and the settings.sh bash generates from it
makeHome(){
	local home=$1
	mkdir -p "$home/.config/EmuDeck/logs" "$home/Applications" "$home/Desktop" "$home/.local/share/applications"
	cp "$testsDir/fixtures/settings.json" "$home/.config/EmuDeck/settings.json"
	cp -a "$testsDir/fixtures/home/." "$home/"
	ln -s "$venv" "$home/.config/EmuDeck/python_virtual_env"
	TEST_CMD='jsonToBashVars "$emudeckFolder/settings.json"' LEGACY_FILE="" runIn "$home" >/dev/null 2>&1
}

defFile="$(grep -rlE "^(function +)?${fn} *\(\)" "$repo/functions" | head -n1)"
if [ -z "$defFile" ]; then
	echo "Function $fn not found in $repo/functions"
	exit 2
fi
relFile="${defFile#$repo/}"
if ! git -C "$repo" show "$ref:$relFile" > "$work/legacy.sh" 2>/dev/null; then
	echo "$relFile does not exist in $ref"
	exit 2
fi

ensureVenv || exit 2
makeHome "$work/bash"
makeHome "$work/python"

if [ -n "$prepare" ]; then
	echo "Preparing both sandboxes with: $prepare"
	for side in bash python; do
		TEST_CMD="$prepare" LEGACY_FILE="$work/legacy.sh" runIn "$work/$side" > "$work/prepare-$side.log" 2>&1
	done
fi

echo "Running $fn from $ref ($relFile)..."
TEST_CMD="$fn" LEGACY_FILE="$work/legacy.sh" runIn "$work/bash" > "$work/bash.log" 2>&1
echo "  exit code: $?"
if [ -n "$pyFn" ]; then
	echo "Running $pyFn through py_run..."
	TEST_CMD="py_run $pyFn" LEGACY_FILE="" runIn "$work/python" > "$work/python.log" 2>&1
else
	echo "Running $fn from the working tree..."
	TEST_CMD="$fn" LEGACY_FILE="" runIn "$work/python" > "$work/python.log" 2>&1
fi
echo "  exit code: $?"
echo

python3 "$testsDir/compare_trees.py" "$work/bash" "$work/python"
status=$?

echo
echo "Sandboxes and logs: $work"
exit $status
