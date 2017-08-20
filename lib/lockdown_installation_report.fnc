# Report installation status
installation_report () {
  # Check for executables & required directories
  if [ -f /usr/bin/iptables ]
  then
    echo "/usr/bin/iptables found"
  else
    "Could not find iptables, please report on Github issues"
    exit 1
  fi
  if [ -f /usr/sbin/ipset ]
  then
    echo "/usr/sbin/ipset found"
  else
    "Could not find ipset, please report on Github issues"
    exit 1
  fi
  if [ -f /usr/bin/fail2ban-client ]
  then
    echo "/usr/bin/fail2ban-client found"
  else
    echo "Could not find fail2ban, please report on Github issues"
    exit 1
  fi
  if [ -d /etc/fail2ban ]
  then
    echo "/etc/fail2ban found"
  else
    "Could not find fail2ban configuration files, please report on Github issues"
    exit 1
  fi
  if [ -d /etc/lockdown ]
  then
    echo "/etc/lockdown found"
  else
    "Could not find Lockdown configuration files, please report on Github issues"
    exit 1
  fi
  if [ -d /usr/share/lockdown ]
  then
    echo "/usr/share/lockdown found"
  else
    "Could not find Lockdown lists, please report on Github issues"
    exit 1
  fi
  if [ -f /usr/local/sbin/ld-allow ]
  then
    echo "/etc/lockdown found"
  else
    "Could not find Lockdown configuration files, please report on Github issues"
    exit 1
  fi

  # Check conflicting services are not running
  if (( `pidof nftables` ))
  then
    "nftables process found, please report on Github issues"
    exit 1
  else
    echo "nftables not running"
  fi
  if (( `pidof firewalld` ))
  then
    "firewalld process found, please report on Github issues"
    exit 1
  else
    echo "firewalld not running"
    exit 1
  fi

  # Check required services are running
  if (( `pidof iptables` ))
  then
    echo "iptables is running"
  else
    "iptables process not found, please report on Github issues"
    exit 1
  fi
  if (( `pidof ipset` ))
  then
    echo "ipset is running"
  else
    "ipset process not found, please report on Github issues"
    exit 1
  fi
  if (( `pidof fail2ban-server` ))
  then
    echo "fail2ban-server is running"
  else
    "fail2ban-server process not found, please report on Github issues"
    exit 1
  fi

  # Make sure everything is A-OK (ld-test should exit 0 status w/no output)
  if (( `/usr/local/sbin/ld-test` ))
  then
    "Lockdown test failed, please report on Github issues"
    exit 1
  else
    echo "Lockdown test passed."
  fi

  # Display success message and show user relevant files
  echo
  echo
  echo "Success!"
  echo "Lockdown executables are in /usr/local/sbin and start with ld-"
  echo "ls /usr/local/sbin/ld-*:"
  ls /usr/local/sbin/ld-*
  echo "Lockdown configuration files are in /etc/lockdown"
  echo "ls /etc/lockdown:"
  ls /etc/lockdown
  echo "Lockdown blacklist & country files are in /usr/share/lockdown"
  echo "ls /usr/share/lockdown:"
  ls /usr/share/lockdown
  echo
  echo "May the force of my ban hammer be with you! - @iDoMeteor"
}
