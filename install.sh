#!/bin/bash
#!/bin/bash
 
#------------------------------------------------------------------------------------
# Install vsFTPd
#------------------------------------------------------------------------------------
 
yum install -y vsftpd
systemctl enable vsftpd.service
mkdir -p /etc/vsftpd/vconf
 
#------------------------------------------------------------------------------------
# Configure vsFTPd data directory and user
#------------------------------------------------------------------------------------
 
mkdir -p /data/ftp
useradd -s /sbin/nologin -d /data/ftp vsftpd
chown -R vsftpd:vsftpd /data/ftp
 
#------------------------------------------------------------------------------------
# Configure vsFTPd (/etc/vsftpd/vsftpd.conf)
#------------------------------------------------------------------------------------
 
cp /etc/vsftpd/vsftpd.conf{,.original}
 
sed -i "s/^.*anonymous_enable.*/anonymous_enable=NO/g" /etc/vsftpd/vsftpd.conf
sed -i "/^xferlog_std_format*a*/ s/^/#/" /etc/vsftpd/vsftpd.conf
sed -i "s/#idle_session_timeout=600/idle_session_timeout=900/" /etc/vsftpd/vsftpd.conf
sed -i "s/#nopriv_user=ftpsecure/nopriv_user=vsftpd/" /etc/vsftpd/vsftpd.conf
sed -i "/#chroot_list_enable=YES/i\chroot_local_user=YES" /etc/vsftpd/vsftpd.conf
sed -i 's/listen=NO/listen=YES/' /etc/vsftpd/vsftpd.conf
sed -i 's/listen_ipv6=YES/listen_ipv6=NO/' /etc/vsftpd/vsftpd.conf
 
echo 'allow_writeable_chroot=YES
guest_enable=YES
guest_username=vsftpd
local_root=/data/ftp/$USER
user_sub_token=$USER
virtual_use_local_privs=YES
user_config_dir=/etc/vsftpd/vconf' >> /etc/vsftpd/vsftpd.conf
 
systemctl start vsftpd.service
 
#------------------------------------------------------------------------------------
# Configure pam (/etc/pam.d/vsftpd)
#------------------------------------------------------------------------------------
 
cp /etc/pam.d/vsftpd{,.original}
 
echo '#%PAM-1.0
auth required pam_userdb.so db=/etc/vsftpd/password crypt=crypt
account required pam_userdb.so db=/etc/vsftpd/password crypt=crypt
session required pam_loginuid.so' > /etc/pam.d/vsftpd
 
#------------------------------------------------------------------------------------
# Configure firewalld
#------------------------------------------------------------------------------------
 
yum install -y firewalld
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --permanent --add-service=ftp
firewall-cmd --reload
 
#------------------------------------------------------------------------------------
# Configure selinux
#------------------------------------------------------------------------------------
 
setsebool -P ftpd_full_access 1
