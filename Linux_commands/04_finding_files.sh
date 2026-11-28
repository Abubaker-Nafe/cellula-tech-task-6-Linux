#!/usr/bin/env bash
set -euo pipefail

mkdir -- ProjectFiles
cd -- ProjectFiles
mkdir -- Backup Config Scripts

echo 'Project notes' > notes.txt
echo 'Review staging deployment' > tasks.txt
printf 'port=8080\nenvironment=production\n' > server.conf
printf 'INFO Application started\nERROR Database connection timed out\n' > app.log
printf 'id,item\n1,router\n' > inventory.csv
printf 'INFO Login audit started\nINFO ERROR_COUNT=0\n' > audit.log
echo 'Notes from the previous release' > Backup/old_notes.txt
printf 'id,item\n1,spare switch\n' > Backup/snapshot.csv
printf 'INFO Backup started\nERROR Backup destination unavailable\n' > Backup/backup.log
printf 'Archived release manifest, record %03d\n' {1..80} > Backup/archive.txt
echo 'retention_days=30' > Backup/settings.conf
printf 'port=8081\nenvironment=staging\n' > Config/server.conf
echo 'timeout_seconds=10' > Config/client.conf
echo 'retries=3' > Config/defaults.conf
echo 'Configuration for the staging service' > Config/readme.txt
printf 'id,role\n1,operator\n' > Config/users.csv
cat > Scripts/deploy.sh <<'SCRIPT'
#!/usr/bin/env bash
printf "Deploy\n"
SCRIPT
cat > Scripts/health.sh <<'SCRIPT'
#!/usr/bin/env bash
printf "Healthy\n"
SCRIPT
cat > Scripts/maintenance.sh <<'SCRIPT'
#!/usr/bin/env bash
printf "Maintenance complete\n"
SCRIPT
printf 'INFO Health check started\nERROR: Disk quota reached\n' > Scripts/maintenance.log

echo 'Number of project files before generating the error report'
find . -type f -printf '.' | wc -c
echo
echo 'All .txt files'
find . -type f -name '*.txt' -print | LC_ALL=C sort
echo
echo 'Every server.conf'
find . -type f -name 'server.conf' -print | LC_ALL=C sort
echo
echo 'Files larger than 1 KB (1,024 bytes)'
find . -type f -size +1024c -printf '%s bytes  %p\n' | LC_ALL=C sort

find . -type f -name '*.log' -print0 | LC_ALL=C sort -z | xargs -0 -r grep -Hnw -- ERROR > errors.txt
echo
echo 'Log entries matching the whole word ERROR'
cat -- errors.txt
