#!/bin/bash
#Gautam Dhavamani
disk=`df -h | grep -i "/dev/sda2" | awk '{print $(NF-1)}' | sed 's/%//g'`
if [[ "$disk" -ge "85" ]]; then

#Compressing the logs older than 30 days in /var/log/sa/
declare -a dirlistSA=(`find /var/log/sa/* -type d -ctime +30 2> /dev/null`)
# To find the length of an array
#echo ${#dirlistSA[@]}
echo " "
echo "Analyzing logs in /var/log/sa..."
        if [[ ${#dirlistSA[@]} -gt 0 ]]; then
                for dirSA in ${dirlistSA[@]}
                do
                        tempSAPath=`echo $dirSA | sed 's/$/\//'`
                        finalSAPath=`echo $dirSA | sed 's/\/var\/log\/sa\///g'`
                        cd /var/log/sa
                        tar -zcf $finalSAPath.tar.gz $tempSAPath > /dev/null 2>&1
                        rm -rf $tempSAPath
                done
	echo "All the log directories older than 30 days have been compressed successfully under /var/log/sa/"
        else
                echo "There are no log directories older than 30 days to compress in /var/log/sa"
        fi

# Compressing the message logs, if its size is greater than 1 GB under /var/log/messages

declare -a dirlistMessages=(`find /var/log/* -maxdepth 0 -type f | grep messages | grep -v /var/log/messages.*.gz$ 2> /dev/null`)
echo " "
echo "${dirlistMessages[@]}"
echo "Analyzing messages logs..."
        if [[ ${#dirlistMessages[@]} -gt 0 ]]; then
                for dirMessage in ${dirlistMessages[@]}
                do
			if [[ "${dirMessage}" == "/var/log/messages" ]]; then

				messageSize=`du -sh ${dirMessage} | awk '{print $(NF-1)}'`
					if [[ "$messageSize" =~ "G" ]]; then
						messagePath=`echo $dirMessage | sed 's/\/var\/log\///g'`
		        	                cd /var/log/
						if [[ -f "/var/log/messages.gz" ]]; then
							gzip -c $messagePath >> /var/log/messages.gz
						else
							gzip $messagePath
						fi
						echo "Compressing $dirMessage"
						touch $dirMessage
						service rsyslog restart
						sleep 5
						echo "Created new /var/log/messages file and restarted the rsyslog services for the changes to get reflected ..."
					else
						echo "The $dirMessage has not exceeded 1GB. Hence skipping this file from compressing"

					fi			
			else
	
				 messageSize=`du -sh $dirMessage | awk '{print $(NF-1)}'`
                                        if [[ "$messageSize" =~ "G" ]]; then
                                                messagePath=`echo $dirMessage | sed 's/\/var\/log\///g'`
                                                cd /var/log/
                                                gzip $messagePath
                                                echo "Compressing $dirMessage..."
                                        else
                                        	echo "The $dirMessage has not exceeded 1GB. Hence skipping this file from compressing"

                                        fi
			fi

                done
        fi

# Compressing the atop logs, if its size is greater than 1 GB under /var/log/atop

declare -a dirlistAtop=(`find /var/log/atop/* -type d`)
#echo ${#dirlistAtop[@]}
echo " "
echo "Analyzing atop logs..."
	if [[ ${#dirlistAtop[@]} -gt 0 ]]; then
		
		sizeAtop=`du -sh /var/log/atop/ | awk '{print $(NF-1)}'`
		if [[ "$sizeAtop" =~ "G" ]]; then
		
			atopStatusBefore=`service atop status | cut -d ")" -f1 | awk '{print $(NF)}'` 
			/etc/init.d/atop restart
			sleep 5
			atopStatusAfter=`service atop status | cut -d ")" -f1 | awk '{print $(NF)}'`
				if [[ $atopStatusBefore != $atopStatusAfter ]]; then
					echo "atop logs size exceeded greater than 1 GB. Hence restarted the atop services"
				fi

		fi
	else
		echo "There are no atop logs to compress in /var/log/atop/"
		echo "    "
	fi

else
	echo "The current size of the root partition has not exceeded the threshold limit of 85%"
	echo "          "

fi
