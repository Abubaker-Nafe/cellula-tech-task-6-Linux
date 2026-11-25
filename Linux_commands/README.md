# Linux assignments with Bash history

Each assignment ran in a fresh interactive Bash session and exported its command history with `history -w`. Lines beginning with `#` followed by digits are Bash timestamps. The transcript pairs the entered commands with their terminal output. [Demo transcript](demo_transcript.txt)

| Assignment | Bash history |
| --- | --- |
| 01 · Company directories | [01_company_directory.txt](command_history/01_company_directory.txt) |
| 02 · Employee files | [02_employee_files.txt](command_history/02_employee_files.txt) |
| 03 · Monthly reports | [03_reading_reports.txt](command_history/03_reading_reports.txt) |
| 04 · File search | [04_finding_files.txt](command_history/04_finding_files.txt) |
| 05 · Permissions and links | [05_permissions_and_links.txt](command_history/05_permissions_and_links.txt) |
| 06 · Redirection and pipelines | [06_redirection_and_pipelines.txt](command_history/06_redirection_and_pipelines.txt) |
| 07 · Employee CSV | [07_employee_database.txt](command_history/07_employee_database.txt) |
| 08 · Process monitoring | [08_process_monitoring.txt](command_history/08_process_monitoring.txt) |
| 09 · Project generator | [09_project_generator.txt](command_history/09_project_generator.txt) |
| 10 · File checker | [10_file_checker.txt](command_history/10_file_checker.txt) |
| 11 · File organizer | [11_file_organizer.txt](command_history/11_file_organizer.txt) |

The commands for assignments 01–08 and the sample download setup were entered directly into Bash. For the three script exercises, the histories record the script invocations and sample inputs. The execution traces show the commands Bash ran inside those scripts. [Project generator trace](execution_trace/09_project_generator.txt) · [File checker trace](execution_trace/10_file_checker.txt) · [File organizer trace](execution_trace/11_file_organizer.txt)

## Run the exercises again

The generated files are in `demo/` in the local workspace. The transcript uses `<demo>` for the working directory and `<exercise-folder>` for the folder containing the scripts. In the histories, the `TASK9_` variables point to the scripts and capture files for that session.

From the repository root, run the copied Bash demo in a new scratch directory.

```bash
bash Linux_commands_history/run_demo.sh
```

To create a fresh set of histories and traces, use Python 3 with `pexpect`. The command writes the new capture to a separate directory under `demo/`.

```bash
python3 Linux_commands_history/record_history.py Linux_commands_history/demo/recapture
```
