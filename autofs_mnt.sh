#!/bin/bash
#devoloped by gautam.dhavamani
fun()
{
case $mpt in
    /*) true;;
    * ) echo -e "Enter absolute path of $3 example \"/mnt/test\"" ;exit 1;;
esac
}
if [ $# -lt 3 ] || [ $# -gt 3 ]
then
echo "Usage :"
echo "./mig_autmnt.sh "comment" "nfsserver:/path" "/mountpoint""
echo "Example:"
echo "./mig_autmnt.sh migr 10.231.255.142:/Uscowrsfsz31_J2CMigrationShare /J2CMigration"
echo
exit 1
elif [ ${#1} -gt 5 ]
then
echo "Too long - Comment must be 5 characters max"
exit 1
elif [[ $1 =~ [0-9] ]];then
echo "comment should contain only alphanumeric characters"
exit 1
fi
mpt="$3"
fun
nfstst=`echo "$2" | cut -d : -f 1`
ping -c1 $nfstst 2>&1 >/dev/null
if [ $? -ne 0 ]; then
echo "Mentioned Nfs server is not reachable.echo response failed. Please check"
exit 1
fi
nfstst1=`echo "$2" | cut -d : -f 2`
showmount -e $nfstst | grep $nfstst1 2>&1 >/dev/null
if [ $? -ne 0 ]; then
echo "The mount is not available in client export list. Check showmount -e output"
echo "showmount -e $nfstst | grep $nfstst1"
exit 1
fi
#checking necessary rpms are installed, if not it will install and enable the required services,
rpm -q nfs-utils > /dev/null
if [ $? -ne 0 ]; then
echo "nfs-utils package not available ,hence installing and enabling the service"
yum install nfs-utils -y > /dev/null 2>&1
fi
rpm -q autofs > /dev/null
if [ $? -ne 0 ]; then
echo "Autofs package not available ,hence installing and enabling the service"
yum install autofs -y > /dev/null 2>&1
systemctl enable --now autofs > /dev/null 2>&1
else
systemctl is-active --quiet  autofs && systemctl is-enabled --quiet  autofs
if [ $? -ne 0 ]; then
systemctl enable --now autofs > /dev/null 2>&1
if [ $?  -eq 0 ]; then
echo "Autofs service is enabled and started"
else
echo "Autofs service is not running.. Please check manually"
exit 1
fi
fi
fi
if grep -qs "$3" /proc/mounts; then
echo "$3 is already mounted..Hence exiting"
exit 1
fi
if [ ! -d "$3" ] ;then
mkdir $3
if [ ! -f "/etc/auto.$1" ];then
touch /etc/auto.$1 && chmod 644 /etc/auto.$1
echo "$3 -rw,soft,intr $2" >> /etc/auto.$1
echo "/- /etc/auto.$1" >> /etc/auto.master.d/$1.autofs
systemctl restart autofs > /dev/null 2>&1
if [ $?  -eq 0 ]; then
echo "Autofs service restarted successfully"
else
echo "Autofs service is not running.. Please check manually"
exit 1
fi
else
echo "direct mapping already present for auto.$1 .Skipping"
fi
else
echo "$3 Directory already exists . Hence exiting"
exit 1
fi
cd $3
echo "$3 mounted successfully"
df -hTP $3
exit 0

