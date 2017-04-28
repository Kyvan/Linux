#!/bin/bash -u

function syslogConfig() {
	read -p "How manu clients are connecting to this SYSLOG server? " num
	for ( i = 0 ; i < $num ; i++ ) ; do
		read -p "What is the IP of the client sending the logs? " cip
		read -p "What is the client hostname? " chn
		echo -e "\$ModLoad imtcp\n" >> /etc/rsyslog.conf
		sed -i "2i \ " /etc/rsyslog.conf
		sed -i "3i \$InputTCPServerRun 514" /etc/rsyslog.conf
		sed -i "4i \ " /etc/rsyslog.conf
		sed -i "5i if (\$fromhost-ip startswith $cip) then {" /etc/rsyslog.conf 
		sed -i "6i # email-messages" /etc/rsyslog.conf""
		sed -i "7i #" /etc/rsyslog.conf   ""
		sed -i "8i mail.*\	\	\	-/var/log/$chn/mail" /etc/rsyslog.conf
		sed -i "9i mail.info\	\	\	-/var/log/$chn/mail.info" /etc/rsyslog.conf
		sed -i "10i mail.warning\	\	\	-/var/log/$chn/mail.warn" /etc/rsyslog.conf
		sed -i "11i mail.err\	\	\	/var/log/$chn/mail.err" /etc/rsyslog.conf
		sed -i "12i \ " /etc/rsyslog.conf
		sed -i "13i \ " /etc/rsyslog.conf
		sed -i "14i #" /etc/rsyslog.conf""
		sed -i "15i #" news-messages /etc/rsyslog.conf
		sed -i "16i #" /etc/rsyslog.conf""
		sed -i "17i news.crit\	\	\	-/var/log/$chn/news/news.crit" /etc/rsyslog.conf
		sed -i "18i news.err\	\	\	-/var/log/$chn/news/news.err" /etc/rsyslog.conf
		sed -i "19i news.notice\	\	\	-/var/log/$chn/news/news.notice" /etc/rsyslog.conf
		sed -i "20i # enable this, if you want to keep all news messages" /etc/rsyslog.conf
		sed -i "21i # in one file" /etc/rsyslog.conf
		sed -i "22i #news.*\	\	\	-/var/log/$chn/news.all" /etc/rsyslog.conf
		sed -i "23i \ " /etc/rsyslog.conf
		sed -i "24i \ " /etc/rsyslog.conf
		sed -i "25i #" /etc/rsyslog.conf
		sed -i "26i # Warnings in one file" /etc/rsyslog.conf
		sed -i "27i #" /etc/rsyslog.conf
		sed -i "28i *.=warning;*.=err\	\	\	-/var/log/$chn/warn" /etc/rsyslog.conf
		sed -i "29i *.crit\	\	\	/var/log/$chn/warn"  /etc/rsyslog.conf
		sed -i "30i \ " /etc/rsyslog.conf
		sed -i "31i \ " /etc/rsyslog.conf
		sed -i "32i #" /etc/rsyslog.conf
		sed -i "33i # the rest in one file" /etc/rsyslog.conf
		sed -i "34i #" /etc/rsyslog.conf
		sed -i "35i *.*;mail.none;news.none\	\	\	-/var/log/$chn/messages" /etc/rsyslog.conf
		sed -i "36i \ " /etc/rsyslog.conf
		sed -i "37i \ " /etc/rsyslog.conf
		sed -i "38i #" /etc/rsyslog.conf
		sed -i "39i # Some foreign boot scripts require local7" /etc/rsyslog.conf
		sed -i "40i #" /etc/rsyslog.conf
		sed -i "41i local0.*;local1.*\	\	\	-/var/log/$chn/localmessages" /etc/rsyslog.conf
		sed -i "42i local2.*;local3.*\	\	\	-/var/log/$chn/localmessages" /etc/rsyslog.conf
		sed -i "43i local4.*;local5.*\	\	\	-/var/log/$chn/localmessages" /etc/rsyslog.conf
		sed -i "44i local6.*;local7.*\	\	\	-/var/log/$chn/localmessages" /etc/rsyslog.conf
		sed -i "45i \ " /etc/rsyslog.conf
		sed -i "46i ###" /etc/rsyslog.conf
		sed -i "47i }" /etc/rsyslog.conf
		sed -i "48i stop" /etc/rsyslog.conf
		sed -i "49i \ " /etc/rsyslog.conf
	done
	systemctl restart rsyslog
	systemctl enable rsyslog
}

if rpm -qa | grep -q rsyslog ; then
	syslogConfig
else
	yum install -y rsyslog
	syslogConfig
fi
