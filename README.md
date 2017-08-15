# [Lockdown](https://github.com/boldleadsdevelopment/lockdown)
## v0.1


## Synopsis

Lockdown is a set of scripts, lists and configuration files used to quickly implement granular firewall security at the host level using iptables, ipset and fail2ban.  It is intended to be smart, up to date, controllable and most imporantly.. **stable** enough to use in **automated production deployments**.


## Concept

In a nutshell, let us *assume* the following:

  * Most services and web sites do not truly deliver value to the entire globe
  * Most services and web sites do not truly receive value from the entire globe
  * The vast majority of traffic from many countries is not only useless, but also dangerous
  * Both computational resources and data privacy are more important than junk traffic
  * Chasing down attackers manually consumes more time than it is worth and is a never ending job
  * Every site on the Internet gets hit with hundreds if not thousands of automated attacks on a daily basis
  * In the countries of value to the site or service, there will also be malicious traffic
  * An attack on any port may as well be on all ports
  * A trusted source on any port may as well be trusted on all ports
  * So we only deal with ports globally for public services
  * It is of utmost importance not to block valid traffic from countries of value
  * There are also individuals or entities that must never be denied access for any reason
  * There may be times we want to do interact directly with IP Tables, IP Set or Fail2Ban without losing the easy and convenience of **Lockdown**

Therefore, **Lockdown** will *do* the following:

  * Utilize the most ubiquitous Linux firewall, **IP Tables**
  * Differentiate between single IPs and blocks of IPs (aka ranges, subnets)
  * Define whitelists to allow access to known or assumedly good traffic based on country of origin
  * Define blacklists to deny access to known or assumedly bad traffic based on country of origin
  * Protect ourselves from malicious traffic in assumedly good countries by using **Fail2Ban** to automatically add the offenders to the IP specific blacklist
  * Trust individual users or entities by adding them to the whitelist
  * Use **IP Set** to manage these lists to minimize resource consumption
  * Automatically update country and attack lists automatically using wget via a scripted cron job
  * Allow some configurability via configuration files and run time execution parameters


## Installation

Before you install, you should probably edit the `confs/lockdown.conf` file.  When you run `bin/ld-setup`, the following things will happen (*note that using the -f or --force option will run without asking any questions*) in sequential order:

  * Existing iptables, ipset and fail2ban configurations will be renamed (with -b4-lockdown.bak appended)
  * Yum will ask you to install iptables, ipset and fail2ban if any are missing
  * An initialization script for ipset will be copied to `/etc/init.d`
  * Country lists and blacklists will be downloaded according to the configuration with a 10 second gap between each download (prevents getting your own self banned!)
  * You will be asked to if you wish to manually enter IPs or subnets into each of the four lists, one at a time
  * A cron job to update lists will be installed
  * IP Set will be started
  * **Sets** will be created in **IP Set** and lists loaded into them (can take quite a while, especially processing lists like China & the USA)
  * IP Set sets will be saved
  * Firewalld will be stopped if running
  * IP Tables rules will be started
  * IP Tables rules will be loaded
  * IP Tables rules will be saved
  * Fail2Ban configuration files will be copied into place
  * Fail2Ban will be started
  * Firewalld will be disabled on system boot if enabled
  * Fail2Ban, IPSet and IPTables will be enabled  on system boot if disabled
  * Scripts from bin/ will be copied to /usr/local/sbin
  * Configuration file and lists will be copied to /etc/lockdown
  * A report will be written to ./setup.log and emailed to the address configured in the config file

Congratulations, you are now blocking half the Internet!  Take a nap! \o/

## Defaults

  * By default, we do not block any /8 blocks, to do so, set block-eight to 1 in the config
  * XXX
  * XXX
  * XXX
  * XXX
  * XXX

## How Rules are Processed

  1. Global pre-process rules are parsed
  1. Whitelisted IPs are parsed, matches are allowed on any port
  1. Blacklisted IPs are parsed, matches are denied on any port
  1. Whitelisted networks are parsed, matches are allowed on any port
  1. Blacklisted networks are parsed, matches are denied on any port
  1. Global post-process rules are parsed, generally allowing all traffic on ports 80 & 443

## Requirements & Dependencies

Distros Supported: 

  * Amazon Linux
  * CentOS
  * Fedora (untested)
  * RHEL (untested)
  * Ubuntu

OS Pre-Installation Dependencies

  * **Bash**  
      To interpret the scripts in bin/
  * **systemctl**  
      For controlling services
  * **Package Manager**  
      Supported: Apt, DNF, Yum
      Used to install iptables, ipset & fail2ban are not present

Requirements for Operation:

  * **Fail 2 Ban**  
      Temporarily bans offending IPs and can be tightly coupled with any service
  * **IP Set**  
      Compiles address sets for direct usage by the kernel resulting in extremely fast procesing of large sets
  * **IP Tables**  
      The standard Linux firewall, determines what happens to a network packet as it traverses the network interface

Optional:

  * **Cron**  
      To orchestrate automated list and **Lockdown**  updates
  * **Public Internet connection**  
      For updating lists
  * **WGet**  
      Also for updating lists (set update_lists = 0 to prevent attempts to update)


## Files Included

```bash
$ tree -L 2
> .
> ├── bin/
> │   ├── ld-accept
> │   ├── ld-deny
> │   ├── ld-emergency-accept-all
> │   ├── ld-emergency-deny-all
> │   ├── ld-export
> │   ├── ld-import
> │   ├── ld-reinitialize
> │   ├── ld-remove-allow
> │   ├── ld-remove-block
> │   ├── ld-setup
> │   ├── ld-start
> │   ├── ld-stop
> │   ├── ld-update-blacklists
> │   └── ld-update-countries
> ├── blacklist-ips/
> ├── blacklist-networks/
> │   ├── bogons/
> │   ├── countries/
> │   ├── domains/
> │   ├── ipset-blocklist-removals.txt
> │   ├── iptable-drop-old-blocks.txt
> │   ├── iptable-drops.txt
> │   └── iptable-removals.txt
> ├── confs/
> ├── post-process/
> ├── pre-process/
> ├── README.md
> ├── whitelist-ips/
> └── whitelist-networks/
```

Type the name of any file in bin/ with --help or -h and hit return to get a short description of what it does, parameters it accepts and examples.

```bash
# Example
bin/ld-accept --help
```
> Command: ld-accept
> Description: Allow an IP or subnet through the firewall
> Examples:
>   ld-allow 1.2.3.4 # Accept all traffic from 1.2.3.4/32
>   ld-allow 1.2.3   # Accept all traffic from 1.2.3.0/24
>   ld-allow 1.2     # Accept all traffic from 1.2.0.0/16
>   ld-allow 1       # Accept all traffic from 1.0.0.0/8


## Examples

`ld-accept`
> xxx

`ld-deny`
> xxx

`ld-emergency-accept-all`
> xxx

`ld-emergency-deny-all`
> xxx

`ld-export`
> xxx

`ld-import`
> xxx

`ld-reinitialize`
> xxx

`ld-remove-allow`
> xxx

`ld-remove-block`
> xxx

`ld-replace-firewalld`
> xxx

`ld-setup`
> xxx

`ld-start`
> xxx

`ld-stop`
> xxx

`ld-update-blacklists`
> xxx

`ld-update-countries`
> xxx



## TODO

Can always use more configuration and command line options!
Download ASN lists directly from RIPE and convert
Make an NPM wrapper module


## Bug Reports & Contributions

Bug reports and code contributions can be made against the [@iDoMeteor Lockdown Repo](https://github.com/idometeor/lockdown).

## External Sources

[Execution Environment's IP](http://bot.whatismyipaddress.com/)

[IPv4 Full Bogons](http://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt)
[IPv4 Full Bogons - alternate](https://www.countryipblocks.net/bogons/cidr_ipv4_bogons.txt)
[IPv6 Full Bogons - future use](http://www.team-cymru.org/Services/Bogons/fullbogons-ipv6.txt)
[The German's Blocklist](https://lists.blocklist.de/lists/all.txt)

[Country Lists](http://www.iwik.org/ipcountry/<country code uppercase>.cidr)
[Country Lists - Alternate -Single](http://ipdeny.com/ipblocks/data/aggregated/<country code lowercase>-aggregated.zone)
[Country Lists - Alternate - All](http://www.ipdeny.com/ipblocks/data/countries/all-zones.tar.gz)
[Country Lists IPv6](http://www.ipdeny.com/ipv6/ipaddresses/blocks/ipv6-all-zones.tar.gz)

[GeoIP Country](http://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip)
[GeoIP ASN](http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN-CSV.zip)

--

<3
