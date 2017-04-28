#!/bin/bash -u

read -p "What is the domain name of the rsyslog server? " dsn
read -p "Who should receive the emails? " name
read -p "What is the destination IP address or hotname? " iph
read -p "What is the destination port number? " port

function syslogConfig() {
	sed -i "48i *.*	@@$iph:$port" /etc/rsyslog.conf

	echo -e "module(load="builtin:ommail" ...)\n" > /etc/rsyslog.d/remote.conf
	sed -i "2i \$ModLoad ommail" /etc/rsyslog.d/remote.conf
	sed -i "3i \ " /etc/rsyslog.d/remote.conf
	sed -i "4i \$ActionMailSMTPServer mail.$dsn" /etc/rsyslog.d/remote.conf
	sed -i "5i \$ActionMailFrom rsyslog@$dsn" /etc/rsyslog.d/remote.conf
	sed -i "6i \$ActionMailTo $name@$dsn" /etc/rsyslog.d/remote.conf
	sed -i "7i \ " /etc/rsyslog.d/remote.conf
	sed -i "8i \$template mailSubject,\"SUDO used on %hostname%\"" /etc/rsyslog.d/remote.conf
	sed -i "9i \$template mailBody,\"RSYSLOG Alert\\r\\nmsg='%msg%'\"" /etc/rsyslog.d/remote.conf
	sed -i "10i \ " /etc/rsyslog.d/remote.conf
	sed -i "11i \$ActionMailSubject mailSubject" /etc/rsyslog.d/remote.conf
	sed -i "12i \ " /etc/rsyslog.d/remote.conf
	sed -i "13i \$ActionExecOnlyOnceEveryInterval 3600" /etc/rsyslog.d/remote.conf
	sed -i "14i \ " /etc/rsyslog.d/remote.conf
	sed -i "15i if \$msg contains ' user NOT in sudoers ' then :ommail:;mailBody" /etc/rsyslog.d/remote.conf
	sed -i "16i ActionExecOnlyOnceEveryInterval 0" /etc/rsyslog.d/remote.conf
	systemctl restart rsyslog
	systemctl enable rsyslog
}

if rpm -qa | grep -q rsyslog ; then
	syslogConfig
else
	yum install -y rsyslog
	syslogConfig
fi
