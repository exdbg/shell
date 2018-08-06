#!/usr/bin/env bash
NUM1=10000000
NUM2=3600
NUM3=24
NUM4=90

if [ -s yad ];then
        > yad
fi

/usr/bin/ldapsearch -H ldap://xxx.com -Y GSSAPI -N -b ou=xxx,dc=xxx,dc=com '(&(objectClass=user)(userAccountControl=512))'|grep pwdLastSet|awk -F ":" '{print $2}'> day

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

/usr/bin/ldapsearch -H ldap://xxx.com -Y GSSAPI -N -b ou=xxx,dc=xxx,dc=com '(&(objectClass=user)(userAccountControl=512))'|grep userPrincipalName|awk -F ":" '{print $2}' > email

paste -d " " email yad > join

while read i k
        do
        if [[ "$k" -lt 5 && "$k" -gt 0 ]];then
         echo -e "Hi,\nYour xxx domain passord will exprie within $k days, please consider change your password ASAP.\n" | mail -s 'Password Expiration Reminder' $i

                fi
done < join

exit 0

