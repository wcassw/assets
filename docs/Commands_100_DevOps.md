## Basic Linux Commands

### 1. pwd – Print Working Directory
```
pwd               # Shows current directory location
/home/user/project
```

### 2. ls – List Files and Directories
```
ls           # list items in current directory
ls -l        # list detailed file info (size, permissions)
ls -a        # list all including hidden files
```

### 3. cd – Change Directory
```
cd /var/log           # go to /var/log directory
cd ..                 # move one step back
cd ~                  # go to home directory
```

### 4. touch – Create an Empty File
```
touch file.txt     # Creates file.txt in the current directory.
```

### 5. mkdir – Create a Directory
```
mkdir backups           # Creates a folder named backups
mkdir dir1 dir2 dir3    # To create multiple directories
```

### 6. rm – Remove Files or Directories
```
rm file.txt        # delete a file
rm -r folder/      # delete a directory , ⚠ Use with caution, especially with -r
```

### 7. rmdir – Remove Empty Directory
```
rmdir test_folder    # Deletes a directory only if it is empty.
```

### 8. cp – Copy Files/Directories
```
cp file.txt /tmp/              # copy file to /tmp/ 
cp -r dir1/ dir_backup/        # copy directory (recursive)
```

### 9. mv – Move or Rename Files/Directories
```
mv file.txt /tmp/              # move file to /tmp
mv oldname.txt newname.txt     # rename file
```

### 10. cat – View File Content
```
cat config.txt                         # Displays content of a file.
cat file1.txt file2.txt > merged.txt   # You can also combine files.
```

### 11. echo – Print Text to Terminal
```
echo "Hello DevOps!"                # Used to display text or write content into files.
echo "Job Done!" > message.txt      # creates file with text
echo "More data" >> message.txt     # append to file
```

### 12. clear – Clear Terminal Screen
```
clear  # Clears previously printed commands and output to keep the screen clean.
Ctrl + L   # Shortcut key
```

## Intermediate Linux Commands
These commands are widely used in daily DevOps operations — from file permissions to process monitoring, network testing, data transfers and file management.

### 13. chmod – Change File Permissions
```
chmod 400 test.txt      # Controls who can read, write, or execute a file.
chmod 755 script.sh      # read+write+execute for owner, read+execute for others
chmod 644 file.txt       # owner read/write, others read-only
```

### 14. chown – Change File Ownership
```
chown user file.txt             # change owner
chown user:group file.txt       # change owner and group
```

### 15. find – Search Files/Directories
```
find /var -name "log*"          # search files starting with log
find . -type f -size +10M        # find files larger than 10MB
```

### 16. grep – Search Text in Files
```
grep "error" app.log         # search word "error" - Find lines containing a specific pattern.
grep -i "fail" app.log       # case-insensitive search
grep -r "password" /etc/     # search recursively in directories
```

### 17. wc – Word/Line/Character Count
```
wc -l file.txt        # count lines
wc -w file.txt        # count words
wc -c file.txt        # count characters
```

### 18. head – View First Lines of a File
```
head file.txt         # By default shows first 10 lines.
head -n 5 file.txt    # first 5 lines
```

### 19. tail – View Last Lines of a File
```
tail file.log         # By default shows last 10 lines.
tail -f file.log      # live real-time log view - Useful for log monitoring.
```

### 20. sort – Sort File Content
```
sort names.txt        # Sorts alphabetically or numerically.
sort -n numbers.txt   # numeric sort
```

### 21. uniq – Remove Duplicate Lines
```
sort data.txt | uniq   # Used with sort to filter unique values.
```

### 22. diff – Compare Two Files
```
diff old.conf new.conf   # Shows line-by-line differences.
```

### 23. tar – Create or Extract Tar Archives
```
tar -cvf archive.tar folder/         # create tar - Used for backups files.
tar -xvf archive.tar                 # extract tar
```

### 24. zip/unzip – Compress & Extract Zip Files
```
zip logs.zip *.log                  # zip files
unzip logs.zip                      # extract zip
```

### 25. df – Disk Space Usage
```
df -h     # Shows available disk and partition usage in human readable format
```

### 26. du – Directory Size
```
du -sh /var/log      # total size
du -h *              # Shows space used by directories/files.
```

### 27. top – Live Process Monitoring
```
top        # Real-time CPU/memory usage display. (Exit with → q)
```

### 28. ps – Show Running Processes
```
ps aux                 # all processes
ps -ef | grep nginx    # filter specific process
```

### 29. kill – Terminate Processes
```
kill 1234          # normal termination.
kill -9 1234       # force kill
```

### 30. ping – Test Network Reachability
```
ping google.com   #Checks server connectivity & latency (Stop → Ctrl + C)
```

### 31. wget – Download Files from Web
```
wget https://example.com/file.zip   # Simple file download via URL.
```

### 32. curl – Transfer Data to/from Server
```
curl http://example.com                 # Supports HTTP, FTP, API calls, etc.
curl -O https://site.com/file.tar.gz    # download file
```

### 33. scp – Secure File Transfer Between Hosts
```
scp file.txt user@server:/tmp/    # SSH-based file copy.
scp user@server:/home/logs.zip .
```

### 34. rsync – Fast File Sync/Backup
```
rsync -av /data/ /backup/           # Efficient incremental copy.
rsync -avz file user@server:/path/
```

## Advanced Linux Commands
Perfect for DevOps, SysAdmin, and interview preparation ✔️

### 35. awk — Text processing and pattern scanning
```
awk '{print $1, $3}' file.txt  # Prints column 1 and 3 from each line. - Extract columns, filter rows, perform operations
```

### 36. sed — Stream editor (search, replace, modify text)
```
sed 's/error/ok/g' logfile.txt # Replaces all occurrences of error with ok.
```

### 37. cut — Remove/extract sections of text
```
cut -d ":" -f 1 /etc/passwd # Shows only first field (username) using : as delimiter.
```

### 38. tr — Translate or delete characters
```
echo "hello world" | tr 'a-z' 'A-Z'  # Converts lowercase to uppercase.
```

### 39. xargs — Build and execute commands from input
```
cat files.txt | xargs rm   # Reads file names from files.txt and deletes them.
```

### 40. ln — Create hard or symbolic links
```
ln -s /path/original file_link  # Creates a symbolic link to a file or folder.
```

### 41. df -h — Disk usage in human-readable format
```
df -h   # Shows disk space in GB/MB
```

### 42. free — Display memory usage
```
free -h   # Shows RAM usage in human-readable form.
```

### 43. iostat — CPU and I/O statistics
```
iostat -x 2  # Shows extended I/O stats every 2 seconds.
```

### 44. netstat (deprecated) / ss (modern)
```
ss -tulnp  # Shows listening ports and services.
```

### 45. ifconfig / ip — Network configuration
```
ip addr show  # Shows IP addresses of interfaces.
```

### 46. iptables — Firewall rule configuration
```
sudo iptables -L  # Lists current firewall rules.
```

### 47. systemctl — Manage systemd services
```
sudo systemctl restart nginx   # Restarts the nginx service.
```

### 48. journalctl — View system logs
```
journalctl -u nginx  # Shows logs for the nginx service.
```

### 49. crontab — Schedule recurring tasks
```
crontab -e                       # Add a cron job,
0 1 * * * /home/user/backup.sh   # e.g., run script every day at 1 AM:
```

### 50. at — Schedule one-time tasks
```
echo "reboot" | at 02:00   # Schedules a reboot at 2 AM.
```

### 51. uptime — Shows system uptime and load
```
uptime     # Shows how long the system is running + load average.
```

### 52. whoami — Current logged-in user
```
whoami  # Current logged-in user
```

### 53. users — List users currently logged in
```
users  #  List users currently logged in
```

### 54. hostname — Show or set system hostname
```
hostname   # Show hostname:
sudo hostnamectl set-hostname server01   # Set new hostname:
```

### 55. env — Display environment variables
```
env   #  Display All environment variables
```

### 56. export — Set environment variables
```
export PATH=$PATH:/opt/myapp/bin  # Adds new path permanently for current session.
```

## Advanced Networking Commands

### 57. ip addr — Display or configure IP addresses
```
ip addr show  # Displays all network interfaces and their IPs
sudo ip addr add 192.168.1.10/24 dev eth0  #  Assign an IP
```

### 58. ip route — View or modify routing table
```
ip route                   # Shows default and static routes.
sudo ip route add 10.0.0.0/24 via 192.168.1.1   # Add a route
```

### 59. traceroute — Trace the path of packets
```
traceroute google.com  # Shows the hops packets take to reach a destination.
```

### 60. nslookup — DNS lookup utility
```
nslookup google.com  # Used to check DNS resolution (domain → IP and reverse lookup).
nslookup 8.8.8.8     # Reverse lookup:
```

### 61. dig — Flexible DNS query tool
```
dig google.com  # More powerful than nslookup; used for DNS troubleshooting.
dig google.com A          # Query only A record: 
dig @8.8.8.8 example.com  # Check DNS propagation:
```

### 62. ssh — Secure remote login
```
ssh user@192.168.1.20   # Connect securely to remote servers using encrypted communication.
scp file.txt user@server:/tmp/    # Copy files with SSH:
```

### 63. ftp — Transfer files via FTP protocol
```
ftp 192.168.1.10  #  Older file transfer protocol; mostly replaced by SFTP.
put file.txt    #  Inside FTP command
get data.zip    #  Inside FTP Command
```

### 64. nmap — Network scanner & security auditing
```
nmap 192.168.1.0/24    # Used to discover hosts, open ports, OS detection, vulnerabilities.
nmap -sV 192.168.1.10  # Scan a single host:
```

### 65. telnet — Test connectivity (TCP)
```
telnet google.com 80  # Used to test open ports on remote systems. (Not secure and rarely used for remote login today.)
```

### 66. netcat (nc) — Read/write over network (Swiss Army Knife)
```
nc -zv 192.168.1.10 22       # Used for port scanning, file transfer, debugging, and more.
nc -l 4444 > received.txt    # Transfer file: 
nc server-ip 4444 < file.txt # Sender:
```

## File Management & Search Commands
These commands help you quickly inspect files, search for them, and understand directory structures.

### 67. locate – Find Files Quickly
```
locate searches for files using a pre-built database, making it much faster than find.
locate nginx.conf  # ✔ Shows all paths where nginx.conf exists.
Note: Run updatedb to refresh its database (if needed).
```

### 68. stat – File Information & Metadata
```
stat file.txt # Displays detailed file info such as size, permissions, timestamps, owner, inode, etc.
Output (example):
Size: 2048  Blocks: 8  IO Block: 4096 regular file
Access: (0644/-rw-r--r--)  Uid: (1000/user)  Gid: (1000/user)
```

### 69. tree – Display Directory Structure in Tree Format
tree /var/www/  # Shows directories and files visually in a tree layout.
```
Output (example):
/var/www/
├── index.html
├── css
│   └── style.css
└── js
    └── app.js
Install if missing:
sudo yum install tree   # RHEL/CentOS  
sudo apt install tree   # Ubuntu/Debian
```

### 70. file – Identify File Type
file backup.tar.gz  # Helps you determine a file's actual type (binary, text, script, image, etc.).
file script.sh
```
Output example: 
backup.tar.gz: gzip compressed data
script.sh: Bourne-Again shell script
```

### 71. basename – Get File Name From Path
```
basename /home/user/data/report.csv  # Extracts only the filename from a full path.
Output: report.csv
```

### 72. dirname – Get Directory Path Only
```
dirname /home/user/data/report.csv  # Extracts the folder path, removing the filename.
Output: /home/user/data
```

## System Monitoring Commands

### 73. vmstat – Virtual Memory Statistics
```
vmstat 1 5  # Displays memory, CPU, paging, and process statistics. 
            # ✔ Shows stats every 1 second, 5 times.
```

### 74. htop – Interactive Process Viewer
```
A modern, user-friendly alternative to top.
Shows CPU, memory usage, processes, colors, scroll, and kill options.
htop
Install if missing:
sudo apt install htop
sudo yum install htop
```

### 75. lsof – List Open Files
```
Shows all open files used by processes — useful for debugging ports and locks.
lsof -i :8080         # find process using port 8080
lsof /var/log/messages # see who is using file
```

### 76. dmesg – Kernel Messages
```
dmesg | tail  # Prints kernel and hardware-related logs (boot issues, device detection).
```

### 77. uptime – System Uptime
```
uptime  # Shows system running duration, user count, and load average.
Output example: 
14:20:10 up 12 days,  3 users,  load average: 0.12, 0.08, 0.05
```

### 78. iotop – Real-Time Disk I/O Monitor
```
sudo iotop  # Displays which processes are reading/writing to disk.
Install if required:
sudo apt install iotop
sudo yum install iotop
```

## Package Management Commands

### 79. apt – Package Manager (Debian/Ubuntu)
```
Used to install, update, remove packages.
sudo apt update
sudo apt install nginx
sudo apt remove nginx
```

### 80. yum / dnf – Package Manager (RHEL/CentOS/Fedora)
```
Used on RedHat-based systems.
sudo yum install httpd
sudo yum update
sudo dnf remove httpd
```

### 81. snap – Manage Snap Packages
```
Used on systems that support snap (Ubuntu etc.).
snap list
sudo snap install docker
sudo snap remove docker
```

### 82. rpm – RedHat Package Manager
Manages .rpm packages directly.
rpm -ivh package.rpm    # install
rpm -qa                 # list installed packages
rpm -e package          # remove package

## Disk & Filesystem Commands

### 83. mount / umount – Mount or Unmount Filesystems
```
Mount attaches a filesystem; umount detaches it.
mount /dev/sdb1 /mnt/data     # mount disk
umount /mnt/data              # unmount
```

### 84. fsck – Filesystem Check & Repair
```
Used to fix corrupted filesystems (run on unmounted disks).
fsck /dev/sdb1  # ⚠️ Do NOT run on a mounted filesystem.
```

### 85. mkfs – Create a Filesystem
```
mkfs.ext4 /dev/sdb1  # Formats a disk with a filesystem.
```

### 86. blkid – Display Block Device Info
```
blkid  # Shows UUIDs, filesystem types, etc.
```

### 87. lsblk – List Block Devices
```
lsblk  # Displays device names, mount points, sizes.
```

### 88. parted – Partition Management Tool
```
parted /dev/sdb # For creating, resizing, deleting partitions interactively.
Inside parted:
(parted) print
(parted) mkpart
```

## Scripting & Automation Commands

### 89. bash – Bash Shell & Scripting
```
Runs commands, interactive shell, and executes .sh scripts.
bash script.sh           # run a script
bash                     # start bash shell
```

### 90. sh – POSIX Legacy Shell
```
sh script.sh # Older shell interpreter; commonly used for compatibility.
```

### 91. cron – Schedule Automated Tasks
```
crontab -e  # Used for running tasks at specific intervals (daily, hourly, weekly).

0 2 * * * /home/user/backup.sh # Example job (run script every day at 2 AM):
```

### 92. alias – Create Command Shortcuts
```
Helps shorten long or complex commands.
alias ll='ls -l'
alias gs='git status'
alias rm='rm -i'
```

### 93. source – Execute File in Current Shell
```
Runs commands without creating a new shell.
source .bashrc     # reload config
source env.sh      # load environment variables
```

## Development & Debugging Commands

### 94. gcc – C Compiler
```
Compiles C programs into executables.
gcc hello.c -o hello
./hello
```

### 95. make – Build Automation Tool
```
A tool to compile and build projects using a Makefile.
make
make clean
```

### 96. strace – System Call Tracer
```
Tracks system calls made by a process. Useful for debugging errors.
strace ls
strace -p 1234     # attach to process
```

### 97. gdb – GNU Debugger
```
Debugs executables, inspects variables, sets breakpoints.
gdb ./a.out
(gdb) run
(gdb) break main
```

### 98. git – Version Control System
```
Used widely in DevOps for managing code and repositories.
Common commands:

git clone <repo-url>
git status
git add .
git commit -m "update"
git push
```

### 99. vim / nano – Text Editors
Used to edit configuration files, scripts, and code.
