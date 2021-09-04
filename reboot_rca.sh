#!/bin/bash
#Devoloped by Gautam Dhavamani
#Script to find the cause of last boot(Reboot RCA) - under devolopment
sep1="echo "-------------------------------------------------------------------""
l2=`last -n2 -x shutdown reboot | awk '{ print $6, $7}' | sed -n 2p | awk '{ print $1}'`
l3=`last -n2 -x shutdown reboot | awk '{ print $6, $7}' | sed -n 2p | awk '{ print $2}'`
l4=`last -n2 -x shutdown reboot | awk '{print $8}' | sed -n 2p`
os=`grep -w VERSION_ID /etc/os-release | cut -d'"' -f 2 | cut -b 1`
dt=`echo $(date) | cut -f 2,3 -d " "`
distr=`grep -w NAME /etc/os-release | egrep -ci "red hat"`

while true; do
    read -p "This script is useful in finding the cause of last boot(Reboot RCA).Do you wish to proceed ? " yn
    case $yn in
        y|Y|Yes|yes|YES) break;;
        n|N|No|no|NO) exit;;
        * ) echo "Please answer yes or no.";;
esac
done

match()
{
        if [[ $? != "0" ]] ;then
                echo "No Matching commands ..."
        fi
        echo " "
}

if [ $USER != 'root' ];then
        echo "You must be root to run $0..Hence Quitting"
        exit 1
fi

if [[ $os -ge "7" && $distr == "1" ]];then
       true
else
        echo " This script is compataible for RHEL 7 and greater versions only... Hence Quitting"
        exit 1
fi

echo -e "\e[1;32m\nLast boot info \e[0m";echo " ";echo "`last -n2 -x shutdown reboot | grep -v wtmp`"

echo -e "\e[1;32m\nCause of last shutdown (Based on Redhat article, https://access.redhat.com/articles/2642741)\e[0m";echo " ";c1=(`last -n2 -x shutdown reboot | awk '{ print $1}' | head -1`);c2=(`last -n2 -x shutdown reboot | awk '{ print $1}' | sed -n 2p`)
if [[ $c1 == $c2 ]];then
        echo -e '\033[1mLast Shutdown was due to Crash it seems\033[0m'
else
        echo -e '\033[1mLast shutdown was Graceful\033[0m'
        crash="n"
fi

echo -e "\e[1;32m\nAudit log last boot info \e[0m"; ausearch -i -m system_boot,system_shutdown | tail -4;
echo -e "\e[1;32m\nJournal logs for last boot info \e[0m";
echo " ";echo "`journalctl -b -1 -n`";echo -e "\e[1;32m\nChecking messages log for errors/cause\n \e[0m";
egrep -i "shut|crash|bug|thermal|signal 15|fatal|SIGTERM|throt|panic|error|warn|halt|stonith|reboot|fenc|token|button|lockup|failure|blocked" /var/log/messages | egrep $l4 | tail -100;$sep1

if [ $crash == "n" ]
then
        echo -e "\e[1;32m\nListing users who logged in at time of last reboot/shutdown \e[0m";echo " "
declare -a f=""
if [[ $l3 -ge 10 ]];then
        echo "`last | egrep "$l2 $l3" | grep $l4 |egrep -v "reboot|shut|wtmp" `"
        f=`last | egrep "$l2 $l3" |egrep $l4 | egrep -v "reboot|shut|wtmp" | awk '{print $1}' | sort -u`
else
        echo "`last | egrep "$l2  $l3" | grep $l4 |egrep -v "reboot|shut|wtmp"`"
        f=`last | egrep "$l2  $l3"| egrep $l4 | egrep -v "reboot|shut|wtmp"| awk '{print $1}' | sort -u`
fi

echo -e "\e[1;32m\nChecking Root user bash history\e[0m";echo " ";egrep -i "shutdown|reboot|poweroff|halt|init|fence|stonith"  /root/.bash_history | egrep -v "last|cat|ausearch|journal|grep|egrep";match;
echo -e "\e[1;32mRelated logs of users who logged in at time of last reboot/shutdown\e[0m";echo " "

for i in ${f[@]}; do echo -e "\033[1m\nSearching \"$i\" bash/secure log history for shutdown/reboot related commands\033[0m"; echo " ";echo -e "\033[1m$i bash_history\n\033[0m" ;egrep -i "shutdown|reboot|poweroff|halt|init|fence|stonith" /home/$i/.bash_history | egrep -v "last|cat|ausearch|journal|grep|egrep"; match; echo " ";echo -e "\033[1m$i command history in secure logs\n\033[0m";grep $i /var/log/secure | grep COMMAND | egrep -i "shutdown|reboot|poweroff|halt|init|fence|stonith" | egrep -v "last|cat|ausearch|journal|grep|egrep";match;echo -e "\033[1m$i session opened\n\033[0m";egrep "session opened" /var/log/secure | grep $i|grep "$l2 $l3" | tail -20;echo -e "\033[1m\nSession closed for $i \n\033[0m";egrep "session closed" /var/log/secure | egrep "$i|root" | grep "$l2 $l3" | tail -20 ;done
else
echo -e "\e[1;32m\nChecking today's sar reports for resource usage\e[0m";echo " "
echo -e "\033[1mCPU\033[0m";echo "              CPU     %user     %nice   %system   %iowait    %steal     %idle";sar -u | grep -i average;$sep1
echo -e "\033[1mIOPS\033[0m";echo "                  tps      rtps      wtps   bread/s   bwrtn/s";sar -b | grep -i average;$sep1
echo -e "\033[1mLoad average(runq)\033[0m";echo "               runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15   blocked";sar -q | grep -i average;$sep1
echo -e "\033[1mMemory\033[0m";echo "         kbmemfree   kbavail kbmemused  %memused kbbuffers  kbcached  kbcommit   %commit  kbactive   kbinact   kbdirty";sar -r | grep -i average
fi

exit 0;
