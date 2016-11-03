#!/bin/bash
chown root:root /var/run/sshd
service ssh start

if [ -f "/opt/zimbra/bin/zmcontrol" ]; then
HOSTNAME=$(hostname -s)
DOMAIN=$(hostname -d)
CONTAINERIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
# Set DNS Server to localhost
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

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

# Restart zimbra
rm -f /opt/zimbra/zmstat/pid/zmstat-*.pid
su -c "/opt/zimbra/bin/zmloggerctl restart" zimbra
/opt/zimbra/libexec/zmsyslogsetup
kill -9 $(ps ax | grep rsyslog | grep -v "grep" | awk '{print $1}')
rsyslogd -f /etc/rsyslog.conf
su -c "/opt/zimbra/libexec/zmstatuslog restart" zimbra
su -c "/opt/zimbra/bin/zmstatctl restart" zimbra
/opt/zimbra/libexec/zmsyslogsetup
su -c "/opt/zimbra/bin/zmupdateauthkeys restart" zimbra
su -c "/opt/zimbra/bin/zmcontrol restart" zimbra
su -c "/opt/zimbra/bin/zmcontrol start" zimbra
su -c "/opt/zimbra/bin/zmcontrol status" zimbra
bash
else
/install.sh
fi
