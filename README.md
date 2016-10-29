# docker-zimbra
•   Run good in coreos without Server service monitor
•   mount volume to /install if you want install from /install. SSH and run /install.sh or edit /install.sh to wget option

# Zimbra 8.7.1 for docker

``docker run -p PORTS -h HOSTNAME.DOMAIN --dns DNSSERVER -i -t -e PASSWORD=YOURPASSWORD NAMEOFDOCKERIMAGE``

Example:
``docker run -p 25:25 -p 80:80 -p 456:456 -p 587:587 -p 110:110 -p 143:143 -p 993:993 -p 995:995 -p 443:443 -p 8080:8080 -p 8443:8443 -p 7071:7071 -p 9071:9071 -h zimbra86-docker.zimbra.io --dns 127.0.0.1 --dns 8.8.8.8 -i -t -e PASSWORD=Zimbra2015 zimbra_docker``

This will create the container in few seconds, and run automatically the start.sh:

•     Install a DNS Server based in bind9 and the dnsutils package
•     Configure all the DNS Server to resolve automatically internal the MX and the hostname that we define while launch the container.
•     Install the OS dependencies for Zimbra Collaboration 8.7.1
•     Create 2 files to automate the Zimbra Collaboration installation, the keystrokes and the config.defaults.
•     Launch the installation of Zimbra based only in the .install.sh -s
•     Inject the config.defaults file with all the parameters that is autoconfigured with the Hostname, domain, IP, and password that you define before.

# Access to the Web Client and Admin Console

The Script will take care of everything and after a few minutes you can go to the IP of your server and use the next URL:

•     Web Client - https://YOURIP
•     Admin Console - https://YOURIP:7071
