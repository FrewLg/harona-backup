#!/bin/bash
IP= "10.140.11.171"

backupfolder="/var/www/harona/logs/"

logfile="$backupfolder/"backup_log.txt


echo "subject: Test end-to-end connectivity   $(date +'%d-%m-%Y %H:%M:%S')" >> "email2.txt"
echo "to: <firewlegese74@gmail.com>, <firewlegese14@gmail.com> " >> "email2.txt"
echo "Dear, sir  " >>  "email.txt"
ping -c 3 10.140.11.171  > /dev/null
if [ $? != 0 ]
then
IP= "10.140.11.171"
echo "The destination service (local IP [ $IP ] )site seems to be down  at  $(date +'%d-%m-%Y %H:%M:%S')"  >> "$logfile"
echo "Your Service (local [ $IP ] )site seems to be down" >> "email2.txt"
echo "The destination service is not responding! Please check the local system is standby and ready to  receive backup files  " >>  "email2.txt"
echo "Regards, " >>  "email2.txt"
echo "Admin" >>  "email2.txt"
echo "This is autogenerated email, Please donot reply!" >>  "email2.txt"
curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
 --mail-from 'juservicesbackup@gmail.com' --mail-rcpt 'firewlegese12@gmail.com' \
 --mail-rcpt 'firewlegese74@gmail.com'   --mail-rcpt 'firewlegese14@gmail.com' \
 --upload-file email2.txt  --user 'juservicesbackup@gmail.com:Ba9M7A55' --insecure

fi
rm -r email2.txt