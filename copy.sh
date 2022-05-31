SRCDIR="/var/www/harona/muke.txt"
#The file or folder to be compressed
DESTDIR="/home/journals/docs/"
#The destination folderto put file
FILENAME=$(date  +%d-%m-%Y )-_$(date +%-T)_Journals.tgz
#The compressed file name after zipped
tar --create --gzip --file=$DESTDIR$FILENAME  $SRCDIR
chown -R 777   $DESTDIR$FILENAME 
########### write to email template ##################

################################copy recource and database files ###########################
scp -r $DESTDIR$FILENAME     'ghost@10.140.11.171:/home/ghost/Desktop/Abdu'

rm  -r /home/journals/docs/*
