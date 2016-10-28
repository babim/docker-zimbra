#!/bin/sh
## Preparing all the variables like IP, Hostname, etc, all of them from the container
sleep 5
HOSTNAME=$(hostname -a)
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
cat <<EOF >>/etc/bind/named.conf.local
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
sudo service bind9 restart 

##Install the Zimbra Collaboration OS dependencies and Zimbra package ##
#apt-get update
echo "Download and install Zimbra Collaboration dependencies"
sudo apt-get install -y netcat-openbsd sudo libidn11 libpcre3 libgmp10 libexpat1 libstdc++6 libperl5.18 libaio1 resolvconf unzip pax sysstat sqlite3

## Building and adding the Scripts keystrokes and the config.defaults
touch /tmp/zcs/installZimbra-keystrokes
cat <<EOF >/tmp/zcs/installZimbra-keystrokes
y
y
y
y
n
y
y
y
y
y
y
y
EOF

touch /tmp/zcs/installZimbraScript
cat <<EOF >/tmp/zcs/installZimbraScript
AVDOMAIN="$DOMAIN"
AVUSER="admin@$DOMAIN"
CREATEADMIN="admin@$DOMAIN"
CREATEADMINPASS="$PASSWORD1"
CREATEDOMAIN="$DOMAIN"
DOCREATEADMIN="yes"
DOCREATEDOMAIN="yes"
DOTRAINSA="yes"
EXPANDMENU="no"
HOSTNAME="$HOSTNAME.$DOMAIN"
HTTPPORT="8080"
HTTPPROXY="TRUE"
HTTPPROXYPORT="80"
HTTPSPORT="8443"
HTTPSPROXYPORT="443"
IMAPPORT="7143"
IMAPPROXYPORT="143"
IMAPSSLPORT="7993"
IMAPSSLPROXYPORT="993"
INSTALL_WEBAPPS="service zimlet zimbra zimbraAdmin"
JAVAHOME="/opt/zimbra/java"
LDAPAMAVISPASS="$PASSWORD1"
LDAPPOSTPASS="$PASSWORD1"
LDAPROOTPASS="$PASSWORD1"
LDAPADMINPASS="$PASSWORD1"
LDAPREPPASS="$PASSWORD1"
LDAPBESSEARCHSET="set"
LDAPHOST="$HOSTNAME.$DOMAIN"
LDAPPORT="389"
LDAPREPLICATIONTYPE="master"
LDAPSERVERID="2"
MAILBOXDMEMORY="972"
MAILPROXY="TRUE"
MODE="https"
MYSQLMEMORYPERCENT="30"
POPPORT="7110"
POPPROXYPORT="110"
POPSSLPORT="7995"
POPSSLPROXYPORT="995"
PROXYMODE="https"
REMOVE="no"
RUNARCHIVING="no"
RUNAV="yes"
RUNCBPOLICYD="no"
RUNDKIM="yes"
RUNSA="yes"
RUNVMHA="no"
SERVICEWEBAPP="yes"
SMTPDEST="admin@$DOMAIN"
SMTPHOST="$HOSTNAME.$DOMAIN"
SMTPNOTIFY="yes"
SMTPSOURCE="admin@$DOMAIN"
SNMPNOTIFY="yes"
SNMPTRAPHOST="$HOSTNAME.$DOMAIN"
SPELLURL="http://$HOSTNAME.$DOMAIN:7780/aspell.php"
STARTSERVERS="yes"
SYSTEMMEMORY="3.8"
TRAINSAHAM="ham.$RANDOMHAM@$DOMAIN"
TRAINSASPAM="spam.$RANDOMSPAM@$DOMAIN"
UIWEBAPPS="yes"
UPGRADE="yes"
USESPELL="yes"
VERSIONUPDATECHECKS="TRUE"
VIRUSQUARANTINE="virus-quarantine.$RANDOMVIRUS@$DOMAIN"
ZIMBRA_REQ_SECURITY="yes"
ldap_bes_searcher_password="$PASSWORD1"
ldap_dit_base_dn_config="cn=zimbra"
ldap_nginx_password="$PASSWORD1"
mailboxd_directory="/opt/zimbra/mailboxd"
mailboxd_keystore="/opt/zimbra/mailboxd/etc/keystore"
mailboxd_keystore_password="$PASSWORD1"
mailboxd_server="jetty"
mailboxd_truststore="/opt/zimbra/java/jre/lib/security/cacerts"
mailboxd_truststore_password="changeit"
postfix_mail_owner="postfix"
postfix_setgid_group="postdrop"
ssl_default_digest="sha256"
zimbraFeatureBriefcasesEnabled="Enabled"
zimbraFeatureTasksEnabled="Enabled"
zimbraIPMode="ipv4"
zimbraMailProxy="FALSE"
zimbraMtaMyNetworks="127.0.0.0/8 $CONTAINERIP/24 [::1]/128 [fe80::]/64"
zimbraPrefTimeZoneId="America/Los_Angeles"
zimbraReverseProxyLookupTarget="TRUE"
zimbraVersionCheckNotificationEmail="admin@$DOMAIN"
zimbraVersionCheckNotificationEmailFrom="admin@$DOMAIN"
zimbraVersionCheckSendNotifications="TRUE"
zimbraWebProxy="FALSE"
zimbra_ldap_userdn="uid=zimbra,cn=admins,cn=zimbra"
zimbra_require_interprocess_security="1"
zimbraMailSSLPort="$MailSSLPort1"
zimbraAdminPort="$AdminPort1"
zimbraAdminURL="$AdminURL1"
INSTALL_PACKAGES="zimbra-core zimbra-ldap zimbra-logger zimbra-mta zimbra-snmp zimbra-store zimbra-apache zimbra-spell zimbra-memcached zimbra-proxy"
EOF

##Install the Zimbra Collaboration ##
echo "Downloading Zimbra Collaboration 8.6"
cd /tmp/zcs 
##download from web
if [ -f "/install/zcs-8.7.1_GA_1670.UBUNTU16_64.20161025045114.tgz" ]; then
##install from /install
cp /install/zcs*.tgz /tmp/zcs
tar xzvf zcs-*.tgz
rm -f zcs*.tgz
echo "Installing Zimbra Collaboration just the Software"
cd /tmp/zcs/zcs-* && ./install.sh -s < /tmp/zcs/installZimbra-keystrokes
echo "Installing Zimbra Collaboration injecting the configuration"
/opt/zimbra/libexec/zmsetup.pl -c /tmp/zcs/installZimbraScript
else
wget https://files.zimbra.com/downloads/8.7.1_GA/zcs-8.7.1_GA_1670.UBUNTU16_64.20161025045114.tgz
##install from /install
cp /install/zcs*.tgz /tmp/zcs
tar xzvf zcs-*.tgz
rm -f zcs*.tgz
echo "Installing Zimbra Collaboration just the Software"
cd /tmp/zcs/zcs-* && ./install.sh -s < /tmp/zcs/installZimbra-keystrokes
echo "Installing Zimbra Collaboration injecting the configuration"
/opt/zimbra/libexec/zmsetup.pl -c /tmp/zcs/installZimbraScript
fi

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
