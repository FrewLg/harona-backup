#!/bin/bash
BKP_USER="root"
#password
BKP_PASS="databasePassword"
firstnow="$(date +'%d-%m-%Y %H:%M:%S')"
now="$(date +'%d_%m_%Y_%H_%M_%S')"
backupfolder="/var/www/harona/logs/"
fullpathbackupfile="$backupfolder/$filename"
email_logfolder="/var/www/harona/email_log/"
chmod  -R 777  "$email_logfolder/."
email_log="$email_logfolder"email_log.txt
#chmod  -R 777  "$email_logfolder/."
#chmod  -R 777  $email_log
logfile="$backupfolder/"backup_log.txt
BKP_DATE="$(date +"%d-%m-%Y")Database"
BKP_DEST="/var/www/harona/database/$BKP_DATE/"
BKP_DAYS="90"
MYSQL_HOST="localhost"
IGNORE_DB="phpmyadmin information_schema mysql performance_schema"
[ ! -d $BKP_DEST ] && mkdir -p $BKP_DEST || :
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

#
###################### Get database list ################################
#
DB_LIST="$($MYSQL -u $BKP_USER -h $MYSQL_HOST -p$BKP_PASS -Bse 'show databases')"
#
for db in $DB_LIST
do
    skipdb=-1
    if [ "$IGNORE_DB" != "" ];
    then
	for i in $IGNORE_DB
	do
	    [ "$db" == "$i" ] && skipdb=1 || :
	done
    fi
 
    if [ "$skipdb" == "-1" ] ; then
	BKP_FILENAME="$BKP_DEST/$db.sql.gz"
#
################ Using MYSQLDUMP for bakup and Gzip for compression ###################
#
        $MYSQLDUMP -u $BKP_USER -h $MYSQL_HOST -p$BKP_PASS $db | $GZIP -9 > $BKP_FILENAME
    fi
done


#########To delete all backup files older then BKP_DAYS #################
#
find $BKP_DEST -type f -mtime +$BKP_DAYS -delete
echo "==============    $(date +'%d-%m-%Y')    =============" >> "$logfile"
echo "********* Mysqldump to backup database **********" >> "$logfile"
echo "mysqldump started at $firstnow " >> "$logfile"
echo "mysqldump finished at $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
chown web   "$fullpathbackupfile"
chown web   "$logfile"
chown -R 777  "database/$BKP_DATE" 
chmod  -R 777  "database/$BKP_DATE/."
echo "*******  Database file permission canging ******* " >> "$logfile"
echo "File permission changed at $(date +'%d-%m-%Y %H:%M:%S') " >> "$logfile"
#######################File comporession task here ################################
echo "*********** File compression ******************** " >> "$logfile"
#Start scripting 
SRCDIR=/var/www/html/
#The file or folder to be compressed
DESTDIR="/var/www/harona/resource/"
#The destination folderto put file
FILENAME=$(date  +%d-%m-%Y )_Source.tgz
#The compressed file name after zipped
tar --create --gzip --file=$DESTDIR$FILENAME  $SRCDIR
chown -R 777   $DESTDIR$FILENAME 
########### write to email template ##################
###########################################
echo "File compressed at   $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile"
echo "************** Send emails ********************** " >> "$logfile"
##########################################################################################
################################copy recource and database files #########################
######################## Checking for end to end connectivity ############################
echo "subject:   website resource and database backup notice    $(date +'%d-%m-%Y %H:%M:%S')" >> "email.txt"
echo "to: <emailto1@gmail.com>, <emailto2@gmail.com> " >> "email.txt"
#echo "Dear, sir  " >>  "email.txt"
#######========= destination service to move backup files ==========#####################
IP= "10.140.11.0"
ping -c 3 10.140.1.0  > /dev/null
if [ $? != 0 ]
then 
 
echo "Dear, sir  " >>  "email.txt"
echo "Your destination site seems to be down or disconnected!" >> "email.txt"
echo "Unable to send backup copy to destination  $IP " >>  "email.txt"
else
echo "subject: website resource and database backup notice    $(date +'%d-%m-%Y %H:%M:%S')" >> "email.txt"
echo "to: <emailto1@gmail.com>, <emailto2@gmail.com> " >> "email.txt"
#echo "Dear, sir  " >>  "email.txt"

echo "Dear, sir  " >>  "email.txt"
fi
scp -r $DESTDIR$FILENAME     'ghost@ip.address:/home/ghost/Desktop/webresource'
scp -r $BKP_DEST    'ghost@ip.address:/home/ghost/Desktop/webdb'
echo "The      database has been copied  to the local computer successfully! at  $(date +'%d-%m-%Y %r') " >>  "email.txt"

echo "Regards, " >>  "email.txt"
echo "Admin" >>  "email.txt"
curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
 --mail-from 'backup@gmail.com' --mail-rcpt 'emailto1@gmail.com' \
  --upload-file email.txt  --user 'backup@gmail.com:password' --insecure
rm -r email.txt
#########################################################################################
echo "************** Copy backup files to the local computer ********************* " >> "$logfile"
echo "Copying backup files to the local computer performed successfully! at  $(date +'%d-%m-%Y %H:%M:%S') " >> "$logfile"
###################################Email all tasks has been done #################
echo "Email sent at   $(date +'%d-%m-%Y %H:%M:%S')" >> "$logfile" 
##################################### end Emailing ############### email.txt####################
rm -r resource/*
rm -r /var/www/harona/resource/*
rm -r /var/www/harona/docs/*
rm -r /var/www/harona/database/*
exit 0

