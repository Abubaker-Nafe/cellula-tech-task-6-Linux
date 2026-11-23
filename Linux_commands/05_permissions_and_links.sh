#!/usr/bin/env bash
set -euo pipefail

mkdir -- SecurityLab
cd -- SecurityLab
printf '%s\n' 'Public company notice' > public.txt
printf '%s\n' 'Private payroll notes' > private.txt
printf '#!/usr/bin/env bash\nprintf "SecurityLab script ran\\n"\n' > script.sh

chmod 644 -- public.txt
chmod 600 -- private.txt
chmod 755 -- script.sh
printf 'Numeric modes in the long listing\n'
ls -l -- public.txt private.txt script.sh

chmod u=rw,go= -- private.txt
printf '\nPrivate file after symbolic chmod\n'
stat -c '%a %A %n' -- private.txt

ln -s -- script.sh script_link
ln -- public.txt public_backup
printf '\nInodes and link information\n'
ls -li -- public.txt public_backup script.sh script_link
stat -c '%n inode=%i hard_links=%h type=%F' -- public.txt public_backup script.sh script_link
printf '\nSymbolic link target\n'
readlink -- script_link
stat -L -c 'Dereferenced script_link inode=%i' -- script_link
./script_link
