#!/bin/bash -u

read -p "What is the domain name of the rsyslog server? " dsn
read -p "Who should receive the emails? " name
read -p "What is the destination IP address or hotname? " iph
read -p "What is the destination port number? " port

sed -i "48i *.*	$iph:$port" /etc/rsyslog.conf

echo -e "$ModLoad ommail\n" >> /etc/rsyslog.d/remote.conf
sed -i "2i \ " /etc/rsyslog.d/remote.conf
sed -i "3i $ActionMailSMTPServer mail.$dsn" /etc/rsyslog.d/remote.conf
sed -i "4i $ActionMailFrom rsyslog@$dsn" /etc/rsyslog.d/remote.conf
sed -i "5i $ActionMailTo $name@$dsn" /etc/rsyslog.d/remote.conf
sed -i "6i \ " /etc/rsyslog.d/remote.conf
sed -i "7i $template mailSubject,\"SUDO used on %hostname%\"" /etc/rsyslog.d/remote.conf
sed -i "8i $template mailBody,\"RSYSLOG Alert\\r\\nmsg='%msg%'\"" /etc/rsyslog.d/remote.conf
sed -i "9i \ " /etc/rsyslog.d/remote.conf
sed -i "10i $ActionMailSubject mailSubject" /etc/rsyslog.d/remote.conf
sed -i "11i \ " /etc/rsyslog.d/remote.conf
sed -i "12i $ActionExecOnlyOnceEveryInterval 3600" /etc/rsyslog.d/remote.conf
sed -i "13i \ " /etc/rsyslog.d/remote.conf
sed -i "14i if $msg contains ' user NOT in sudoers ' then :ommail:;mailBody" /etc/rsyslog.d/remote.conf
sed -i "15i ActionExecOnlyOnceEveryInterval 0" /etc/rsyslog.d/remote.conf
