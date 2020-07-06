# Shell-script

#/bin/bash
#Author Gautam Dhavamani
#Script to list large directories and files in a Filesystem, and it should not cross file system boundaries. 

#This while loop ensures to recieve input begins with /

while true; do
    read -p "Please enter the Filesystem name:" FS
    case $FS in
        /*) break;;
        * ) echo -e "Enter absolute path of FS example \"/var\" ";;
esac
done

#We do have challenges while listing top big directories, the output will be in Kb that is not human readable. So I have sorted the top 5 large directories name and size as separate variables later I called both through the for loop.

declare -a dname=`du -a $FS --max-depth=1 --one-file-system 2>/dev/null |sort -nr |sed "1d" | awk '{print $2}' | head -5`
declare -a dsize=`du -a $FS --max-depth=1 --one-file-system 2>/dev/null |sort -nr|sed "1d"| awk '{printf "%.1f \n", $1/1024/1024}' | awk '{print $1 "G"}' | head -5`
set -- $dsize
echo " ";df -PTh $FS
echo " "; echo -e "\033[1mLarge Directories in $FS Filesystem\033[0m" ; echo "------------------------------------------"
for a in $dname
do
    printf "$a\t $1\n"
    shift
done

#this is to list large files in the filesystem, it will list the files ascendingly with large file on top, show filsize, file owner followed by filename. 

echo " " ; echo -e "\033[1mLarge files in $FS Filesystem\033[0m";echo "---------------------------------";find $FS -xdev -size +1024 -ls | awk '{ print $11 , $5, $7}' | sort -nrk +3 | awk '{ print $3/1024/1024 "MB" "\t| " , $2 "\t| " ,  $1 }' | head -10 ; echo "-----------------------------------" ;

#Sometimes we might get confused  as the actual sum of files and directories within the Filesytem should not coincide with FS usage in df -h output.That could be due to open deleted files. You can compare the below output size with the FS usage, if it differs you can act accordingly then. 
echo -e "\033[1mTotal size of files & dirs within $FS Filesystem\033[0m"; echo " ";du -ch --max-depth=1 --one-file-system $FS 2>/dev/null| grep total;

exit 0;
