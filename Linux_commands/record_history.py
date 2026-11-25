#!/usr/bin/env python3
"""Execute the Linux exercises in isolated interactive Bash sessions."""

import argparse
import io
import os
from pathlib import Path

import pexpect


SCRIPTS = Path(__file__).resolve().parent
PROMPT = "__assignment_prompt__ "
CONTINUATION = "__assignment_continuation__ "


def script_commands(path):
    commands = path.read_text(encoding="utf-8").splitlines()[1:]
    if path.name == "08_process_monitoring.sh":
        # An interactive shell has no script path in BASH_SOURCE[0].
        commands = ["scripts=$TASK9_SCRIPTS" if line.startswith("scripts=") else line for line in commands]
    return commands


def trace(script, name):
    return f'BASH_XTRACEFD=9 bash -x "$TASK9_SCRIPTS/{script}" 9>> "$TASK9_TRACES/{name}.txt"'


def exercises():
    for script in sorted(SCRIPTS.glob("0[1-8]_*.sh")):
        yield script.stem, script_commands(script)

    generator = trace("project_generator.sh", "09_project_generator")
    yield "09_project_generator", [
        "set -euo pipefail",
        f"printf 'MentorDemo\\n6\\n' | {generator}",
        f"if printf '\\n' | {generator}; then exit 1; fi",
        f"if printf 'MentorDemo\\n4\\n' | {generator}; then exit 1; fi",
        f"if printf 'TooSmall\\n3\\n' | {generator}; then exit 1; fi",
        "(cd -- MentorDemo && python3 -B -m unittest discover -s tests)",
    ]

    checker = trace("file_checker.sh", "10_file_checker")
    yield "10_file_checker", [
        "set -euo pipefail",
        "mkdir -p -- CheckerLab/.hidden_directory",
        "printf 'Hidden sample\\n' > CheckerLab/.hidden_file",
        f"printf 'SecurityLab/private.txt\\n' | {checker}",
        f"printf 'CheckerLab\\n' | {checker}",
        f"if printf 'missing-path\\n' | {checker}; then exit 1; fi",
    ]

    yield "11_file_organizer", [
        *script_commands(SCRIPTS / "11_seed_downloads.sh"),
        "ls -A -- .",
        "cd -- ..",
        trace("organizer.sh", "11_file_organizer") + " Downloads",
        "find Downloads -type f -print | LC_ALL=C sort",
    ]


def run_session(name, commands, demo, histories, traces, transcript):
    env = os.environ.copy()
    for variable in ("BASH_ENV", "ENV", "CDPATH", "PROMPT_COMMAND", "BASHOPTS", "SHELLOPTS", "BASH_XTRACEFD"):
        env.pop(variable, None)
    env.update(
        HISTFILE="/dev/null", HISTCONTROL="", HISTIGNORE="", HISTSIZE="10000", HISTFILESIZE="10000",
        HISTTIMEFORMAT="%F %T ", PS1=PROMPT, PS2=CONTINUATION, TERM="dumb", LC_ALL="C", TZ="UTC",
        TASK9_SCRIPTS=str(SCRIPTS), TASK9_TRACES=str(traces), TASK9_HISTORY=str(histories / f"{name}.txt"),
    )
    output = io.StringIO()
    session = pexpect.spawn(
        "bash", ["--noprofile", "--norc", "--noediting", "-O", "lithist", "-i"], cwd=str(demo), env=env,
        encoding="utf-8", codec_errors="replace", timeout=30, dimensions=(30, 160),
    )
    session.logfile_read = output
    session.delaybeforesend = None
    try:
        session.expect_exact(PROMPT)
        prompt = 0
        for line in commands:
            if line or prompt == 1:
                session.sendline(line)
                prompt = session.expect_exact([PROMPT, CONTINUATION])
        if prompt != 0:
            raise RuntimeError(f"Incomplete command at the end of {name}")
        session.sendline('history -w "$TASK9_HISTORY"')
        session.expect_exact(PROMPT)
        session.sendline("exit")
        session.expect(pexpect.EOF)
        session.close()
        if session.exitstatus != 0 or not (histories / f"{name}.txt").is_file():
            raise RuntimeError(f"The Bash session did not record a completed history for {name}")
    finally:
        session.close(force=True)
        content = output.getvalue().replace("\r\n", "\n").replace("\r", "")
        content = content.replace(PROMPT, "$ ").replace(CONTINUATION, "> ")
        content = content.replace(str(demo), "<demo>")
        content = content.replace(str(SCRIPTS), "<exercise-folder>")
        transcript.write(f"\n--- {name} ---\n")
        transcript.write("\n".join(line.rstrip() for line in content.splitlines()) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", nargs="?", type=Path, default=SCRIPTS, help="where to save the new capture")
    args = parser.parse_args()
    output = args.output.resolve()
    demo = output / "demo"
    histories = output / "command_history"
    traces = output / "execution_trace"
    transcript_path = output / "demo_transcript.txt"
    for target in (demo, histories, traces, transcript_path):
        if target.exists() or target.is_symlink():
            parser.error(f"{target} exists. Choose a different output folder.")
    for directory in (demo, histories, traces):
        directory.mkdir(parents=True)

    with transcript_path.open("x", encoding="utf-8") as transcript:
        transcript.write("Linux assignments recorded in interactive Bash sessions\n")
        for name, commands in exercises():
            run_session(name, commands, demo, histories, traces, transcript)
            print(f"Recorded {name}", flush=True)


if __name__ == "__main__":
    main()
