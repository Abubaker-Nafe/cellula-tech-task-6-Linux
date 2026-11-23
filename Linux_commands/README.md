# Linux command assignments

From the repository root, run the demo on GNU/Linux with Bash. By default, it creates a fresh temporary directory and prints the path at the end.

```bash
bash Linux_commands/run_demo.sh
bash Linux_commands/run_demo.sh ./task9-linux-output
```

The `demo/` directory in the completed local workspace contains the generated files. The transcript records the listings, process checks and report output. `<project>` represents the local repository path. [Recorded demo](demo_transcript.txt)

| Assignment | Script | Evidence |
| --- | --- | --- |
| 01 · Company directory | [01_company_directory.sh](01_company_directory.sh) | Directory tree, `pwd`, hidden-inclusive listing, empty `Company/company_info.txt` |
| 02 · Employee files | [02_employee_files.sh](02_employee_files.sh) | Employee records, HR copy and deletion, department moves and `manager.txt` |
| 03 · Read reports | [03_reading_reports.sh](03_reading_reports.sh) | Three 15-line reports, excerpts, `wc` counts and `quarterly_report.txt` |
| 04 · Find files | [04_finding_files.sh](04_finding_files.sh) | Twenty input files, two `server.conf` matches, a file over 1,024 bytes and `errors.txt` |
| 05 · Permissions and links | [05_permissions_and_links.sh](05_permissions_and_links.sh) | Modes `644`, `600` and `755`, symbolic `chmod`, hard and symbolic link inode checks |
| 06 · Pipelines | [06_redirection_and_pipelines.sh](06_redirection_and_pipelines.sh) | 50 even and 50 odd lines, appended counts, redirected stderr and ten largest numbers |
| 07 · Employee database | [07_employee_database.sh](07_employee_database.sh) | 24 employees, name extraction and sorting, department totals and salary filter |
| 08 · Process control | [08_process_monitoring.sh](08_process_monitoring.sh) | Three background PIDs, CPU and memory listing, timestamp logs and verified shutdown |
| 09 · Project generator | [project_generator.sh](project_generator.sh) | Project scaffolding, counted directories and input validation |
| 10 · File checker | [file_checker.sh](file_checker.sh) | File metadata, direct and recursive directory counts, effective access checks |
| 11 · File organizer | [11_seed_downloads.sh](11_seed_downloads.sh), [organizer.sh](organizer.sh) | 25 sample downloads, seven folders and `organization_report.txt` |

For an individual run, change into a scratch directory and call the desired script by its absolute path. Run assignment 01 before assignment 02. Assignment 08 starts [process1.sh](process1.sh), [process2.sh](process2.sh) and [process3.sh](process3.sh) and collects their UTC timestamps.

The project generator requires at least four subdirectories for `src`, `tests`, `docs` and `config`. Higher counts add `extra_5`, `extra_6` and so on. The organizer uses the supplied directory or the current directory's `Downloads`. Its sample files are empty placeholders for extension-based sorting. Duplicate destination names receive a numeric suffix.
