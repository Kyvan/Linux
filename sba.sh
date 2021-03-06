#!/bin/bash -u

# Making a script for the SBA to make shit run super duper fast
# Kyvan Emami Tabrizi - 040778865 - emam0009
# March 10th, 2016

# Function to make interfaces
intSetup() {
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
	systemctl stop NetworkManager
	systemctl disable NetworkManager
	systemctl stop iptables
	systemctl disable iptables
	systemctl restart network
	systemctl enable network
	sed -i 's/enforcing/disabled/' /etc/selinux/config
}

# Function to make iptables
fwRules() {
	# Installing iptables
	yum install -y iptables
	
	# Disable firewalld
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl start iptables
	systemctl enable iptables

	# Setting up the rules
	iptables -A INPUT -rp tcp --dport 5999 -s 172.16.31.167 -j REJECT
	iptables -A INPUT -rp tcp --dport 5999 -s 172.16.31."$MN" -j REJECT
	iptables -A INPUT -rp tcp --dport 5999 -j ACCEPT
}

# Function making an FTP server
FTP() {
	# Asking for the required info for FTP
	read -rp "Please choose your FTP third octet number: " FO
	read -rp "Please choose the name for FTP Upload directory: " FTPU
	read -rp "Please choose the name for FTP Download directory: " FTPD

	# installing FTP service
	$PKTMGR install -y vsftpd ftp

	# Enabling anonymous uploading
	sed -i "15s/^/# /" /etc/vsftpd/vsftpd.conf
	sed -i "27s/#//" /etc/vsftpd/vsftpd.conf

	# Making an Upload and Download directory with appropriate permissions
	mkdir -p /var/ftp/"$FTPU"
	chmod 777 /var/ftp/"$FTPU"
	mkdir -p /var/ftp/"$FTPD"
	chmod 555 /var/ftp/"$FTPD"

	# Making a file for testing FTP
	echo -e "Kyvan\n" > "/var/ftp/$FTPD/readme.ftp"
	sed -i "2i emam0009" "/var/ftp/$FTPD/readme.ftp"
	sed -i "3i Testing to see if user can download from DOWNLOAD folder in FTP directory" "/var/ftp/$FTPD/readme.ftp"

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
	systemctl restart network
	systemctl restart vsftpd
	systemctl enable vsftpd
	}

# Function to make SSH
SSH() {
	# Installing SSH
	$PKTMGR install -y openssh openssh-server openssh-clients
	$PKTMGR install -y openssl

	# Enabling RSA Authentication
	sed -i "46i PasswordAuthentication yes" /etc/ssh/sshd_config
	sed -i "47i RSAAuthentication yes" /etc/ssh/sshd_config

# Restarting SSH
	systemctl restart sshd
	systemctl enable sshd
}

# Function to make DNS
DNS() {
	# Asking for the info needed for DNS
	read -rp "Please enter your First Zone Name: " FZN
	read -rp "Please enter your Second Zone Name: " SZN
	read -rp "Please enter your Third Zone Name: " TZN
	read -rp "Please enter your Zone Name Extension: " ZNE

	# Installing bind
	$PKTMGR install -y bind

	# Changing the resolv.conf file
	echo -e "search $HN$MN.$ZNE\n" > /etc/resolv.conf
	sed -i "2i nameserver	127.0.0.1" /etc/resolv.conf
	sed -i "3i nameserver	172.16.30.$MN" /etc/resolv.conf

	# Fixing /etc/rsyslog.conf file
	sed -i '63i # Save log messages in /var/log/dns.log' /etc/rsyslog.conf
	sed -i '10i daemon.debug	/var/log/dns.log' /etc/rsyslog.conf

	# Making the 1st forward zone
	echo -e "\$TTL 1D\n" > "/var/named/$FZN.zone"
	sed -i "2i \$ORIGIN $FZN.$ZNE." "/var/named/$FZN.zone"
	sed -i "3i \	" "/var/named/$FZN.zone"
	sed -i "4i @	IN	SOA	ns1.$FZN.$ZNE.	dnsadmin.$FZN.$ZNE. (" "/var/named/$FZN.zone"
	sed -i "5i \	2015013101" "/var/named/$FZN.zone"
	sed -i "6i \	3H" "/var/named/$FZN.zone"
	sed -i "7i \	15M" "/var/named/$FZN.zone"
	sed -i "8i \	1W" "/var/named/$FZN.zone"
	sed -i "9i \	3H" "/var/named/$FZN.zone"
	sed -i "10i )" "/var/named/$FZN.zone"
	sed -i "11i \	" "/var/named/$FZN.zone"
	sed -i "12i \	IN	NS	ns1.$FZN.$ZNE." "/var/named/$FZN.zone"
	sed -i "13i \	IN	NS	ns2.$FZN.$ZNE." "/var/named/$FZN.zone"
	sed -i "14i \	" "/var/named/$FZN.zone"
	sed -i "15i @	IN	A	172.16.30.$MN" "/var/named/$FZN.zone"
	sed -i "16i ns1	IN	A	172.16.30.$MN" "/var/named/$FZN.zone"
	sed -i "17i ns2	IN	A	172.16.30.$MN" "/var/named/$FZN.zone"
	sed -i "18i www	IN	A	172.16.30.$MN" "/var/named/$FZN.zone"

	# Making the 2nd forward zone
	echo -e "\$TTL 1D\n" > "/var/named/$SZN.zone"
	sed -i "2i \$ORIGIN $SZN.$ZNE." "/var/named/$SZN.zone"
	sed -i "3i \	" "/var/named/$SZN.zone"
	sed -i "4i @	1D	IN	SOA	ns1.$SZN.$ZNE.	dnsadmin.$SZN.$ZNE. (" "/var/named/$SZN.zone"
	sed -i "5i \	2015013101" "/var/named/$SZN.zone"
	sed -i "6i \	3H" "/var/named/$SZN.zone"
	sed -i "7i \	15M" "/var/named/$SZN.zone"
	sed -i "8i \	1W" "/var/named/$SZN.zone"
	sed -i "9i \	3H" "/var/named/$SZN.zone"
	sed -i "10i )" "/var/named/$SZN.zone"
	sed -i "11i \	" "/var/named/$SZN.zone"
	sed -i "12i \	IN	NS	ns1.$SZN.$ZNE." "/var/named/$SZN.zone"
	sed -i "13i \	IN	NS	ns2.$SZN.$ZNE." "/var/named/$SZN.zone"
	sed -i "14i \	" "/var/named/$SZN.zone"
	sed -i "15i @	IN	A	172.16.30.$MN" "/var/named/$SZN.zone"
	sed -i "16i ns1	IN	A	172.16.30.$MN" "/var/named/$SZN.zone"
	sed -i "17i ns2	IN	A	172.16.30.$MN" "/var/named/$SZN.zone"
	sed -i "18i ftp	IN	A	172.16.30.$MN" "/var/named/$SZN.zone"

	# Making the 3rd forward zone
	echo -e "\$TTL 1D\n" > "/var/named/$TZN.zone"
	sed -i "2i \$ORIGIN $TZN.$ZNE." "/var/named/$TZN.zone"
	sed -i "3i \	" "/var/named/$TZN.zone"
	sed -i "4i @	IN	SOA	ns1.$TZN.$ZNE.	dnsadmin.$TZN.$ZNE. (" "/var/named/$TZN.zone"
	sed -i "5i \	2015013101" "/var/named/$TZN.zone"
	sed -i "6i \	3H" "/var/named/$TZN.zone"
	sed -i "7i \	15M" "/var/named/$TZN.zone"
	sed -i "8i \	1W" "/var/named/$TZN.zone"
	sed -i "9i \	3H" "/var/named/$TZN.zone"
	sed -i "10i )" "/var/named/$TZN.zone"
	sed -i "11i \	" "/var/named/$TZN.zone"
	sed -i "12i \	IN	NS	ns1.$TZN.$ZNE." "/var/named/$TZN.zone"
	sed -i "13i \	IN	NS	ns2.$TZN.$ZNE." "/var/named/$TZN.zone"
	sed -i "14i \	" "/var/named/$TZN.zone"
	sed -i "15i @	IN	A	172.16.30.$MN" "/var/named/$TZN.zone"
	sed -i "16i ns1	IN	A	172.16.30.$MN" "/var/named/$TZN.zone"
	sed -i "17i ns2	IN	A	172.16.30.$MN" "/var/named/$TZN.zone"
	sed -i "18i www	IN	A	172.16.30.$MN" "/var/named/$TZN.zone"

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
	systemctl enable named
	systemctl restart named
	systemctl restart network
}

# Function to install and configure IMAP
IMAP() {
	# Installing IMAP, Squirrelmail, and PHP
	$PKTMGR install -y dovecot epel-release squirrelmail php
	systemctl enable dovecot

	# Fixing the /etc/dovecot/dovecot.conf
	sed -i "21i protocols = imap" /etc/dovecot/dovecot.conf
	sed -i "28i listen = 127.0.0.1" /etc/dovecot/dovecot.conf

	# Setting up INBOX and Mail Access Group in /etc/dovecot/conf.d/10-mail.conf
	sed -i "25s/.//" /etc/dovecot/conf.d/10-mail.conf
	sed -i "67i #inbox = /var/spool/mail/\$USER" /etc/dovecot/conf.d/10-mail.conf
	sed -i "124i mail_access_groups = mail" /etc/dovecot/conf.d/10-mail.conf

	# Fixing /etc/dovecot/conf.d/10-auth.conf
	sed -i "10i disable_plaintext_auth = no" /etc/dovecot/conf.d/10-auth.conf

	# Loading the required PHP modules
	sed -i "9s/$/\	index.php/" 	/etc/httpd/conf/httpd.conf
	sed -i "17i LoadModule		php5_module	 modules/libphp5.so" /etc/httpd/conf/httpd.conf
	sed -i "18i AddHandler		php5-script	.php" /etc/httpd/conf/httpd.conf
	sed -i "19i AddType		text/html	.php" /etc/httpd/conf/httpd.conf
	sed -i "20i Include		conf.d/squirrelmail.conf" /etc/httpd/conf/httpd.conf

	# Starting IMAP
	systemctl restart dovecot
	systemctl enable dovecot
}

# Function to make HTTP
HTTP() {
	# Asking for required info for HTTP
	read -rp "Please enter the First Website's Name: " FWN
	read -rp "Please enter the Second Website's Name: " SWN
	read -rp "Please enter the Third Website's Name: " TWN
	read -rp "Please enter the Secure Website's Name: " ZN
	read -rp "Please enter the Website's Extension: " WE

	# Installing HTTP and SSL mod
	$PKTMGR install -y httpd mod_ssl

	# Making the document root for the sites
	cd /var/www/vhosts || exit
	mkdir -rp "www.$FWN.$WE/html" "www.$FWN.$WE/log" "www.$SWN.$WE/html" "www.$SWN.$WE/log" "www.$TWN.$WE/html" "www.$TWN.$WE/log" "secure.$ZN$MN.$WE/html" "secure.$ZN$MN.$WE/log"

	# Making the directories for RSA certifications
	mkdir -rp /etc/httpd/tls/cert /etc/httpd/tls/key

	# Giving correct permissions to each directory
	chmod 700 /etc/httpd/tls/key
	chmod 755 /etc/httpd/tls/cert

	# Making the certificates for the Secure website
	cd /etc/httpd/tls || exit
	openssl req -x509 -newkey rsa -days 120 -nodes -keyout key/"$ZN$MN".key -out cert/"$ZN$MN".cert -subj "/O=$ON/OU=$ZN$MN.$WE/CN=secure.$ZN$MN.$WE"

	# Making index for localhost
	echo -e "<Title>Server: HTTP, Apache</Title>\n" > /var/www/html/index.html
	sed -i "2i <H1> $HN$MN.$WE<H1>" /var/www/html/index.html

	# Making the index file for the 1st page
	echo -e "<Title>Service: HTTP, Apache</Title>\n" > "/var/www/vhosts/www.$FWN.$WE/html/index.html"
	sed -i "2i <H1>Server: www.$FWN.$WE</H1>" "/var/www/vhosts/www.$FWN.$WE/html/index.html"
	sed -i "3i <H2>Host: www.$FWN.$WE</H1>" "/var/www/vhosts/www.$FWN.$WE/html/index.html"
	sed -i "4i <H2>IP Address: [172.16.30.$MN:80]</H2>" "/var/www/vhosts/www.$FWN.$WE/html/index.html"
	sed -i "5i <H1>It works, woohoo!!!!!!</H2>" "/var/www/vhosts/www.$FWN.$WE/html/index.html"

	# Making the index file for the 2nd page
	echo -e "<Title>Service: HTTP, Apache</Title>\n" > "/var/www/vhosts/www.$SWN.$WE/html/index.html"
	sed -i "2i <H1>Server: www.$SWN.$WE</H1>" "/var/www/vhosts/www.$SWN.$WE/html/index.html"
	sed -i "3i <H2>Host: www.$SWN.$WE</H1>" "/var/www/vhosts/www.$SWN.$WE/html/index.html"
	sed -i "4i <H2>IP Address: [172.16.30.$MN:80]</H2>" "/var/www/vhosts/www.$SWN.$WE/html/index.html"
	sed -i "5i <H1>This freaking thing works, I sure do know what to do!!!!!!!</H2>" "/var/www/vhosts/www.$SWN.$WE/html/index.html"

	# Making the index file for the 3rd page
	echo -e "<Title>Service: HTTP, Apache</Title>\n" > "/var/www/vhosts/www.$TWN.$WE/html/index.html"
	sed -i "2i <H1>Server: www.$TWN.$WE</H1>" "/var/www/vhosts/www.$TWN.$WE/html/index.html"
	sed -i "3i <H2>Host: www.$TWN.$WE</H1>" "/var/www/vhosts/www.$TWN.$WE/html/index.html"
	sed -i "4i <H2>IP Address: [172.16.30.$MN:80]</H2>" "/var/www/vhosts/www.$TWN.$WE/html/index.html"
	sed -i "5i <H1>This freaking thing works, I sure do know what to do, or do I????????</H2>" "/var/www/vhosts/www.$TWN.$WE/html/index.html"

	# Making the index file for secure page
	echo -e "<Title>Service: HTTPS, Apache</Title>\n" > "/var/www/vhosts/secure.$ZN$MN.$WE/html/index.html"
	sed -i "2i <H1>Server: $HN.$ZN$MN.$WE</H1>" "/var/www/vhosts/secure.$ZN$MN.$WE/html/index.html"
	sed -i "3i <H2>Host: secure.$ZN$MN.$WE</H1>" "/var/www/vhosts/secure.$ZN$MN.$WE/html/index.html"
	sed -i "4i <H2>IP Address: [172.16.30.$MN:443]</H2>" "/var/www/vhosts/secure.$ZN$MN.$WE/html/index.html"
	sed -i "5i <H1>This one is so secure the whole message is encrypted, or is it?</H2>" "/var/www/vhosts/secure.$ZN$MN.$WE/html/index.html"

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
	sed -i "12i Include		conf.modules.d/*.conf" /etc/httpd/conf/httpd.conf
	sed -i "13i Include		conf.d/*.conf" /etc/httpd/conf/httpd.conf
	sed -i "14i TransferLog		logs/access_log" /etc/httpd/conf/httpd.conf
	sed -i "15i TypesConfig			/etc/mime.types" /etc/httpd/conf/httpd.conf
	sed -i "16i \	" /etc/httpd/conf/httpd.conf
	sed -i "17i NameVirtualHost		172.16.30.$MN:80" /etc/httpd/conf/httpd.conf
	sed -i "18i \	" /etc/httpd/conf/httpd.conf

	# Making 1st Virtual Hosts
	sed -i "19i <VirtualHost 172.16.30.$MN:80>" /etc/httpd/conf/httpd.conf
	sed -i "20i ServerName              www.$FWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "21i ServerAlias             $FWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "22i DocumentRoot            /var/www/vhosts/www.$FWN.$WE/html" /etc/httpd/conf/httpd.conf
	sed -i "23i DirectoryIndex		index.html" /etc/httpd/conf/httpd.conf
	sed -i "24i ErrorLog                logs/error_log" /etc/httpd/conf/httpd.conf
	sed -i "25i </VirtualHost>" /etc/httpd/conf/httpd.conf
	sed -i "26i \	" /etc/httpd/conf/httpd.conf

	# Making 2nd Virtual Host
	sed -i "27i <VirtualHost 172.16.30.$MN:80>" /etc/httpd/conf/httpd.conf
	sed -i "28i ServerName              www.$SWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "29i ServerAlias             $SWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "30i DocumentRoot            /var/www/vhosts/www.$SWN.$WE/html" /etc/httpd/conf/httpd.conf
	sed -i "31i DirectoryIndex		index.html" /etc/httpd/conf/httpd.conf
	sed -i "32i ErrorLog                logs/error_log" /etc/httpd/conf/httpd.conf
	sed -i "33i </VirtualHost>" /etc/httpd/conf/httpd.conf
	sed -i "34i \	" /etc/httpd/conf/httpd.conf

	# Making HTTPS Virtual Host
	sed -i "35i <VirtualHost 172.16.30.$MN:443>" /etc/httpd/conf/httpd.conf
	sed -i "36i ServerName              secure.$ZN$MN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "37i DocumentRoot            /var/www/vhosts/secure.$ZN$MN.$WE/html" /etc/httpd/conf/httpd.conf
	sed -i "38i DirectoryIndex		index.html" /etc/httpd/conf/httpd.conf
	sed -i "39i SSLCertificateFile      tls/cert/$ZN$MN.cert" /etc/httpd/conf/httpd.conf
	sed -i "40i SSLCertificateKeyFile   tls/key/$ZN$MN.key" /etc/httpd/conf/httpd.conf
	sed -i "41i SSLProtocol             -all    +TLSv1  +SSLv3" /etc/httpd/conf/httpd.conf
	sed -i "42i SSLEngine               On" /etc/httpd/conf/httpd.conf
	sed -i "43i </Virtualhost>" /etc/httpd/conf/httpd.conf
	sed -i "44i \	" /etc/httpd/conf/httpd.conf

	# Making 3rd Virtual Host
	sed -i "45i <VirtualHost 172.16.30.$MN:80>" /etc/httpd/conf/httpd.conf
	sed -i "46i ServerName              www.$TWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "47i ServerAlias             $TWN.$WE" /etc/httpd/conf/httpd.conf
	sed -i "48i DocumentRoot            /var/www/vhosts/www.$TWN.$WE/html" /etc/httpd/conf/httpd.conf
	sed -i "49i DirectoryIndex		index.html" /etc/httpd/conf/httpd.conf
	sed -i "50i ErrorLog                logs/error_log" /etc/httpd/conf/httpd.conf
	sed -i "51i </VirtualHost>" /etc/httpd/conf/httpd.conf

	# Adding sites to /etc/hosts files
	sed -i "3i 172.16.30.$MN    $HN$MN.$WE www.$FWN.$WE www.$SWN.$WE $HN" /etc/hosts

	# Starting HTTP service
	systemctl restart httpd
	systemctl enable httpd
}

# Function to install and configure postfix
POSTFIX() {
	# Asking for needed info for postfix
	read -rp "Please choose your Mail Hostname: " MH
	read -rp "Please choose your Mail Hostname Extension: " MHE

	# Installing postfix and mailx
	$PKTMGR install -y postfix mailx

	# Editing the config file
	sed -i "113s/#//" /etc/postfix/main.cf
	sed -i "116s/^/# /" /etc/postfix/main.cf
	sed -i "117i smtp_host_lookup = native" /etc/postfix/main.cf
	sed -i "75i myhostname = mail.$MH.$MHE" /etc/postfix/main.cf
	sed -i "83i mydomain = $MH.$MHE" /etc/postfix/main.cf
	sed -i "167s/$/,\ \$mydomain/" /etc/postfix/main.cf
	sed -i "101s/#//" /etc/postfix/main.cf

	# Starting POSTFIX service
	systemctl restart postfix
	systemctl enable postfix
}

# Choosing your to input required info
read -rp "What Package Manager does your Distro use? " PKTMGR
read -rp "Please enter your Magic Number: " MN
read -rp "Please enter your HostName: " HN

# Asking the user to choose a function to run
echo "fwRules"
echo "intSetup"
echo "FTP"
echo "SSH"
echo "DNS"
echo "IMAP"
echo "HTTP"
echo "POSTFIX"
echo "All"
read -rp "Which of the above options are you looking to use? $(echo -e '\n> ')" FR

# Checking to see which function to run
case ${FR,,} in
	fwrules)
		fwRules
	;;
	intsetup)
		intSetup
	;;
	ftp)
		FTP
	;;
	ssh)
		SSH
	;;
	dns)
		DNS
	;;
	imap)
		IMAP
	;;
	http)
		HTTP
	;;
	postfix)
		POSTFIX
	;;
	all)
		fwRules && intSetup && FTP && SSH && DNS && IMAP && HTTP && POSTFIX
	;;
	*)
		echo "Nothing left to do, bye!!"
		;;
esac