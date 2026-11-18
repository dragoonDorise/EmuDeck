#!/usr/bin/env bash
testsDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$testsDir/../.." && pwd)"
results="${EMUDECK_TEST_RESULTS:-$HOME/EmuDeck-tests}"

if [ $# -eq 0 ]; then
	echo "Usage: $0 <bash_function> [more_functions...]"
	echo "Runs tests/migration/compare.sh for each function inside the Linux test container."
	exit 2
fi

mkdir -p "$results"
docker build -q -t emudeck-migration-tests "$testsDir" >/dev/null || exit 2

status=0
for fn in "$@"; do
	echo "=================== $fn ==================="
	docker run --rm -e EMUDECK_TEST_PREPARE="${EMUDECK_TEST_PREPARE:-}" -v "$repo":/repo -v "$results":"$results" -e TMPDIR="$results" \
		emudeck-migration-tests "$fn"
	if [ "${PIPESTATUS[0]}" -ne 0 ]; then
		status=1
	fi
done
exit $status
