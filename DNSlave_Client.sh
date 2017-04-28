# Asking for the DNSlave IP address
read -p "Please choose the Slave DNS third Octet number: " TON
read -p "Please choose the Master Magic Number: " MMN
read -p "Please enter your First Zone Name: " FZN
read -p "Please enter your Second Zone Name: " SZN
read -p "Please enter your Third Zone Name: " TZN
read -p "Please enter your Zone Name Extension: " ZNE
	
# Making the DNSlave config file
echo -e "options {\n" > /etc/named.conf
sed -i "2i \	listen-on port 53 { 127.0.0.1; 172.16.$TON.$MMN; };" /etc/named.conf
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
sed -i "25i \	type slave;" /etc/named.conf
sed -i "26i \	file \"slaves/$FZN.$ZNE\";" /etc/named.conf
sed -i "27i \	masters { 172.16.$TON.$MMN; };" /etc/named.conf
sed -i "28i };"
sed -i "29i \	;" /etc/named.conf
sed -i "30i zone \"16.172.IN-ADDR.ARPA\" IN {" /etc/named.conf
sed -i "31i \	type slave;" /etc/named.conf
sed -i "32i \	file \"slaves/16.172.zone\";" /etc/named.conf
sed -i "33i \	masters { 172.16.$TON.$MMN; };" /etc/named.conf
sed -i "34i };" /etc/named.conf
sed -i "35i \	" /etc/named.conf
sed -i "36i zone \"$SZN.$ZNE\" IN {" /etc/named.conf
sed -i "37i \	type slave;" /etc/named.conf
sed -i "38i \	file \"slaves/$SZN.$ZNE\";" /etc/named.conf
sed -i "39i \	masters { 172.16.$TON.$MMN; };" /etc/named.conf
sed -i "40i };" /etc/named.conf
sed -i "41i \	" /etc/named.conf
sed -i "42i zone \"$TZN.$ZNE\" IN {" /etc/named.conf
sed -i "43i \	type slave;" /etc/named.conf
sed -i "44i \	file \"slaves/$TZN.$ZNE\";" /etc/named.conf
sed -i "45i \	masters { 172.16.$TON.$MMN; };" /etc/named.conf
sed -i "46i };" /etc/named.conf
sed -i "47i \	" /etc/named.conf
sed -i "48i include \"/etc/named.rfx1912.zones\";" /etc/named.conf
sed -i "49i \"/etc/named.root.key\";" /etc/named.conf

# Restarting the DNS service
service named restart


