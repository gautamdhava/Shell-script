#!/bin/sh
#Prepared by Gautam Dhavamani
totalmem=`grep -w MemTotal /proc/meminfo | awk '{print $(NF-1)/1024/1024 "G"}'`
m1=`grep -w MemFree /proc/meminfo | awk '{print $(NF-1)}'`
m2=`grep -wi cached /proc/meminfo | awk '{print $(NF-1)}'`
totalswap=`grep -w SwapTotal /proc/meminfo | awk '{print $(NF-1)/1024/1024 "G"}'`
s1=`grep -w SwapFree /proc/meminfo | awk '{print $(NF-1)}'`
s2=`grep -w SwapCached /proc/meminfo | awk '{print $(NF-1)}'`
declare -i M_av="($m1+$m2)";Memory_available=`echo "$M_av" | awk '{ print $0/1024/1024 "G"}'`;declare -i Sw_av="($s1+$s2)";Swap_av=`echo "$Sw_av" | awk '{ print $0/1024/1024 "G"}'`
echo " " ; free -h;echo " ";echo "Total_memory $totalmem" ; echo "Avail_memory $Memory_available";echo "Total_Swap $totalswap";echo Avail_Swap $Swap_av;echo "-----------------------------------";echo "Top Memory Consuming Processes";echo "------------------------------------" ; ps -eo pid,user,comm,%mem --sort=-%mem | head
