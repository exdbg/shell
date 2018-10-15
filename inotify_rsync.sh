#!/bin/bash
host=x.x.x.x
user=root
src='/tmp/src1/'
dest='/tmp/dest1'
inotifywait -mrq -e modify,attrib,moved_to,moved_from,move,move_self,create,delete,delete_self --timefmt='%d/%m/%y %H:%M' --format='%T %w%f %e' $src | while read chgeFile
do
rsync -avPz --delete $src $user@$host:$dest &>>./rsync.log
done

