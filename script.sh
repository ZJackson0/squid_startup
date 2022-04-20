apt update
apt upgrade -y
apt install squid -y
apt install apache2-utils -y
apt install curl -y
touch /etc/squid/.ip.txt
touch /etc/squid/squidusers
IP=$(curl -s ifconfig.co)
echo "$IP tom" > /etc/squid/.ip.txt
htpasswd -nb tom 123 > /etc/squid/squidusers
echo "http_port 7158

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/squidusers
auth_param basic realm proxy
auth_param basic children 1
auth_param basic credentialsttl 2 hours
auth_param basic casesensitive on
max_filedesc 8192

always_direct allow all
workers 1
dns_v4_first on

access_log none
cache_log /dev/null

logfile_rotate 0
coredump_dir /var/spool/squid
via off

#header config
forwarded_for off
request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all
via off
forwarded_for delete

#refresh
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern (Release|Packages(.gz)*)$      0       20%     2880
refresh_pattern .               0       20%     4320

httpd_suppress_version_string on
cache deny all
#ACL
external_acl_type file_userip ipv4 %MYADDR %LOGIN /usr/lib/squid/ext_file_userip_acl -f /etc/squid/.ip.txt
acl authenticated proxy_auth REQUIRED
acl IP_USER external file_userip
http_access deny !IP_USER
acl ip2 myip $IP
tcp_outgoing_address $IP ip2
http_access allow authenticated
http_access deny all" > /etc/squid/squid.conf
/etc/init.d/squid reload 
