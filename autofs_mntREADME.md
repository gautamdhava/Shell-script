# Shell-script
System Administration
####This script will be helpful if you want add an autofs mount for a new nfs share in multiple servers. 

Purpose:
Linux standard suggests using autofs to mount a NAS share. You must pass three arguments for this script. 
Argument 1. Comment – The comment should be less than 5 characters and only alphanumeric. For example if you are trying to add a new backup mount , then give comment like “nfsbk” or “backup”
Argument 2. Nfs share path . nfsserver:path example: 10.0.1.1:/nf/shared/backup
Argument 3: Mount point. “/mountpoint” . example: /J2Migration

The script will exit without any action if it meets below conditions:
1.	If the mount point directory is already present
2.	If the share is already mounted
3.	If the direct mapping file is already present .. For example /etc/auto.migr . 

4.	If the given arguments is not valid. Example , the comment should contain only alphanumeric and character not more than 5. The mount point argument must be absolute path, otherwise it will not accept. 
5.	If the mentioned nfs server is not reachable from client or if the export is not listed in show mount output
The script will also check if the necessary rpms are installed, and services are enabled and active. If not, then it will install the packages and start/enable the required services. 
 

Successful execution: please see below snippet

 
Thanks,
Gautam
