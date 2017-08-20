# Lockdown initialization function
lockdown_init () {
  if [ ! -d /usr/local/sbin ]
  then
    mkdir -p /usr/local/sbin
  fi
  if [ -d /usr/local/sbin ]
  then
    chmod u+x bin/*
    cp bin/* /usr/local/sbin
  else
    echo "Could not create or access /usr/local/sbin, installation cannot continue"
    exit 1
  fi
  if [ ! -d /etc/lockdown ]
  then
    mkdir -p /etc/lockdown
  fi
  if [ -d /etc/lockdown ]
  then
    /bin/cp -r lists /etc/lockdown
    /bin/cp -r conf /etc/lockdown
    /bin/cp -r lists /etc/lockdown
    /bin/cp -r post-process /etc/lockdown
    /bin/cp -r pre-process /etc/lockdown
    /bin/cp -r etc/ipset.conf /etc/
    chown root:root /etc/ipset.conf
    /bin/cp -r etc/init.d/ipset /etc/init.d
    chown -R root:root /etc/lockdown /etc/init.d/ipset
    chmod u+x /etc/init.d/ipset
  else
    echo "Could not create or access /etc/lockdown, installation cannot continue"
    exit 1
  fi
  if [ ! -d /usr/local/share/lockdown ]
  then
    mkdir -p /usr/local/share/lockdown
  fi
  if [ -d /usr/local/share/lockdown ]
  then
    cp -r . /usr/local/share/lockdown/
  else
    echo "Could not create or access /usr/local/share/lockdown, installation cannot continue"
    exit 1
  fi
}
