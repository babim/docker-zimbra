#!/bin/bash
service ssh start
# Set DNS Server to localhost
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
service bind9 restart
if [ -f "/opt/zimbra/bin/zmcontrol" ]; then
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
bash
fi
