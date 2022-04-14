linux_filesystem_backup
Generic Backup Scripts For Linux This tool can create backups of folders. It's simple.

Easy to understand and use. Made to be easy to setup. History of how many backups you want stored for a specific item. Log files for the backup, you actually know what was done.

Requirements
bash and rsync

Automated backups
This script runs backups of filesystem..

crontab -e

m h dom mon dow command
00 00 * * * /home/corwin71/backup/fs_backup_2_NAS.sh
