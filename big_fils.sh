#/bin/bash
<<<<<<< HEAD:big_fils.sh

=======
#Prepared by Gautam D
>>>>>>> newgtmbranch:list_bigfiles.sh
#Script to list large directories and files in a Filesystem, and it will not cross Filesystem boundaries.
fun()
{
case $FS1 in
        /*) true;;
        * ) echo -e "Enter absolute path of FS example \"/home\"" ;exit 1;;
esac
}
if [[ -n $1 ]]
then
        FS="$1"
        fun
else

    read -p "Please enter the Filesystem name:" FS
    fun
fi
if mountpoint -q "$FS" ; then
    true
else
    echo "It seems, $FS is not mounted ..Please verify"
    exit 1;
fi
echo " ";df -hTP $FS
echo -e "\033[1m\nLarge Directories in $FS Filesystem\n\033[0m" ;du -xh $FS --max-depth=2  2>/dev/null |sort -rh|sed "1d"|head -5
echo -e "\033[1m\nLarge files in $FS Filesystem\n\033[0m";find $FS -xdev -size +1024 -ls | awk '{ print $11 , $5, $7}' |sort -nrk +3 | awk '{ print $3/1024/1024 "MB" "\t| " , $2 "\t| " , $1 }' | head -10
echo -e "\033[1m\nTotal sum of files & dirs within $FS Filesystem\n\033[0m";du -xch  $FS 2>/dev/null| grep total
exit 0;
