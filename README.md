# [Lockdown](https://github.com/boldleadsdevelopment/lockdown)
## v0.1 PRE-BETA


## Synopsis

Lockdown is a set of scripts, lists and configuration files used to quickly implement granular firewall security at the host level using iptables, ipset and fail2ban.  It is intended to be smart, up to date, controllable and most imporantly.. **stable** enough to use in **automated production deployments**.


## Concept

In a nutshell, let us *assume* the following:

  * Most services and web sites do not truly deliver value to the entire globe
  * Most services and web sites do not truly receive value from the entire globe
  * The vast majority of traffic from many countries is not only irrelevant, but also dangerous
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

Before you install, you should probably edit the `confs/lockdown.conf` file.  When you run `./ld-install`, the following things will happen (*note that using the -f or --force option will run without asking any questions*) in sequential order:

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
  * **Gamin**  
      Modern file access monitoring system which enables Fail2Ban to process logs more quickly (not required but is installed with everything else)
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


## Defaults

From the configuration file:
```bash
# Lockdown Default Configuration File v001
#
# This file could be exploited, be sure only root has write
# access
# 
# Double quote strings
# 0 = false, 1 = true

# Allow blocking of /8 networks
allow_eight=1

# If set to 1, single IP blocks will be re-assigned as /24 CIDR ranges
bad_neighbor_policy=1

# Block non-assigned, multicast and private network blocks
block_bogons=1

# Countries blocks to whitelist
countries_good=(
  us
  ca
)

# Countries blocks to whitelist
countries_bad=(
  cn
  ir
  kr
  ro
  ru
  sr
  vz
)

# Location of Lockdown files
location_bin=/usr/local/sbin
location_conf=/etc/lockdown/conf
location_lists=/etc/lockdown/lists
location_logs=/var/log/lockdown

# Globally open ports
# Any traffic not matching a blacklist entry will be
# allowed to access services on each of these ports
ports=(
  22
  80
  443
)

# Repository for Lockdown lists
repo_lists='https://github.com/boldleadsdevelopment/lockdown-lists'

# When enabled, the latest lists will be downloaded 
# using ld-update-lists.  If set to 0, lists will never
# be updated and that is probably not wise.
update_lists=1

# Using Github will update lists via our Github repository
# Setting this to 0 will download from their source 
use_github=1
```

## Files Included

```bash
$ tree -L 2
.
├── bin
│   ├── ld-allow
│   ├── ld-allow-all
│   ├── ld-block
│   ├── ld-block-all
│   ├── ld-export
│   ├── ld-import
│   ├── ld-kill
│   ├── ld-load-lists
│   ├── ld-reinitialize
│   ├── ld-reload
│   ├── ld-remove-allow
│   ├── ld-remove-block
│   ├── ld-restart
│   ├── ld-start
│   ├── ld-status
│   ├── ld-stop
│   ├── ld-test
│   └── ld-update-lists
├── blacklist-ips
│   ├── ahrefs.com.ips
│   └── ips.txt
├── blacklist-networks
│   └── cidrs.txt
├── conf
│   └── lockdown-default.conf
├── etc
│   ├── fail2ban
│   ├── init.d
│   └── logrotate.d
├── ld-install
├── lib
├── lists
│   ├── blacklists
│   ├── countries
│   ├── countries.txt
│   └── country-codes.txt
├── post-process
│   ├── ipset.rules
│   └── iptables.rules
├── pre-process
│   ├── ipset.rules
│   └── iptables.rules
├── README.md
├── whitelist-ips
│   └── ips.txt
└── whitelist-networks
    └── cidrs.txt

```

Type the name of any file in bin/ with --help or -h and hit return to get a short description of what it does, parameters it accepts and examples.

```bash
# Example
bin/ld-accept --help
> Command: ld-accept  
> Description: Allow an IP or subnet through the firewall  
> Examples:  
>   ld-allow 1.2.3.4 # Accept all traffic from 1.2.3.4/32  
>   ld-allow 1.2.3   # Accept all traffic from 1.2.3.0/24  
>   ld-allow 1.2     # Accept all traffic from 1.2.0.0/16  
>   ld-allow 1       # Accept all traffic from 1.0.0.0/8  
```


## Command Documentation

`ld-install`
> WHEN TO USE:    
>   When you are very sure you want to boot up the full Lockdown suite of  
>   utilities using the configuration files in the conf/ directory where  
>   ld-install is located.  
>  
> USAGE:   
>   ld-install [-d] [-n] [-s] [-v] [-y]  
>   ld-install [--dry-run] [--no-download] [--silent] [--verbose] [--yes]  
>  
> DESCRIPTION:  
>   This script will try to do all of the following things,   
>    once it starts running, and in the order specified:  
>     * Install extra packages for Enterprise Linux if required  
>     * Install iptables, ipset and fail2ban if required  
>     * Stop each of the three above services if running  
>     * Copy default configuration files into place  
>     * Start each of the three services  
>     * Enable each of the three services to run at boot  
>     * Stop nftables or firewalld  
>     * Disable nftables or firewalld from running at boot  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -n | --no-download  
>      Do not run commands to download latest blacklist & country CIDR lists  
>   -s | --silent  
>      Silent will attempt to prevent any and all output except in the event  
>      of failure.  Silent operation implies --yes and will not ask permission  
>      for anything, you have been warned!  
>      Currently, any output from external programs will not be suppressed.  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  
>   -x | --no-backup  
>      Do not back up any potentially pre-existing files  
>   -y | --yes  
>      Automatically say yes to everything  

`ld-allow`
> WHEN TO USE:  
>   Fire it off when you want to quickly allow traffic on all ports from  
>   an IP or CIDR range in a variety of formats.  The point is to be as  
>   fast and brainless to use as possible.  
>  
> USAGE:   
>   ld-allow 1  
>   ld-allow 1.2.3.4  
>   ld-allow 1.0.0.0  
>   ld-allow 1.0.0.0/8  
>   ld-allow 1.2  
>   ld-allow 1.2.0.0  
>   ld-allow 1.2.0.0/16  
>   ld-allow 1.2.3  
>   ld-allow 1.2.3.4  
>   ld-allow 1.2.3.4/32  
>   ld-allow 1.2.3.5/21  
>  
> DESCRIPTION:  
>   Allows an IP or subnet through the firewall.  Specify full single IPs or  
>   subnets by leaving specifying the non-zero bytes of the dot-decimal address.  
>  
>   For example:   
>     1           = 1.0.0.0/8 in whitelist-networks  
>     1.0.0.0      = 1.0.0.0/8 in whitelist-networks  
>     1.0.0.0/8    = 1.0.0.0/8 in whitelist-networks  
>     1.2         = 1.2.0.0/16 in whitelist-networks  
>     1.2.0.0      = 1.2.0.0/16 in whitelist-networks  
>     1.2.0.0/16  = 1.2.0.0/16 in whitelist-networks  
>     1.2.3       = 1.2.3.0/24 in whitelist-networks  
>     1.2.3.0      = 1.2.3.0/24 in whitelist-networks  
>     1.2.3.0/24  = 1.2.3.0/24 in whitelist-networks  
>     1.2.3.5/21  = 1.2.3.5/21 in whitelist-networks  
>     1.2.3.4     = 1.2.3.4 in whitelist-ips  
>     1.2.3.4/32   = 1.2.3.4 in whitelist-ips  
>   Note: /8, /16, /24 and /32 are the only bit blocks currently utilized  
>  
> OPTIONS:  
>   [1-9]\*  
>      Required  
>      Target IP, CIDR or short-code  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-allow-all`
> WHEN TO USE:  
>   When you have some serious issues and need everything open in a hurry!  
>  
> USAGE:   
>   ld-allow-all [-d] [-h] [-n] [-p] [-t /tmp] [-v]  
>   ld-allow-all [--dry-run] [--help] [--notmp] [--permanent]   
>                            [--tmp /tmp] [--verbose]  
>  
> DESCRIPTION:  
>   This script will backup your current configuration to a temporary location  
>   and completely reboot IP tables and IP set with accept all policies as well  
>   as clear all temporary data from Fail2Ban.  The temporary location may be   
>   specified by the user, and will be output in the report.  
>  
>   Current saved configurations will only be reset if the permanent option  
>   is supplied.  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -n | --notmp  
>      Do not save currently running configuration  
>   -p | --permanent  
>      Make changes permanent  
>   -t | --tmp  
>      Provide an alternate location to save current configuration  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  
>  
> CAVEATS:  
>   Options -n and -t are mutually exclusive which is not checked so if you  
>   do something silly like that the consequences are unknown.  

`ld-block`
> WHEN TO USE:  
>   Fire it off when you want to quickly block traffic on all ports from  
>   an IP or CIDR range in a variety of formats.  The point is to be as  
>   fast and brainless to fire off as possible.  
>  
> USAGE:   
>   ld-block 1  
>   ld-block 1.2.3.4  
>   ld-block 1.0.0.0  
>   ld-block 1.0.0.0/8  
>   ld-block 1.2  
>   ld-block 1.2.0.0  
>   ld-block 1.2.0.0/16  
>   ld-block 1.2.3  
>   ld-block 1.2.3.4  
>   ld-block 1.2.3.4/32  
>   ld-block 1.2.3.5/21  
>  
> DESCRIPTION:  
>   Allows an IP or subnet through the firewall.  Specify full single IPs or  
>   subnets by leaving specifying the non-zero bytes of the dot-decimal address.  
>  
>   For example:   
>     1           = 1.0.0.0/8 in blacklist-networks  
>     1.0.0.0      = 1.0.0.0/8 in blacklist-networks  
>     1.0.0.0/8    = 1.0.0.0/8 in blacklist-networks  
>     1.2         = 1.2.0.0/16 in blacklist-networks  
>     1.2.0.0      = 1.2.0.0/16 in blacklist-networks  
>     1.2.0.0/16  = 1.2.0.0/16 in blacklist-networks  
>     1.2.3       = 1.2.3.0/24 in blacklist-networks  
>     1.2.3.0      = 1.2.3.0/24 in blacklist-networks  
>     1.2.3.0/24  = 1.2.3.0/24 in blacklist-networks  
>     1.2.3.5/21  = 1.2.3.5/21 in blacklist-networks  
>     1.2.3.4     = 1.2.3.4 in blacklist-ips  
>     1.2.3.4/32   = 1.2.3.4 in blacklist-ips  
>   Note: /8, /16, /24 and /32 are the only bit blocks currently utilized  
>  
> OPTIONS:  
>   [1-9]\*  
>      Required  
>      Target IP, CIDR or short-code  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-block-all`
> USAGE:   
>   ld-block-all [-d] [-h] [-n] [-p] [-t /tmp] [-v]  
>   ld-block-all [--dry-run] [--help] [--notmp] [--permanent]   
>                            [--tmp /tmp] [--verbose]  
>  
> DESCRIPTION:  
>   This script will backup your current configuration to a temporary location  
>   and completely reboot IP tables and IP set with deny all policies as well  
>   as clear all temporary data from Fail2Ban.  The temporary location may be   
>   specified by the user, and will be output in the report.  
>  
>   The IP of the user executing the command will automatically be  
>   whitelisted.  
>  
>   Current saved configurations will only be reset if the permanent option  
>   is supplied.  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -n | --notmp  
>      Do not save currently running configuration  
>   -p | --permanent  
>      Make changes permanent  
>   -t | --tmp  
>      Provide an alternate location to save current configuration  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  
>  
> CAVEATS:  
>   Options -n and -t are mutually exclusive which is not checked so if you  
>   do something silly like that the consequences are unknown.  

`ld-export`
> WHEN TO USE:  
>   When you want to save your current configurations to some specific location.  
>  
> USAGE:   
>   ld-export  
>   ld-export [--etc]  
>   ld-export [--path /path/to/export] [--tmp /tmp]  
>   ld-export [-e]  
>   ld-export [-p /path/to/export] [-t /tmp]  
>  
> DESCRIPTION:  
>   Saves current configuration of IP Tables, IP Set and Fail2Ban as a set of  
>   files and directories in the directory specified (or pwd when not set).  
>   If any of the services are not running, their existing configuration file  
>   from /etc will be used if it exists.  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -e | --etc  
>      Export currently running config of IP Tables & IP Set to /etc  
>   -h | --help  
>      Run help function and exit  
>   -p | --path  
>      Path or filename to save data to  
>   -t | --tmp  
>      Default = /tmp  
>      Provide an alternate location to save current configuration  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-import`
> WHEN TO USE:  
>   When you want to import, and implement, a previously exported configuration.  
>  
> USAGE:   
>   ld-import [-t /tmp] path/  
>   ld-import [--temp /tmp] ./filename.tar.gz  
>  
> DESCRIPTION:  
>   Imports previously exported configurations for IP Tables, IP Set and   
>   Fail2Ban from a directory or tarball.  Services will be stopped,  
>   configuration imported, and then services will be started again.  
>  
> OPTIONS:  
>   path | filename  
>      Path or filename to import data from  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -t | --tmp  
>      Default = /tmp  
>      Provide an alternate location to save current configuration  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-kill`
> WHEN TO USE:   
>   When you want to kill IP Tables, IP Set and Fail2Ban in the proper  
>   order, this just uses regular kill unless you -f it then it uses -9.  
>  
> USAGE:   
>   ld-kill [-d] [-f] [-h] [-v]  
>   ld-kill [--dry-run] [--fire] [--force] [--help] [--verbose]  
>  
> DESCRIPTION:  
>   Kills the services in the following order:  
>     * fail2ban  
>     * iptables  
>     * ipset  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -f | --fire | -- force  
>      Kill -9  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-load-lists`
> WHEN TO USE:    
>   After updating lists (otherwise new list data will not be used) or during  
>   installation.  
>  
> USAGE:   
>   ld-load-lists [-d] [-h] [-s] [-u] [-v]  
>   ld-load-lists [--dry-run] [--help] [--silent] [--update] [--verbose]  
>  
> DESCRIPTION:  
>   This script loads all the Lockdown lists into their appropriate places,  
>   including user defined lists.  It does not process pre- or post-processing  
>   rules.  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -s | --silent  
>      Silent will attempt to prevent any and all output except in the event  
>      of failure.  Silent operation implies --yes and will not ask permission  
>      for anything, you have been warned!  
>      Currently, any output from external programs will not be suppressed.  
>   -u | --update  
>      Update lists regardless of update_lists setting  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  
>   -y | --yes  
>      Automatically say yes to everything  

`ld-reinitialize`
> WHEN TO USE:   
>   What you have fubar'd everything and want to reboot IP Tables, IP Set  
>   and Fail2Ban.  
>  
> USAGE:   
>   ld-reinitialize [-c lockdown.conf] [-h] [-o tarball.tar.gz] [-s] [-y]  
>   ld-reinitialize [--config lockdown.conf] [--help] [--out tarball.tar.gz]  
>                   [--skip-f2b] [--yes]  
>  
> DESCRIPTION:  
>   This script will do the following things in the following order:  
>     * Export current saved configurations, if available, to a temporary  
>       location  
>     * Export current running configurations, if available, to a temporary  
>       location  
>     * (Re-)download configured blacklist and country files  
>     * Stop Fail2Ban  
>     * Overwrite existing Fail2Ban configuration files with defaults  
>     * Reset IP Tables and IP Set to their default state if running  
>     * Remove IP Tables and IP Set configuration files and start them if not  
>     * Re-configure IP Tables and IP Set according to config file  
>     * Save IP Tables and IP Set configurations  
>     * Start Fail2Ban  
>     * Ensure all services are enabled  
>    This script will not:  
>     * Install anything  
>     * Uninstall or disable anything  
>  
> OPTIONS:  
>   -c | --config  
>      Default = /etc/lockdown/conf/lockdown.conf  
>      Use given configuration files  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -o | --out  
>      Location to save archives  
>   -s | --skip-f2b  
>      Do not reboot F2B configuration files  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  
>   -y | --yes  
>      Automatically say yes to everything  

`ld-reload`
> WHEN TO USE:   
>   When you want to reload IP Tables, IP Set and Fail2Ban in the proper  
>   order.  
>  
> USAGE:   
>   ld-reload [-d] [-h] [-v]  
>   ld-reload [--dry-run] [--help] [--verbose]  
>  
> DESCRIPTION:  
>   Reloads the services in the following order:  
>     * fail2ban  
>     * ipset  
>     * iptables  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-remove-allow`
> WHEN TO USE:  
>   When you want to remove an IP or range previously allowed.  
>  
> USAGE:   
>   ld-remove-allow 1  
>   ld-remove-allow 1.2.3.4  
>   ld-remove-allow 1.0.0.0  
>   ld-remove-allow 1.0.0.0/8  
>   ld-remove-allow 1.2  
>   ld-remove-allow 1.2.0.0  
>   ld-remove-allow 1.2.0.0/16  
>   ld-remove-allow 1.2.3  
>   ld-remove-allow 1.2.3.4  
>   ld-remove-allow 1.2.3.4/32  
>   ld-remove-allow 1.2.3.5/21  
>  
> DESCRIPTION:  
>   Removes an IP or range from whitelists if found.  
>  
>   For example:   
>     1.2.3.4     = 1.2.3.4 in whitelist-ips  
>     1.2.3.4/32  = 1.2.3.4 in whitelist-ips  
>     1.2.3       = 1.2.3.0/24 in whitelist-networks  
>     1.2.3.0     = 1.2.3.0/24 in whitelist-networks  
>     1.2.3.0/24  = 1.2.3.0/24 in whitelist-networks  
>     1.2         = 1.2.0.0/16 in whitelist-networks  
>     1.2.0.0     = 1.2.0.0/16 in whitelist-networks  
>     1.2.0.0/16  = 1.2.0.0/16 in whitelist-networks  
>     1           = 1.0.0.0/8 in whitelist-networks  
>     1.0.0.0     = 1.0.0.0/8 in whitelist-networks  
>     1.0.0.0/8   = 1.0.0.0/8 in whitelist-networks  
>     1.2.3.5/21  = 1.2.3.5/21 in whitelist-networks  
>  
> OPTIONS:  
>   [1-9]\*  
>      Required  
>      Target IP, CIDR or short-code  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-remove-block`
> WHEN TO USE:  
>   When you want to remove an IP or range previously blocked.  
>  
> USAGE:   
>   ld-remove-block 1  
>   ld-remove-block 1.2.3.4  
>   ld-remove-block 1.0.0.0  
>   ld-remove-block 1.0.0.0/8  
>   ld-remove-block 1.2  
>   ld-remove-block 1.2.0.0  
>   ld-remove-block 1.2.0.0/16  
>   ld-remove-block 1.2.3  
>   ld-remove-block 1.2.3.4  
>   ld-remove-block 1.2.3.4/32  
>   ld-remove-block 1.2.3.5/21  
>  
> DESCRIPTION:  
>   Removes an IP or range from blacklists if found.  
>  
>   For example:   
>     1.2.3.4     = 1.2.3.4 in blacklist-ips  
>     1.2.3.4/32  = 1.2.3.4 in blacklist-ips  
>     1.2.3       = 1.2.3.0/24 in blacklist-networks  
>     1.2.3.0     = 1.2.3.0/24 in blacklist-networks  
>     1.2.3.0/24  = 1.2.3.0/24 in blacklist-networks  
>     1.2         = 1.2.0.0/16 in blacklist-networks  
>     1.2.0.0     = 1.2.0.0/16 in blacklist-networks  
>     1.2.0.0/16  = 1.2.0.0/16 in blacklist-networks  
>     1           = 1.0.0.0/8 in blacklist-networks  
>     1.0.0.0     = 1.0.0.0/8 in blacklist-networks  
>     1.0.0.0/8   = 1.0.0.0/8 in blacklist-networks  
>     1.2.3.5/21  = 1.2.3.5/21 in blacklist-networks  
>  
> OPTIONS:  
>   [1-9]\*  
>      Required  
>      Target IP, CIDR or short-code  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-restart`
> WHEN TO USE:   
>   When you want to restart IP Tables, IP Set and Fail2Ban in the proper  
>   order.  
>  
> USAGE:   
>   ld-restart [-d] [-h] [-v]  
>   ld-restart [--dry-run] [--help] [--verbose]  
>  
> DESCRIPTION:  
>   Restarts the services in the following order:  
>     * fail2ban  
>     * ipset  
>     * iptables  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-start`
> WHEN TO USE:   
>   When you want to start IP Tables, IP Set and Fail2Ban in the proper  
>   order.  
>  
> USAGE:   
>   ld-start [-d] [-h] [-v]  
>   ld-start [--dry-run] [--help] [--verbose]  
>  
> DESCRIPTION:  
>   Starts the services in the following order:  
>     * ipset  
>     * iptables  
>     * fail2ban  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-status`
> WHEN TO USE:   
>   When you want to status IP Tables, IP Set and Fail2Ban in the proper  
>   order.  
>  
> USAGE:   
>   ld-status [-d] [-h] [-v]  
>   ld-status [--dry-run] [--help] [--verbose]  
>  
> DESCRIPTION:  
>   Display the daemons status of each of the following:  
>     * ipset  
>     * iptables  
>     * fail2ban  
>    
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-stop`
> WHEN TO USE:   
>   When you want to stop IP Tables, IP Set and Fail2Ban in the proper  
>   order.  
>  
> USAGE:   
>   ld-stop [-d] [-h] [-v]  
>   ld-stop [--dry-run] [--help] [--verbose]  
>  
> DESCRIPTION:  
>   Stops the services in the following order:  
>     * fail2ban  
>     * iptables  
>     * ipset  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -h | --help  
>      Run help function and exit  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  

`ld-test`
> WHEN TO USE:    
>   When you want to see if an IP or range is in any of the lists.  
>  
> USAGE:   
>   ld-test <target>  
>   ld-test <target>  
>  
> DESCRIPTION:  
>   Checks all the lists to see if the provided target (in any of the formats  
>   used by ld-allow/block) matches any rules.  
>  
> OPTIONS:  
>   [1-9]\*  
>      Required  
>      Target IP, CIDR or short-code  

`ld-update-lists`
> WHEN TO USE:    
>   When you want to update provided lists, which you should probably do daily.  
>  
> USAGE:   
>   ld-update-lists [-d] [-f] [-g] [-h] [-s] [-v]  
>   ld-update-lists [--dry-run] [--force] [--github] [--help] [--silent] [--verbose]  
>  
> DESCRIPTION:  
>   Download the latest lists from the sites defined in the configuration  
>   file.  
>  
> OPTIONS:  
>   -d | --dry-run  
>      Echos the commands that would be executed rather than executing them  
>   -f | --force  
>      Force downloading even if update_lists is 0  
>   -g | --github  
>      Use Github even if use_github is 0  
>   -h | --help  
>      Run help function and exit  
>   -n | --no-github  
>      Force direct downloads even if use_github is 1  
>   -s | --silent  
>      No output of any kind  
>   -v | --verbose  
>      Output each line of the script after validations are parsed  


## Library Function Documentation

`determine_distro`
> How to use...  
> x -y -z  

`init_lockdown`
> How to use...  
> x -y -z  

`installation_report`
> How to use...  
> x -y -z  


## FAQ

  * How many is too many?
    - This set up is currently being used in production n a 24 core dedicated server with 128GB RAM as well as a 8 core 32GB Nginx cloud server and has had not measurable impact on CPU, RAM or NIC bandwidth while having **all** of the provided lists loaded!
  * What happens if I use this and something goes terribly, horribly wrong?
    - You are responsible for your own actions.
  * Is this software related to Fail2Ban, IP Set, IP Tables or X?
    - Only insofar as it uses them.
  * Will using this suite of software cure my DDOS problem?
    - It will most certainly help.  Of course, it does not actually perform rate limiting itself.  However, if you have rate limiting configured and this is running on an Nginx server, then IPs that Nginx blocks for exceeding the limit will be added to the Fail2Ban IP set if those blocks are logged.
  * Will this software stop hackers?
    - It will definitely deter robots and those using any sort of brute force tactics, but using this does not negate the need to properly secure all ports of entry.

## TODO

Can always use more configuration and command line options!
Download ASN lists directly from RIPE and convert
Make an NPM wrapper module


## Bug Reports & Contributions

Bug reports and code contributions are welcome.

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
