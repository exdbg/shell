#!/usr/bin/env bash
export HISTFILESIZE=4000
export HISTTIMEFORMAT="%Y-%m-%d:%H:%M:%S `whoami` "


#history
USER_IP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's@[()]@@g'`
HISTDIR=/usr/share/.history
if [ -z $USER_IP ]
then
USER_IP=`hostname`
fi
if [ ! -d $HISTDIR ]
then
mkdir -p $HISTDIR
chmod 777 $HISTDIR
fi
if [ ! -d $HISTDIR/${LOGNAME} ]
then
mkdir -p $HISTDIR/${LOGNAME}
chmod 300 $HISTDIR/${LOGNAME}
fi
export HISTSIZE=4000
DT=`date +%Y%m%d_%H%M%S`
export HISTFILE="$HISTDIR/${LOGNAME}/${USER_IP}.history.$DT"
export HISTTIMEFORMAT="[%Y.%m.%d %H:%M:%S]"
chmod 600 $HISTDIR/${LOGNAME}/*.history* 2>/dev/null
