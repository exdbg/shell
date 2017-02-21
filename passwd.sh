#!/usr/bin/env bash
#Author:Wesker Lu
#Version 1.0
NUM1=10000000
NUM2=3600
NUM3=24
NUM4=90

if [ -s yad ];then
        > yad
fi

/usr/bin/ldapsearch -H ldap://uk-wdc01.sondrel.com -Y GSSAPI -N -b ou=Users,ou=China,ou=Corporate,dc=sondrel,dc=com '(&(objectClass=user)(userAccountControl=512))'|grep pwdLastSet|awk -F ":" '{print $2}'> day

while read line
        do
                DAY=`expr $line / $NUM1 / $NUM2 / $NUM3`
                nowSec=`date +%s`
                pSk=11644473600
                totalSec=$[ $nowSec+$pSk ]
                dayLi=`expr $totalSec / $NUM2 / $NUM3`
                LAST=$[ ($DAY+$NUM4)-$dayLi ]
                echo $LAST >> yad
done < day

/usr/bin/ldapsearch -H ldap://uk-wdc01.sondrel.com -Y GSSAPI -N -b ou=Users,ou=China,ou=Corporate,dc=sondrel,dc=com '(&(objectClass=user)(userAccountControl=512))'|grep userPrincipalName|awk -F ":" '{print $2}' > email

paste -d : email yad > join

while read i k
        do
                if [[ "$k" -lt "5" && "$k" -gt "0" ]];then

                        /usr/sbin/sendmail -t -F Password Check << EOF
                        SUBJECT:You Linux & AD account password will expried soon
                        TO:$i
                        Your Sondrel Linux & AD passord will expried in $k days, please change your password ASAP.

                        IT

EOF
                fi
done < join

