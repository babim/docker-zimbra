FROM babim/ubuntubaseinit:ssh

## Install wget ##
RUN sudo apt-get update && sudo apt-get install -y wget bind9 bind9utils bind9-doc dnsutils \
	netcat-openbsd sudo libidn11 libpcre3 libgmp10 libexpat1 libstdc++6 libperl5.18 libaio1 resolvconf unzip pax sysstat sqlite3

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /build && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup

VOLUME ["/opt/zimbra", "/install"]

EXPOSE 22 25 456 587 110 143 993 995 80 443 8080 8443 7071

RUN mkdir /tmp/zcs
ADD start.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh
ADD install.sh /install.sh
RUN chmod +x /install.sh

CMD ["/etc/my_init.d/startup.sh"]
