#!/bin/sh

/bin/firewall-cmd --permanent --zone=public --add-port=2376/tcp
/bin/firewall-cmd --permanent --zone=public --add-port=2377/tcp
/bin/firewall-cmd --permanent --zone=public --add-port=4789/tcp
/bin/firewall-cmd --permanent --zone=public --add-port=4789/udp
/bin/firewall-cmd --permanent --zone=public --add-port=7946/tcp
/bin/firewall-cmd --permanent --zone=public --add-port=7946/udp
/bin/firewall-cmd --permanent --zone=public --add-rich-rule="rule protocol value=esp accept"

/bin/firewall-cmd --reload

/sbin/iptables -nvL
