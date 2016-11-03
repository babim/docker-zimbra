#!/bin/sh
## Preparing all the variables like IP, Hostname, etc, all of them from the container
sleep 5
HOSTNAME=$(hostname -s)
DOMAIN=$(hostname -d)
CONTAINERIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)

#change zimbra default value
MailSSLPort1=${MailSSLPort:-443}
AdminPort1=${AdminPort:-7071}
AdminURL1=${AdminURL:-/zimbraAdmin}
PASSWORD1=${PASSWORD:-123456}

service ssh start
## Installing the DNS Server ##
echo "Installing DNS Server"
#sudo apt-get update && sudo sudo apt-get install -y bind9 bind9utils bind9-doc dnsutils
echo "Configuring DNS Server"
sed "s/-u/-4 -u/g" /etc/default/bind9 > /etc/default/bind9.new
mv /etc/default/bind9.new /etc/default/bind9
rm /etc/bind/named.conf.options
cat <<EOF >>/etc/bind/named.conf.options
options {
directory "/var/cache/bind";
listen-on { 127.0.0.1; }; # ns1 private IP address - listen on private network only
allow-transfer { none; }; # disable zone transfers by default
forwarders {
8.8.8.8;
8.8.4.4;
};
auth-nxdomain no; # conform to RFC1035
#listen-on-v6 { any; };
};
EOF
cat <<EOF >/etc/bind/named.conf.local
zone "$DOMAIN" {
        type master;
        file "/etc/bind/db.$DOMAIN";
};
EOF
touch /etc/bind/db.$DOMAIN
cat <<EOF >/etc/bind/db.$DOMAIN
\$TTL  604800
@      IN      SOA    ns1.$DOMAIN. root.localhost. (
                              2        ; Serial
                        604800        ; Refresh
                          86400        ; Retry
                        2419200        ; Expire
                        604800 )      ; Negative Cache TTL
;
@     IN      NS      ns1.$DOMAIN.
@     IN      A      $CONTAINERIP
@     IN      MX     10     $HOSTNAME.$DOMAIN.
$HOSTNAME     IN      A      $CONTAINERIP
ns1     IN      A      $CONTAINERIP
mail     IN      A      $CONTAINERIP
pop3     IN      A      $CONTAINERIP
imap     IN      A      $CONTAINERIP
imap4     IN      A      $CONTAINERIP
smtp     IN      A      $CONTAINERIP
EOF
sudo service bind9 start

# Set DNS Server to localhost
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

##Install the Zimbra Collaboration OS dependencies and Zimbra package ##
#apt-get update
echo "Download and install Zimbra Collaboration dependencies"
#sudo apt-get install -y netcat-openbsd sudo libidn11 libpcre3 libgmp10 libexpat1 libstdc++6 libperl5.18 libaio1 resolvconf unzip pax sysstat sqlite3

##Install the Zimbra Collaboration ##
echo "Downloading Zimbra Collaboration 8.7"
cd /tmp/zcs 
##download from web
if [ -f "/install/zcs-8.7.1_GA_1670.UBUNTU14_64.20161025045105.tgz" ]; then
##install from /install
cp /install/zcs*.tgz /tmp/zcs
tar xzvf zcs-*.tgz
rm -f zcs*.tgz
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
