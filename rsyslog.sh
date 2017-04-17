#!/bin/bash -u

read -p "What is the IP of the client sending the logs? " slip

echo -e "$ModLoad imtcp\n" >> /etc/rsyslog.conf
sed -i "2i \ " /etc/rsyslog.conf
sed -i "3i $InputTCPServerRun 514" /etc/rsyslog.conf
sed -i "4i \ " /etc/rsyslog.conf
sed -i "5i if ($fromhost-ip startswith '$slip') then {" /etc/rsyslog.conf 
sed -i "6i # email-messages" /etc/rsyslog.conf
sed -i "7i #" /etc/rsyslog.conf   
sed -i "8i mail.*\	\	\	-/var/log/CentOS/mail" /etc/rsyslog.conf
sed -i "9i mail.info\	\	\	-/var/log/CentOS/mail.info" /etc/rsyslog.conf
sed -i "10i mail.warning\	\	\	-/var/log/CentOS/mail.warn" /etc/rsyslog.conf
sed -i "11i mail.err\	\	\	/var/log/CentOS/mail.err" /etc/rsyslog.conf
sed -i "12i \ ">> /etc/rsyslog.conf
sed -i "13i \ " /etc/rsyslog.conf
sed -i "14i #" /etc/rsyslog.conf
sed -i "15i #" news-messages /etc/rsyslog.conf
sed -i "16i #" /etc/rsyslog.conf
sed -i "17i news.crit\	\	\	-/var/log/CentOS/news/news.crit" /etc/rsyslog.conf
sed -i "18i news.err\	\	\	-/var/log/CentOS/news/news.err" /etc/rsyslog.conf
sed -i "19i news.notice\	\	\	-/var/log/CentOS/news/news.notice" /etc/rsyslog.conf
sed -i "20i # enable this, if you want to keep all news messages" /etc/rsyslog.conf
sed -i "21i # in one file" /etc/rsyslog.conf
sed -i "22i #news.*\	\	\	-/var/log/CentOS/news.all" /etc/rsyslog.conf
sed -i "23i \ ">> /etc/rsyslog.conf
sed -i "24i \ " /etc/rsyslog.conf
sed -i "25i #" /etc/rsyslog.conf
sed -i "26i # Warnings in one file" /etc/rsyslog.conf
sed -i "27i #" /etc/rsyslog.conf
sed -i "28i *.=warning;*.=err\	\	\	-/var/log/CentOS/warn" /etc/rsyslog.conf
sed -i "29i *.crit\	\	\	/var/log/CentOS/warn"  /etc/rsyslog.conf
sed -i "30i \ " /etc/rsyslog.conf
sed -i "31i \ " /etc/rsyslog.conf
sed -i "32i #" /etc/rsyslog.conf
sed -i "33i # the rest in one file" /etc/rsyslog.conf
sed -i "34i #" /etc/rsyslog.conf
sed -i "35i *.*;mail.none;news.none\	\	\	-/var/log/CentOS/messages" /etc/rsyslog.conf
sed -i "36i \ " /etc/rsyslog.conf
sed -i "37i \ " /etc/rsyslog.conf
sed -i "38i  #" /etc/rsyslog.conf
sed -i "39i # Some foreign boot scripts require local7" /etc/rsyslog.conf
sed -i "40i #" /etc/rsyslog.conf
sed -i "41i  local0.*;local1.*\	\	\	-/var/log/CentOS/localmessages" /etc/rsyslog.conf
sed -i "42i local2.*;local3.*\	\	\	-/var/log/CentOS/localmessages" /etc/rsyslog.conf
sed -i "43i local4.*;local5.*\	\	\	-/var/log/CentOS/localmessages" /etc/rsyslog.conf
sed -i "44i local6.*;local7.*\	\	\	-/var/log/CentOS/localmessages" /etc/rsyslog.conf
sed -i "45i \ " /etc/rsyslog.conf
sed -i "46i ###" /etc/rsyslog.conf
sed -i "47i }" /etc/rsyslog.conf
sed -i "48i stop" /etc/rsyslog.conf
sed -i "49i \ " /etc/rsyslog.conf
