#!/usr/bin/env bash

HOSTS="xxx.xxx.xxx.xxx"

COUNT=40

SUBJECT="xxx lost connection and has been reverted to latest snapshot"
EMAILID="xxx@xxx.com"

for myHost in $HOSTS
do
  echo $COUNT
  count=$(ping -c $COUNT $myHost | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
  
  if [ $count -eq 0 ]; then
    
    sshpass -p 'xxxx' ssh -o StrictHostKeyChecking=no root@xxxx vim-cmd vmsvc/power.reset 14
    echo "VM Reset"
    sleep 60
    echo "Rsync to BackupBox"
    sshpass -p 'xxxx' ssh -o StrictHostKeyChecking=no root@xxxx rsync -aAv /var/log/xxxx /BackupBox4/xxx
    sleep 20
    sshpass -p 'xxxxx' ssh -o StrictHostKeyChecking=no root@xxxxxx vim-cmd vmsvc/snapshot.revert 14 15 suppressPowerOn
    echo "Reverting to Snapshot"
    sleep 60
    echo "Host : $myHost is down (ping failed) at $(date). Log files saved to  /BackupBox4/xxx & Snapshot restored!" | mail -s "$SUBJECT" $EMAILID
  fi
  
done
