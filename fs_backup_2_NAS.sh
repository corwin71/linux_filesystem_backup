#!/bin/bash

dname=`date '+%Y%m%d%H%M%S'`
__Filename=sharebkp_$dname.zip	#префикс файла бекапа
LOGFILE=/u02/share/logs/NASlog/share-bkpNAS-new.log		#путь к логу
PURGEDAY=2  				#Дней хранения бекапов локально
PURGEDAYNAS=10 				#Дней хранения бекапов на внешнем  SMB сервере
__need_copy_to_NAS=1		    	#1 - Копировать на внешний SMB сервер
__NASnetpath=//192.168.1.2/sharebkp   	#UNC путь SMB сервера
__NASpath=/mnt/NAS		   	#точка монтирования SMB сервера
__NASusername=backuper
__NASpassword=password
__SourceD="/u02/share/"	    	#Путь к файлам для резервирования (/ в конце)
__TargetD="/extstorage/backups/sharebkp"     	#Путь, куда будут складываться бекапы на локальном сервере (/ в конце) 
__email="test@test.com"

echo  >$LOGFILE
echo "====================================================="  >>$LOGFILE
echo "$(date)" >>$LOGFILE
echo "Info. Backup started." >>$LOGFILE

OLD_IFS=$IFS
IFS=$'\n'

#tar -czf $__TargetD/$__Filename $__SourceD &>>$LOGFILE
zip  -r  $__TargetD/$__Filename $__SourceD 2>>$LOGFILE

STATUS=$?
IFS=$OLD_IFS
if [[ $STATUS != 0 ]]; then
    echo "$(date)" >>$LOGFILE
    echo "Achtung! Backup error!" >>$LOGFILE
    cat $LOGFILE | mail -v -s "share backup error!" $__email

else
    echo "$(date)" >>$LOGFILE
    echo "Ok. Tar execute complete." >>$LOGFILE

	if  [[ $__need_copy_to_NAS -ne 1 ]]; then
		echo "Info. Delete old backups local. " >>$LOGFILE
		find $__TargetD/ -type f -mtime +$PURGEDAY -exec rm -rf {} \; &>>$LOGFILE
		ls -ls $__TargetD>> $LOGFILE
		echo "Info. Backup process end." >>$LOGFILE
		exit
	fi
echo "Info. Mount external server." >>$LOGFILE
echo "External server path=$__NASnetpath">>$LOGFILE
mount -t cifs -o user=$__NASusername,pass=$__NASpassword $__NASnetpath $__NASpath  &>>$LOGFILE
    if [[ $? != 0 ]]; then
	echo "$(date)" >>$LOGFILE
        echo "Achtung!	Mounting NAS error!" >>$LOGFILE
        cat $LOGFILE | mail -v -s "share backup error!" $__email
        exit
    fi
	echo "$(date)" >>$LOGFILE
    	echo "Ok. Begin copy to NAS." >>$LOGFILE
echo    	cp -f $__TargetD/$__Filename $__NASpath &>>$LOGFILE
    	
    	cp -f $__TargetD/$__Filename $__NASpath &>>$LOGFILE
    if [[ $? != 0 ]]; then
	echo "$(date)" >>$LOGFILE
        echo "Achtung! Copy to NAS error!" >>$LOGFILE
        cat $LOGFILE | mail -v -s "share backup error!" $__email
    else
	echo "$(date)" >>$LOGFILE
        echo "Ok. Copy to NAS complete." >>$LOGFILE

    fi
fi  #backup completed check

# delete backup from NAS
echo "Info. Delete old backups NAS. " >>$LOGFILE
find $__NASpath/ -type f -mtime +$PURGEDAYNAS -exec rm -rf {} \; &>>$LOGFILE

echo "Info. Umount NAS " >>$LOGFILE
umount $__NASpath &>>$LOGFILE

echo "$(date)" >>$LOGFILE
echo "Info. Backup process end." >>$LOGFILE

exit