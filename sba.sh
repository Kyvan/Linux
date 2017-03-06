#!/bin/sh -u

# Making a script for the SBA to make shit run super duper fast
# Kyvan Emami Tabrizi - 040778865 - emam0009
# March 10thm, 0016

# Function to make interfaces
function intSetup(){
	# Making interface eth2
	echo -e "DEVICE=eth2\n" > /etc/sysconfig/network-scripts/ifcfg-eth2
	sed -i '2i TYPE=Ethernet' /etc/sysconfig/network-scripts/ifcfg-eth2
	sed -i "3i BOOTPROTO=dhcp" /etc/sysconfig/network-scripts/ifcfg-eth2
	sed -i "4i ONBOOT=yes" /etc/sysconfig/network-scripts/ifcfg-eth2

	# Making interface eth3
	echo -e "DEVICE=eth3\n" > /etc/sysconfig/network-scripts/ifcfg-eth3
	sed -i "2i TYPE=Ethernet" /etc/sysconfig/network-scripts/ifcfg-eth3
	sed -i "3i ONBOOT=yes" /etc/sysconfig/network-scripts/ifcfg-eth3
	sed -i "4i BOOTPROTO=none" /etc/sysconfig/network-scripts/ifcfg-eth3
	sed -i "5i IPADDR=172.16.30.$MN" /etc/sysconfig/network-scripts/ifcfg-eth3
	sed -i "6i NETMASK=255.255.0.0" /etc/sysconfig/network-scripts/ifcfg-eth3

	# Stoping and starting required services
	service NetworkManager stop
	chkconfig NetworkManager off
	service iptables stop
	chkconfig iptables off
	service network restart
	chkconfig network on
	sed -i "6s|enforced\(disabled\)|" /etc/selinux/config
}

# Function to make iptables
function fwRules() {
	# Installing nc
	yum install -y nc
		
	# Setting up the rules
	iptables -A INPUT -p tcp --dport 5999 -s 172.16.31.167 -j REJECT
	iptables -A INPUT -p tcp --dport 5999 -s 172.16.31."$MN" -j REJECT
	iptables -A INPUT -p tcp --dport 5999 -j ACCEPT
}

# Function making an FTP server
function FTP() {
	# Asking for the required info for FTP
	read -p "Please choose your FTP third octet number: " FO
	read -p "Please choose the name for FTP Upload directory: " FTPU
	read -p "Please choose the name for FTP Download directory: " FTPD

	# installing FTP service
	yum install -y vsftpd ftp

	# Enabling anonymous uploading
	sed -i "15s/^/# /" /etc/vsftpd/vsftpd.conf
	sed -i "27s/#//" /etc/vsftpd/vsftpd.conf
	
	# Making an Upload and Download directory with appropriate permissions
	mkdir -p /var/ftp/$FTPU
	chmod 777 /var/ftp/$FTPU
	mkdir -p /var/ftp/$FTPD
	chmod 555 /var/ftp/$FTPD

	# Making a file for testing FTP
	echo -e "Kyvan\n" > /var/ftp/$FTPD/readme.ftp
	sed -i "2i emam0009" /var/ftp/$FTPD/readme.ftp
	sed -i "3i Testing to see if user can download from DOWNLOAD folder in FTP directory" /var/ftp/$FTPD/readme.ftp
	
	# creating the alias interface for ftp
	echo -e "DEVICE=eth3:0\n" > /etc/sysconfig/network-scripts/"ifcfg-eth3:0"
	sed -i "2i TYPE=Ethernet" /etc/sysconfig/network-scripts/"ifcfg-eth3:0"
	sed -i "3i ONBOOT=yes" /etc/sysconfig/network-scripts/"ifcfg-eth3:0"
	sed -i "4i BOOTPROTO=none" /etc/sysconfig/network-scripts/"ifcfg-eth3:0"
	sed -i "5i IPADDR=172.16.$FO.$MN" /etc/sysconfig/network-scripts/"ifcfg-eth3:0"
	sed -i "6i NETMASK=255.255.0.0" /etc/sysconfig/network-scripts/"ifcfg-eth3:0"
	
	# Making FTP listen to the aliased interface
	sed -i "117i listen_address=172.16.$FO.$MN" /etc/vsftpd/vsftpd.conf

	# Restarting the network service and ftp service
	service network restart
	service vsftpd restart
	chkconfig vsftpd on
}

# Function to make SSH
function SSH() {
	# Installing SSH
	yum install -y openssh openssh-server openssh-clients
	yum install -y openssl

	# Enabling RSA Authentication
	sed -i "46i PasswordAuthentication yes" /etc/ssh/sshd_config
	sed -i "47i RSAAuthentication yes" /etc/ssh/sshd_config
	
# Restarting SSH
	service sshd restart
	chkconfig sshd on
}

# Function to make DNS
function DNS() {
	# Asking for the info needed for DNS
	read -p "Please enter your First Zone Name: " FZN
	read -p "Please enter your Second Zone Name: " SZN
	read -p "Please enter your Third Zone Name: " TZN
	read -p "Please enter your Zone Name Extension: " ZNE

	# Installing bind
	yum install -y bind

	# Changing the resolv.conf file
	echo -e "search $HN$MN.$ZNE\n" > /etc/resolv.conf
	sed -i "2i nameserver	127.0.0.1" /etc/resolv.conf
	sed -i "3i nameserver	172.16.30.$MN" /etc/resolv.conf
	
	# Fixing /etc/rsyslog.conf file
	sed -i '63i # Save log messages in /var/log/dns.log' /etc/rsyslog.conf
	sed -i '10i daemon.debug	/var/log/dns.log' /etc/rsyslog.conf

	# Making the 1st forward zone
	echo -e "\$TTL 1D\n" > /var/named/$FZN.zone
	sed -i "2i \$ORIGIN $FZN.$ZNE." /var/named/$FZN.zone
	sed -i "3i \	" /var/named/$FZN.zone
	sed -i "4i @	IN	SOA	ns1.$FZN.$ZNE.	dnsadmin.$FZN.$ZNE. (" /var/named/$FZN.zone
	sed -i "5i \	2015013101" /var/named/$FZN.zone
	sed -i "6i \	3H" /var/named/$FZN.zone
	sed -i "7i \	15M" /var/named/$FZN.zone
	sed -i "8i \	1W" /var/named/$FZN.zone
	sed -i "9i \	3H" /var/named/$FZN.zone
	sed -i "10i )" /var/named/$FZN.zone
	sed -i "11i \	" /var/named/$FZN.zone
	sed -i "12i \	IN	NS	ns1.$FZN.$ZNE." /var/named/$FZN.zone
	sed -i "13i \	IN	NS	ns2.$FZN.$ZNE." /var/named/$FZN.zone
	sed -i "14i \	" /var/named/$FZN.zone
	sed -i "15i @	IN	A	172.16.30.$MN" /var/named/$FZN.zone	
	sed -i "16i ns1	IN	A	172.16.30.$MN" /var/named/$FZN.zone
	sed -i "17i ns2	IN	A	172.16.30.$MN" /var/named/$FZN.zone
	sed -i "18i www	IN	A	172.16.30.$MN" /var/named/$FZN.zone

	# Making the 2nd forward zone
	echo -e "\$TTL 1D\n" > /var/named/$SZN.zone
	sed -i "2i \$ORIGIN $SZN.$ZNE." /var/named/$SZN.zone
	sed -i "3i \	" /var/named/$SZN.zone
	sed -i "4i @	1D	IN	SOA	ns1.$SZN.$ZNE.	dnsadmin.$SZN.$ZNE. (" /var/named/$SZN.zone
	sed -i "5i \	2015013101" /var/named/$SZN.zone
	sed -i "6i \	3H" /var/named/$SZN.zone
	sed -i "7i \	15M" /var/named/$SZN.zone
	sed -i "8i \	1W" /var/named/$SZN.zone
	sed -i "9i \	3H" /var/named/$SZN.zone
	sed -i "10i )" /var/named/$SZN.zone
	sed -i "11i \	" /var/named/$SZN.zone
	sed -i "12i \	IN	NS	ns1.$SZN.$ZNE." /var/named/$SZN.zone
	sed -i "13i \	IN	NS	ns2.$SZN.$ZNE." /var/named/$SZN.zone
	sed -i "14i \	" /var/named/$SZN.zone
	sed -i "15i @	IN	A	172.16.30.$MN" /var/named/$SZN.zone	
	sed -i "16i ns1	IN	A	172.16.30.$MN" /var/named/$SZN.zone
	sed -i "17i ns2	IN	A	172.16.30.$MN" /var/named/$SZN.zone
	sed -i "18i ftp	IN	A	172.16.30.$MN" /var/named/$SZN.zone

	# Making the 3rd forward zone
	echo -e "\$TTL 1D\n" > /var/named/$TZN.zone
	sed -i "2i \$ORIGIN $TZN.$ZNE." /var/named/$TZN.zone
	sed -i "3i \	" /var/named/$TZN.zone
	sed -i "4i @	IN	SOA	ns1.$TZN.$ZNE.	dnsadmin.$TZN.$ZNE. (" /var/named/$TZN.zone
	sed -i "5i \	2015013101" /var/named/$TZN.zone
	sed -i "6i \	3H" /var/named/$TZN.zone
	sed -i "7i \	15M" /var/named/$TZN.zone
	sed -i "8i \	1W" /var/named/$TZN.zone
	sed -i "9i \	3H" /var/named/$TZN.zone
	sed -i "10i )" /var/named/$TZN.zone
	sed -i "11i \	" /var/named/$TZN.zone
	sed -i "12i \	IN	NS	ns1.$TZN.$ZNE." /var/named/$TZN.zone
	sed -i "13i \	IN	NS	ns2.$TZN.$ZNE." /var/named/$TZN.zone
	sed -i "14i \	" /var/named/$TZN.zone
	sed -i "15i @	IN	A	172.16.30.$MN" /var/named/$TZN.zone	
	sed -i "16i ns1	IN	A	172.16.30.$MN" /var/named/$TZN.zone
	sed -i "17i ns2	IN	A	172.16.30.$MN" /var/named/$TZN.zone
	sed -i "18i www	IN	A	172.16.30.$MN" /var/named/$TZN.zone
	
	# Making the reverse zone 
	echo -e "\$TTL 1D\n" > /var/named/16.172.zone
	sed -i "2i \$ORIGIN 16.172.IN-ADDR.ARPA." /var/named/16.172.zone
	sed -i "3i \	" /var/named/16.172.zone
	sed -i "4i @		IN	SOA	ns1.$FZN.$ZNE.	dnsadmin.$FZN.$ZNE. (" /var/named/16.172.zone
	sed -i "5i \	2015013101" /var/named/16.172.zone
	sed -i "6i \	3H" /var/named/16.172.zone
	sed -i "7i \	15M" /var/named/16.172.zone
	sed -i "8i \	1W" /var/named/16.172.zone
	sed -i "9i \	3H" /var/named/16.172.zone
	sed -i "10i )" /var/named/16.172.zone
	sed -i "11i \	" /var/named/16.172.zone
	sed -i "12i \	IN	NS	ns1.$FZN.$ZNE." /var/named/16.172.zone
	sed -i "13i \	IN	NS	ns2.$FZN.$ZNE." /var/named/16.172.zone
	sed -i "14i \	IN	NS	ns1.$SZN.$ZNE." /var/named/16.172.zone
	sed -i "15i \	IN	NS	ns2.$SZN.$ZNE." /var/named/16.172.zone
	sed -i "16i \	IN	NS	ns1.$TZN.$ZNE." /var/named/16.172.zone
	sed -i "17i \	IN	NS	ns2.$TZN.$ZNE." /var/named/16.172.zone
	sed -i "18i \	" /var/named/16.172.zone
	sed -i "19i $MN.30	IN	PTR	ns1.$FZN.$ZNE." /var/named/16.172.zone
	sed -i "20i $MN.30	IN	PTR	ns2.$FZN.$ZNE." /var/named/16.172.zone
	sed -i "21i $MN.30	IN	PTR	www.$FZN.$ZNE." /var/named/16.172.zone
	sed -i "22i $MN.30	IN	PTR	ns1.$SZN.$ZNE." /var/named/16.172.zone
	sed -i "23i $MN.30	IN	PTR	ns2.$SZN.$ZNE." /var/named/16.172.zone
	sed -i "24i $MN.30	IN	PTR	ftp.$SZN.$ZNE." /var/named/16.172.zone
	sed -i "25i $MN.30	IN	PTR	ns1.$TZN.$ZNE." /var/named/16.172.zone
	sed -i "26i $MN.30	IN	PTR	ns2.$TZN.$ZNE." /var/named/16.172.zone
	sed -i "27i $MN.30	IN	PTR	ftp.$TZN.$ZNE." /var/named/16.172.zone

	# Making the DNS config file
	echo -e "options {\n" > /etc/named.conf
	sed -i "2i \	listen-on port 53 { 127.0.0.1; 172.16.30.$MN; };" /etc/named.conf
	sed -i "3i \	directory		\"/var/named/\";" /etc/named.conf
	sed -i "4i \	dump-file		\"/var/named/data/cache_dump.db\";" /etc/named.conf
	sed -i "5i \	statistics-file		\"/var/named/data/named_stats.txt\";" /etc/named.conf
	sed -i "6i \	memstatistics-file	\"/var/named/data/named_mem_stats.txt\";" /etc/named.conf
	sed -i "7i \	allow-query		{ localhost; 172.16/16; };" /etc/named.conf
	sed -i "8i \	allow-recursion		{ 172.16/16; };" /etc/named.conf
	sed -i "9i \	recursion		yes;" /etc/named.conf
	sed -i "10i };" /etc/named.conf
	sed -i "11i \	" /etc/named.conf
	sed -i "12i logging {" /etc/named.conf
	sed -i "13i \	channel default_debug {" /etc/named.conf
	sed -i "14i \	\	file \"/var/log/dns.debug\";" /etc/named.conf
	sed -i "15i \	\	severity	dynamic;" /etc/named.conf
	sed -i "16i \	};" /etc/named.conf
	sed -i "17i };" /etc/named.conf
	sed -i "18i \	" /etc/named.conf
	sed -i "19i zone \".\" IN {" /etc/named.conf
	sed -i "20i \	type	hint;" /etc/named.conf
	sed -i "21i \	file	\"named.ca\";" /etc/named.conf
	sed -i "22i };" /etc/named.conf
	sed -i "23i \	" /etc/named.conf
	sed -i "24i zone \"$FZN.$ZNE\" IN {" /etc/named.conf
	sed -i "25i \	type	master;" /etc/named.conf
	sed -i "26i \	file	\"$FZN.zone\";" /etc/named.conf
	sed -i "27i };" /etc/named.conf
	sed -i "28i \	" /etc/named.conf
	sed -i "29i zone \"$SZN.$ZNE\" IN {" /etc/named.conf
	sed -i "30i \	type	master;" /etc/named.conf
	sed -i "31i \	file	\"$SZN.zone\";" /etc/named.conf
	sed -i "32i };" /etc/named.conf
	sed -i "33i \	" /etc/named.conf
	sed -i "34i zone \"$TZN.$ZNE\" IN {" /etc/named.conf
	sed -i "35i \	type	master;" /etc/named.conf
	sed -i "36i \	file	\"$TZN.zone\";" /etc/named.conf
	sed -i "37i };" /etc/named.conf
	sed -i "38i \	" /etc/named.conf
	sed -i "39i zone \"16.172.IN-ADDR.ARPA\" IN {" /etc/named.conf
	sed -i "40i \	type	master;" /etc/named.conf
	sed -i "41i \	file	\"16.172.zone\";" /etc/named.conf
	sed -i "42i };" /etc/named.conf
	sed -i "43i \	" /etc/named.conf
	sed -i "44i zone \"127.0.0.1\" IN {" /etc/named.conf
	sed -i "45i \	type	master;" /etc/named.conf
	sed -i "46i \	file	\"named.localhost\";" /etc/named.conf
	sed -i "47i };" /etc/named.conf
	sed -i "48i \	" /etc/named.conf
	sed -i "49i zone \"1.0.0.127.IN-ADDR.ARPA\" IN {" /etc/named.conf
	sed -i "50i \	type	master;" /etc/named.conf
	sed -i "51i \	file	\"named.loopback\";" /etc/named.conf
	sed -i "52i };" /etc/named.conf
	sed -i "53i \	" /etc/named.conf

	# Changing the hostname
	echo -e "NETWORKING=yes\n" > /etc/sysconfig/network
	sed -i "2i NETWORKING_IPV6=no" /etc/sysconfig/network
	sed -i "3i HOSTNAME=$HN$MN.$ZNE" /etc/sysconfig/network
	sed -i "4i NTPSERVERARGS=iburst" /etc/sysconfig/network

	# Stopping eth2 from overwritting DNS
	sed -i "5i PEERDNS=no" /etc/sysconfig/network-scripts/ifcfg-eth2

	# Restarting the bind service
	chkconfig named on
	service named restart
	service network restart
}

# Function to install and configure IMAP
function IMAP() {
	# Installing IMAP
	yum install -y dovecot
	chkconfig dovecot on

	# Fixing the /etc/dovecot/dovecot.conf
	sed -i "21i protocols = imap" /etc/dovecot/dovecot.conf
	sed -i "28i listen = 127.0.0.1" /etc/dovecot/dovecot.conf

	# Setting up INBOX and Mail Access Group in /etc/dovecot/conf.d/10-mail.conf
	sed -i "25s/.//" /etc/dovecot/conf.d/10-mail.conf
	sed -i "67i #inbox = /var/spool/mail/\$USER" /etc/dovecot/conf.d/10-mail.conf
	sed -i "124i mail_access_groups = mail" /etc/dovecot/conf.d/10-mail.conf

	# Fixing /etc/dovecot/conf.d/10-auth.conf
	sed -i "10i disable_plaintext_auth = no" /etc/dovecot/conf.d/10-auth.conf

	# Installing Squirrelmail
	yum install -y epel-release squirrelmail
	
	# Installing php
	yum install -y php

	# Loading the required PHP modules
	sed -i "9s/$/\	index.php/" 	/etc/httpd/conf/httpd.conf
	sed -i "17i LoadModule		php5_module	 modules/libphp5.so" /etc/httpd/conf/httpd.conf
	sed -i "18i AddHandler		php5-script	.php" /etc/httpd/conf/httpd.conf
	sed -i "19i AddType		text/html	.php" /etc/httpd/conf/httpd.conf
	sed -i "21i LoadModule		alias_module	modules/mod_alias.so" /etc/httpd/conf/httpd.conf
	sed -i "22i LoadModule		authz_host_module	modules/mod_authz_host.so" /etc/httpd/conf/httpd.cong
	sed -i "23i Incklude		conf.d/quirrelmail.conf" /etc/httpd/conf/httpd.conf

	# Starting IMAP
	service dovecot restart
	chkconfig dovecot on
}

# Function to make HTTP
function HTTP() {
	# Asking for required info for HTTP
	read -p "Please enter the First Website's Name: " FWN
	read -p "Please enter the Second Website's Name: " SWN
	read -p "Please enter the Third Website's Name: " TWN
	read -p "Please enter the Secure Website's Name: " ZN
	read -p "Please enter the Website's Extension: " WE

	# Installing HTTP and SSL mod
	yum install -y httpd
	yum install -y mod_ssl

	# Making the document root for the sites
	mkdir -p /var/www/vhosts/www.$FWN.$WE/html
	mkdir -p /var/www/vhosts/www.$FWN.$WE/log
	mkdir -p /var/www/vhosts/www.$SWN.$WE/html
	mkdir -p /var/www/vhosts/www.$SWN.$WE/log
	mkdir -p /var/www/vhosts/www.$TWN.$WE/html
	mkdir -p /var/www/vhosts/www.$TWN.$WE/log
	mkdir -p /var/www/vhosts/secure.$ZN$MN.$WE/html
	mkdir -p /var/www/vhosts/secure.$ZN$MN.$WE/log
	
	# Making the directories for RSA certifications
	mkdir -p /etc/httpd/tls/cert
	mkdir -p /etc/httpd/tls/key/

	# Giving correct permissions to each directory
	chmod 700 /etc/httpd/tls/key
	chmod 755 /etc/httpd/tls/cert

	# Making the certificates for the Secure website
	cd /etc/httpd/tls
	openssl req -x509 -newkey rsa -days 120 -nodes -keyout key/$ZN$MN.key -out cert/$ZN$MN.cert -subj "/O=$ON/OU=$ZN$MN.$WE/CN=secure.$ZN$MN.$WE"
	
	# Making index for localhost
	echo -e "<Title>Server: HTTP, Apache</Title>\n" > /var/www/html/index.html
	sed -i "2i <H1> $HN$MN.$WE<H1>" /var/www/html/index.html

	# Making the index file for the 1st page
	echo -e "<Title>Service: HTTP, Apache</Title>\n" > /var/www/vhosts/www.$FWN.$WE/html/index.html
	sed -i "2i <H1>Server: www.$FWN.$WE</H1>" /var/www/vhosts/www.$FWN.$WE/html/index.html
	sed -i "3i <H2>Host: www.$FWN.$WE</H1>" /var/www/vhosts/www.$FWN.$WE/html/index.html
	sed -i "4i <H2>IP Address: [172.16.30.$MN:80]</H2>" /var/www/vhosts/www.$FWN.$WE/html/index.html
	sed -i "5i <H1>It works, woohoo!!!!!!</H2>" /var/www/vhosts/www.$FWN.$WE/html/index.html

	# Making the index file for the 2nd page
	echo -e "<Title>Service: HTTP, Apache</Title>\n" > /var/www/vhosts/www.$SWN.$WE/html/index.html
	sed -i "2i <H1>Server: www.$SWN.$WE</H1>" /var/www/vhosts/www.$SWN.$WE/html/index.html
	sed -i "3i <H2>Host: www.$SWN.$WE</H1>" /var/www/vhosts/www.$SWN.$WE/html/index.html
	sed -i "4i <H2>IP Address: [172.16.30.$MN:80]</H2>" /var/www/vhosts/www.$SWN.$WE/html/index.html
	sed -i "5i <H1>This freaking thing works, I sure do know what to do!!!!!!!</H2>" /var/www/vhosts/www.$SWN.$WE/html/index.html

	# Making the index file for the 3rd page
	echo -e "<Title>Service: HTTP, Apache</Title>\n" > /var/www/vhosts/www.$TWN.$WE/html/index.html
	sed -i "2i <H1>Server: www.$TWN.$WE</H1>" /var/www/vhosts/www.$TWN.$WE/html/index.html
	sed -i "3i <H2>Host: www.$TWN.$WE</H1>" /var/www/vhosts/www.$TWN.$WE/html/index.html
	sed -i "4i <H2>IP Address: [172.16.30.$MN:80]</H2>" /var/www/vhosts/www.$TWN.$WE/html/index.html
	sed -i "5i <H1>This freaking thing works, I sure do know what to do, or do I????????</H2>" /var/www/vhosts/www.$SWN.$WE/html/index.html

	# Making the index file for secure page
	echo -e "<Title>Service: HTTPS, Apache</Title>\n" > /var/www/vhosts/secure.$ZN$MN.$WE/html/index.html
	sed -i "2i <H1>Server: $HN.$ZN$MN.$WE</H1>" /var/www/vhosts/secure.$ZN$MN.$WE/html/index.html
	sed -i "3i <H2>Host: secure.$ZN$MN.$WE</H1>" /var/www/vhosts/secure.$ZN$MN.$WE/html/index.html
	sed -i "4i <H2>IP Address: [172.16.$AI.$MN:443]</H2>" /var/www/vhosts/secure.$ZN$MN.$WE/html/index.html
	sed -i "5i <H1>This one is so secure the whole message is encrypted, or is it?</H2>" /var/www/vhosts/secure.$ZN$MN.$WE/html/index.html

	# Making HTTP config file
	echo -e "ServerName		$HN$MN.$WE\n" > /etc/httpd/conf/httpd.conf
	sed -i "2i ServerRoot		/etc/httpd" /etc/httpd/conf/httpd.conf
	sed -i "3i User			apache" /etc/httpd/conf/httpd.conf
	sed -i "4i Group			apache" /etc/httpd/conf/httpd.conf
	sed -i "5i Listen			80" /etc/httpd/conf/httpd.conf
	sed -i "6i Listen			443" /etc/httpd/conf/httpd.conf
	sed -i "7i ServerAdmin		webmaster@$HN$MN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "8i DocumentRoot		/var/www/html" /etc/httpd/conf/httpd.conf
	sed -i "9i DirectoryIndex		index.html" /etc/httpd/conf/httpd.conf
	sed -i "10i ErrorLog		logs/error_log" /etc/httpd/conf/httpd.conf
	sed -i "11i LogLevel		info" /etc/httpd/conf/httpd.conf
	sed -i "12i LoadModule		log_config_module	modules/mod_log_config.so" /etc/httpd/conf/httpd.conf
	sed -i "13i TransferLog		logs/access_log" /etc/httpd/conf/httpd.conf
	sed -i "14i LoadModule		mime_module	modules/mod_mime.so" /etc/httpd/conf/httpd.conf
	sed -i "15i LoadModule		dir_module	modules/mod_dir.so" /etc/httpd/conf/httpd.conf
	sed -i "16i LoadModule		ssl_module	modules/mod_ssl.so" /etc/httpd/conf/httpd.conf
	sed -i "17i TypesConfig			/etc/mime.types" /etc/httpd/conf/httpd.conf
	sed -i "18i \	" /etc/httpd/conf/httpd.conf
	sed -i "19i NameVirtualHost		172.16.30.$MN:80" /etc/httpd/conf/httpd.conf
	sed -i "20i \	" /etc/httpd/conf/httpd.conf

	# Making 1st Virtual Hosts
	sed -i "21i <VirtualHost 172.16.30.$MN:80>" /etc/httpd/conf/httpd.conf
	sed -i "22i ServerName              www.$FWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "23i ServerAlias             $FWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "24i DocumentRoot            /var/www/vhosts/www.$FWN.$WE/html" /etc/httpd/conf/httpd.conf
	sed -i "25i DirectoryIndex		index.html" /etc/httpd/conf/httpd.conf
	sed -i "26i ErrorLog                logs/error_log" /etc/httpd/conf/httpd.conf
	sed -i "27i </VirtualHost>" /etc/httpd/conf/httpd.conf
	sed -i "28i \	" /etc/httpd/conf/httpd.conf
	
	# Making 2nd Virtual Host
	sed -i "29i <VirtualHost 172.16.30.$MN:80>" /etc/httpd/conf/httpd.conf
	sed -i "30i ServerName              www.$SWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "31i ServerAlias             $SWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "32i DocumentRoot            /var/www/vhosts/www.$SWN.$WE/html" /etc/httpd/conf/httpd.conf
	sed -i "33i DirectoryIndex		index.html" /etc/httpd/conf/httpd.conf
	sed -i "34i ErrorLog                logs/error_log" /etc/httpd/conf/httpd.conf
	sed -i "35i </VirtualHost>" /etc/httpd/conf/httpd.conf
	sed -i "36i \	" /etc/httpd/conf/httpd.conf

	# Making HTTPS Virtual Host
	sed -i "37i <VirtualHost 172.16.$AI.$MN:443>" /etc/httpd/conf/httpd.conf
	sed -i "38i ServerName              secure.$ZN$MN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "39i DocumentRoot            /var/www/vhosts/secure.$ZN$MN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "40i DirectoryIndex		html/index.html" /etc/httpd/conf/httpd.conf
	sed -i "41i SSLCertificateFile      tls/cert/$ZN$MN.cert" /etc/httpd/conf/httpd.conf
	sed -i "42i SSLCertificateKeyFile   tls/key/$ZN$MN.key" /etc/httpd/conf/httpd.conf
	sed -i "43i SSLProtocol             -all    +TLSv1  +SSLv3" /etc/httpd/conf/httpd.conf
	sed -i "44i SSLEngine               On" /etc/httpd/conf/httpd.conf
	sed -i "45i </Virtualhost>" /etc/httpd/conf/httpd.conf
	sed -i "46i \	" /etc//httpd/conf/httpd.conf

	# Making 3rd Virtual Host
	sed -i "47i <VirtualHost 172.16.30.$MN:80>" /etc/httpd/conf/httpd.conf
	sed -i "48i ServerName              www.$TWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "49i ServerAlias             $TWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "50i DocumentRoot            /var/www/vhosts/www.$SWN.$WE/html" /etc/httpd/conf/httpd.conf
	sed -i "51i DirectoryIndex		index.html" /etc/httpd/conf/httpd.conf
	sed -i "52i ErrorLog                logs/error_log" /etc/httpd/conf/httpd.conf
	sed -i "53i </VirtualHost>" /etc/httpd/conf/httpd.conf

	# Adding sites to /etc/hosts files
	sed -i "3i 172.16.30.$MN    $HN$MN.$WE www.$FWN.$WE www.$SWN.$WE $HN" /etc/hosts
		
	# Starting HTTP service
	service httpd restart
	chkconfig httpd on
}

# Function to install and configure postfix
function POSTFIX() {
	# Asking for needed info for postfix
	read -p "Please choose your Mail Hostname: " MH
	read -p "Please choose your Mail Hostname Extension: " MHE

	# Installing postfix and mailx
	yum install -y postfix mailx

	# Editing the config file
	sed -i "113s/#//" /etc/postfix/main.cf
	sed -i "116s/^/# /" /etc/postfix/main.cf
	sed -i "117i smtp_host_lookup = native" /etc/postfix/main.cf
	sed -i "75i myhostname = mail.$MH.$MHE" /etc/postfix/main.cf
	sed -i "83i mydomain = $MH.$MHE" /etc/postfix/main.cf
	sed -i "167s/$/,\ \$mydomain/" /etc/postfix/main.cf
	sed -i "101s/#//" /etc/postfix/main.cf

	# Starting POSTFIX service
	service postfix restart
	chkconfig postfix on
}

# Choosing your to input required info
read -p "Please enter your Magic Number: " MN
read -p "Please enter your HostName: " HN
read -p "Please enter your HostName Extension: " HNE	

function funcRun() {
	# Asking the user to choose a function to run
	read -p "Which function do you want to run (1- fwRules, 2- intSetup, 3- FTP, 4- SSH. 5- DNS, 6- IMAP, 7- HTTP, 8- POSTFIX, 9- All the scripts, [Press any other key to exit the script]) > " FR

	# Checking to see which function to run
	if [ "$FR" = 1 ] ; then
		fwRules
		funcRun
	elif [ "$FR" = 2 ]	; then
		intSetup
		funcRun
	elif [ "$FR" = 3 ] ; then
		FTP
		funcRun
	elif [ "$FR" = 4 ] ; then
		SSH
		funcRun
	elif [ "$FR" = 5 ] ; then
		DNS
		funcRun
	elif [ "$FR" = 6 ] ; then
		IMAP
		funcRun	
	elif [ "$FR" = 7 ] ; then
		HTTP
		funcRun
	elif [ "$FR" = 8 ] ; then
		POSTFIX
		funcRun	
	elif [ "$FR" = 9 ] ; then
		fwRules		
		intSetup
		FTP
		SSH
		DNS
		IMAP
		HTTP
		POSTFIX
		funcRun
	else
		break
	fi
}

funcRun
