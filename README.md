
DHCLIENT on systemd (starting with Debian distro).


## About systemd-dhclient

ISC DHCP client is superior in many aspects over systemd DHCP client.


## Why did I make this?

I replaced the Verizon-supplied customer-premise-equipment (CPE) which was
a Motorola Actiontec wireless broadband router.

That CPE got replaced with a custom-made Linux gateway.

Since forever, I have been using the ISC DHCP client for interacting with 5 different ISP DHCP servers (mostly Juniper Network).  I've found out that systemd v232 still cannot handle these funky ISP DHCP servers.  

Also it was too late, I have had upgraded to Debian 9 and systemd was in near-full force as a default.  Thereby my remaining requirement to continue using ISC DHCP client.


## systemd DHCP limitations 

I needed DHCP-Options that are still not being found in systemd-dhcp-client. 
So, it becomes imperative that I continue to use ISC DHCP client 
despite pervasiveness of systemd.

I also like Dynamic DNS update which is those fancy communication between BIND9 DNS server and DHCP server.  systemd-ddns is also nice but it didn't have other things (described in next section).  Again, too much invested into ISC BIND9 and ISC DHCP server.

systemd-dhcp-server also cannot do custom database interfaces.

systemd-dhcp-server cannot do dynamic hostname replacement regardless of MAC address.

systemd-dhcp-server cannot do failover and high-redundancy.


## Building your own customization

There is only one INSTALL script file.   It should be run firstly in non-root mode.

This INSTALL script file will read various files in /etc as needed and attempt to create a customized version for starting ISC DHCP client within systemd framework.

This script file does not and will not make any modification toward your system, instead it places all new files into its build/ subdirectory for your casual integration effort.  As a bonus, it will search for your existing settings and copy it to the build/ so you can preview it firstly before venturing out into the infinite horizon, or something.

I cannot safely write a script to auto-modify all these root-owned system files without breaking systemd boot-up sequence.  Hence, the build/ subdir approach.

You can also safely run it in as a root-user with zero impact on your /etc directory and its content.  If you do run as a root user, the files in build/ will have their correct file permissions and file ownerships too.


## Obtaining help

To report a bug, use the [issue tracker](https://github.com/egberts/systemd-dhclient/issues).

