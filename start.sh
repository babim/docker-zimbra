#!/bin/bash
service ssh start
if [ -f "/opt/zimbra/bin/zmcontrol" ]; then
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
