---
domain: 20
id: "NIXH-20-SEC-001"
title: "Fail2ban Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "claude-cloudflare-log-b99bb6b3"
tags: [security,fail2ban]
description: "Configure Fail2ban."
path: "docs/guides/GUIDE-20-fail2ban.md"
links:
  module: "modules/20-security/20-fail2ban.nix"
---

# Guide: Fail2ban Guide

```nix
my.security.fail2ban.enable = true;
```


---

## KB Nuggets

### Fail2ban Master-Reference
Jail-Template für SSH, Caddy, Pocket-ID. Endpoint-Liste aller geschützten Services. Ban-Time: 1h, Max-Retry: 3.
### Fail2ban Endpoints
SSH (port 53844), Caddy (443), Pocket-ID (OIDC). Alle mit nftables Backend für native Integration.

---
## Available Fail2ban Filters & Actions (from KB)

---
title: 🛡️ Fail2ban MASTER-ENDPOINT-LIST (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
capabilities: [intrusion-prevention, cloudflare-integration, declarative-security]
sources: [https://github.com/fail2ban/fail2ban (Source Code Extraction)]
---

# 🛡️ Fail2ban: Schnittstellen & Endpunkte

Dieses Dokument listet alle verfügbaren Filter und Aktionen auf, die wir in mynixos (\`modules/00-core/firewall.nix\`) deklarieren können.

## 🔍 Verfügbare Filter (102 Stück)
Filter definieren, welche Log-Patterns zu einem Ban führen.

3proxy
apache-auth
apache-badbots
apache-botsearch
apache-common
apache-fakegooglebot
apache-modsecurity
apache-nohome
apache-noscript
apache-overflows
apache-pass
apache-shellshock
assp
asterisk
bitwarden
botsearch-common
centreon
common
counter-strike
courier-auth
courier-smtp
cyrus-imap
dante
directadmin
domino-smtp
dovecot
dropbear
drupal-auth
ejabberd-auth
exim
exim-common
exim-spam
freeswitch
froxlor-auth
gitlab
grafana
groupoffice
gssftpd
guacamole
haproxy-http-auth
horde
kerio
lighttpd-auth
mongodb-auth
monit
monitorix
mssql-auth
murmur
mysqld-auth
nagios
named-refused
nginx-bad-request
nginx-botsearch
nginx-error-common
nginx-forbidden
nginx-http-auth
nginx-limit-req
nsd
openhab
openvpn
openwebmail
oracleims
pam-generic
perdition
phpmyadmin-syslog
php-url-fopen
portsentry
postfix
proftpd
proxmox
pure-ftpd
qmail
recidive
roundcube-auth
routeros-auth
scanlogd
screensharingd
selinux-common
selinux-ssh
sendmail-auth
sendmail-reject
sieve
slapd
softethervpn
sogo-auth
solid-pop3d
squid
squirrelmail
sshd
stunnel
suhosin
tine20
traefik-auth
uwimap-auth
vaultwarden
vsftpd
webmin-auth
wuftpd
xinetd-fail
xrdp
znc-adminlog
zoneminder

## ⚡ Verfügbare Aktionen (65 Stück)
Aktionen definieren, WAS passiert (z.B. IP blocken, Cloudflare benachrichtigen).

abuseipdb
apf
apprise
blocklist_de
bsd-ipfw
cloudflare
cloudflare-token
complain
csf
dshield
dummy
firewallcmd-allports
firewallcmd-common
firewallcmd-ipset
firewallcmd-multiport
firewallcmd-new
firewallcmd-rich-logging
firewallcmd-rich-rules
helpers-common
hostsdeny
ipfilter
ipfw
iptables
iptables-allports
iptables-ipset
iptables-ipset-proto4
iptables-ipset-proto6
iptables-ipset-proto6-allports
iptables-multiport
iptables-multiport-log
iptables-new
iptables-xt_recent-echo
ipthreat
mail
mail-buffered
mail-whois
mail-whois-common
mail-whois-lines
mikrotik
mynetwatchman
netscaler
nftables
nftables-allports
nftables-multiport
nginx-block-map
npf
nsupdate
osx-afctl
osx-ipfw
pf
route
sendmail
sendmail-buffered
sendmail-common
sendmail-geoip-lines
sendmail-whois
sendmail-whois-ipjailmatches
sendmail-whois-ipmatches
sendmail-whois-lines
sendmail-whois-matches
shorewall
shorewall-ipset-proto6
symbiosis-blacklist-allports
ufw
xarf-login-attack

## 🚀 SRE-Anwendung (Aviation-Grade)
Wir nutzen in NixOS die Option \`services.fail2ban.jails\`. Beispiel für Cloudflare-Banning:

\`\`\`nix
services.fail2ban.jails.sshd-cloudflare = {
  settings = {
    filter = "sshd";
    action = "cl
