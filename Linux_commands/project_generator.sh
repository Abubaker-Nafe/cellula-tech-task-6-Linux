#!/usr/bin/env bash
set -euo pipefail

printf 'Enter a project name: '
if ! IFS= read -r project; then
    echo >&2
    echo 'A project name is required.' >&2
    exit 1
fi
if [[ ! $project =~ [^[:space:]] || $project == */* ||
      $project == . || $project == .. || $project =~ [[:cntrl:]] ]]; then
    echo 'Enter a nonempty project name without slashes or control characters.' >&2
    exit 1
fi
if [[ -e $project || -L $project ]]; then
    printf 'A path named %s already exists.\n' "$project" >&2
    exit 1
fi

printf 'Enter the number of required directories (at least 4): '
if ! IFS= read -r directory_count; then
    echo >&2
    echo 'A directory count is required.' >&2
    exit 1
fi
# Strip leading zeros and reject values outside Bash's integer range.
if [[ ! $directory_count =~ ^0*([1-9][0-9]*)$ ]] ||
   ! count=$(printf '%d' "${BASH_REMATCH[1]}" 2>/dev/null) || (( count < 4 )); then
    echo 'Enter a whole number of at least 4 for src, tests, docs and config.' >&2
    exit 1
fi

mkdir -- "$project"
mkdir -- "$project"/{src,tests,docs,config}
for ((number = 4; number < count; number++)); do
    mkdir -- "$project/extra_$((number + 1))"
done

cat > "$project/src/main.py" <<'PYTHON'
def greeting():
    return "Hello from the project!"


if __name__ == "__main__":
    print(greeting())
PYTHON
cat > "$project/tests/test_main.py" <<'PYTHON'
import unittest

from src.main import greeting


class GreetingTest(unittest.TestCase):
    def test_greeting(self):
        self.assertEqual(greeting(), "Hello from the project!")
PYTHON
printf '# %s\n\nRun `python3 src/main.py` from the project root.\n\nRun tests with `python3 -m unittest discover -s tests`.\n' "$project" > "$project/docs/README.md"
printf '[project]\ndebug = false\n' > "$project/config/settings.conf"

echo
echo 'Generated project structure'
(cd -- "$project" && find . -print | LC_ALL=C sort)
printf 'Successfully created project %s with %d subdirectories.\n' "$project" "$count"
