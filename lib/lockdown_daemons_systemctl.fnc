# Fedora, RHEL, Ubuntu
#   systemctl start|stop|etc x
#   systemctl enable|disable x
# Begin starting services
if (( ! SILENT )) ; then echo "Starting systemctl starts for $DISTRO"; fi
$DRY_RUN systemctl start fail2ban
if [ 0 -ne $? ] && [ -z $DRY_RUN ]
then
    echo "Failed to start fail2ban, exiting."
    exit 1
fi
$DRY_RUN systemctl start ipset
if [ 0 -ne $? ] && [ -z $DRY_RUN ]
then
    echo "Failed to start ipset, exiting."
    exit 1
fi
$DRY_RUN systemctl start iptables
if [ 0 -ne $? ] && [ -z $DRY_RUN ]
then
    echo "Failed to start iptables, exiting."
    exit 1
fi
# Begin stopping & disabling conflicting services
if [ `pidof nftables` ]
then
  if (( ! SILENT )) ; then echo "Stopping & disabling nftables"; fi
  $DRY_RUN systemctl stop nftables
  $DRY_RUN systemctl disable nftables
fi
if [ `pidof firewalld` ]
then
  if (( ! SILENT )) ; then echo "Stopping & disabling firewalld"; fi
  $DRY_RUN systemctl stop nftables
  $DRY_RUN systemctl disable nftables
fi
# Begin enabling services
if (( ! SILENT )) ; then echo "Enabling services for $DISTRO"; fi
$DRY_RUN systemctl enable fail2ban
if (( `systemctl is-enabled fail2ban` )) && [ -z $DRY_RUN ]
then
    echo "Failed to enable fail2ban, exiting."
fi
$DRY_RUN systemctl enable ipset
if (( `systemctl is-enabled ipset` )) && [ -z $DRY_RUN ]
then
    echo "Failed to enable fail2ban, exiting."
fi
$DRY_RUN systemctl enable iptables
if (( `systemctl is-enabled iptables` )) && [ -z $DRY_RUN ]
then
    echo "Failed to enable fail2ban, exiting."
fi
if (( ! SILENT )) ; then echo "Service configuration completed successfully!"; fi
