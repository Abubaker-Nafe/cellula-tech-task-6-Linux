#!/usr/bin/env bash
set -euo pipefail

mkdir -- SecurityLab
cd -- SecurityLab
echo 'Public company notice' > public.txt
echo 'Private payroll notes' > private.txt
cat > script.sh <<'SCRIPT'
#!/usr/bin/env bash
printf "SecurityLab script ran\n"
SCRIPT

chmod 644 -- public.txt
chmod 600 -- private.txt
chmod 755 -- script.sh
echo 'Numeric modes in the long listing'
ls -l -- public.txt private.txt script.sh

chmod u=rw,go= -- private.txt
echo
echo 'Private file after symbolic chmod'
stat -c '%a %A %n' -- private.txt

ln -s -- script.sh script_link
ln -- public.txt public_backup
echo
echo 'Inodes and link information'
ls -li -- public.txt public_backup script.sh script_link
stat -c '%n inode=%i hard_links=%h type=%F' -- public.txt public_backup script.sh script_link
echo
echo 'Symbolic link target'
readlink -- script_link
stat -L -c 'Dereferenced script_link inode=%i' -- script_link
./script_link
