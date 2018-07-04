#!/bin/bash
read -p "Enter Login id: " LID
if [ -f "/etc/vsftpd/vconf/$LID" ];
then 
	echo "User Already exist!! exiting"
	exit 1
else
mkdir -p /data/ftp/$LID
chown -R vsftpd:vsftpd /data/ftp
echo "dirlist_enable=YES
download_enable=YES
local_root=/data/ftp/$LID
write_enable=YES" > /etc/vsftpd/vconf/$LID

echo "$LID" | tee -a /etc/vsftpd/password{,-nocrypt} > /dev/null
myval=$(openssl rand -base64 6)
echo $myval >> /etc/vsftpd/password-nocrypt
echo $(openssl passwd -crypt $myval) >> /etc/vsftpd/password
db_load -T -t hash -f /etc/vsftpd/password /etc/vsftpd/password.db

FTPLID=$(tail -2 /etc/vsftpd/password-nocrypt | sed -n 1p)
FTPPASS=$(tail -2 /etc/vsftpd/password-nocrypt | sed -n 2p)
echo "Your ftp login id is : $FTPLID"
echo "Your ftp password is : $FTPPASS"
fi
