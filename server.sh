#!/usr/bin/env bash
#Author:Wesker Lu
#Version 1.0
REMOTE_OK=remote_ok
REMOTE_FAIL=remote_fail
TIMESTAMP=`date +%F%H%M%S`
CURRENT_HTML=/var/www/html/${TIMESTAMP}.html
CURRENT_INDEX=/var/www/html/index.html
LN=/bin/ln
SERVER_LIST=server_list
PASS=pass

cat <<EOF > $CURRENT_HTML
<html>
<head>
<title>Server Alive Monitor</title>
</head>
<body>
<table width="50%" border="1" cellpading="1" cellspaceing="0" >
<caption><h2>Server Alive Status</h2></caption>
<tr><th>Server Name</th><th>Server Satus</th><th>Server Load</th></tr>
EOF
while read SERVERS
	do

	REMOTE_RESULT=`sshpass -f $PASS ssh -n root@$SERVERS "uptime"` # "-n" redirects stdin from /dev/null

			if [ $? -eq 0 ];then

				STATUS=OK
				COLOR=blue
				echo $REMOTE_RESULT > $REMOTE_OK
				REMOTE_LOAD=`cat ${REMOTE_OK}| awk -F ":" '{print $4}'`

echo "<tr><td>$SERVERS</td><td><font color=$COLOR>$STATUS</font></td><td>$REMOTE_LOAD</td></tr>" >> $CURRENT_HTML

			else
				STATUS=FALSE
				COLOR=red
				echo "Server is unavailable" > $REMOTE_FAIL
				REMOTE_LOAD=$(cat $REMOTE_FAIL)

echo "<tr><td>$SERVERS</td><td><font color=$COLOR>$STATUS</font></td><td>$REMOTE_LOAD</td></tr>" >> $CURRENT_HTML

			fi

done < $SERVER_LIST

cat <<EOF >> $CURRENT_HTML
</table>
</body>
</html>
EOF

$LN -sf $CURRENT_HTML $CURRENT_INDEX
