#!/bin/bash 
echo  "USB backup routine for copying local sondrel ZFS pool and LVM volumes to USB raid array mounted at /BackupBox"

# Set path variable up so we can find things
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/usr/x86_64-pc-linux-gnu/gcc-bin/4.7.3"


if [  -f /run/backup2.sh.pid ]; then
    echo "Pid file found in /run exiting"
	exit 1
fi

MOUNTED=$(cat /proc/mounts | grep /BackupBox)

if [ -z  "$MOUNTED" ]; then
	echo "backup box not mounted exiting"
	exit 2
fi
	

echo $$ >> /run/backup2.sh.pid


# whats the pool name
POOL="xxx"
#DAY=`/bin/date +'%a'`

echo "Starting with ZFS volumes"

echo " remove any old backup ZFS snapshots"
zfs destroy -r "$POOL@USB2"
echo " cleaned creating fresh ones for backup"
zfs snapshot -r "$POOL@USB2"


for LISTING in $(ls -1d /xxx/*/.zfs/snapshot/USB2)
do
    OUTPUT2=$(echo $LISTING | cut -d "." -f1 )
    OUTPUT=$(echo $OUTPUT2 | cut -d "/" -f3)
    echo "processing $OUTPUT"
    rsync -aAv  --delete-before $LISTING/  /BackupBox/$OUTPUT/    | mailx  -s "Backup volume information $OUTPUT"  it@xxx.com
	sync; sync; sync;

done

zfs destroy -r "$POOL@USB2"

echo "completed ZFS volumes starting LVM processes"
echo "remove all snapshots created with bk_ prefix from any failed previous backups"
for RemoveMe in $(lvs --aligned -o lv_path 2>/dev/null | grep bk_ )
do
    lvremove -f $RemoveMe 2>/dev/null

done

# do backups for all volumes in the lvm group
for VolumesToBackup in $(lvs -o lv_path,lv_name,vg_name --noheadings --separator : 2> /dev/null )
do

        Device=$(echo $VolumesToBackup | cut -d : -f 1) 
        Name=$(echo $VolumesToBackup | cut -d : -f 2)
        VolumeGroup=$(echo $VolumesToBackup | cut -d : -f 3)

        lvcreate -L100G  -n bk_$Name  -s  $Device 2> /dev/null
        mount -onouuid,ro /dev/$VolumeGroup/bk_$Name  /snapshot
	echo "backing up $Name"
        rsync -aAv  --delete-before /snapshot/  /BackupBox/$Name/ | mailx  -s "Backup volume information $Name" backups@xxx.com 
	sync; sync; sync;
        umount /snapshot

        lvremove -f  /dev/$VolumeGroup/bk_$Name 2> /dev/null


        #lvs --aligned 2>/dev/null

done
echo "completed LVM volumes"

echo "backup complete all user data volumes rsync'd to USB BackupBox"


if [ -f /run/backup2.sh.pid ]; then
    rm /run/backup2.sh.pid
fi
exit 0

