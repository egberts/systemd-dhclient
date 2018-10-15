
Using DHCLIENT on systemd (starting with Debian).

![systemd_dhclient_diagram](http://www.burningcutlery.com/images/dynamorio/drlogo.png)



## About systemd-dhclient

ISC DHCP client is superior in many aspects over systemd DHCP.


## Why did I make this?

I replaced the Verizon-supplied customer-premise-equipment (CPE) which was
a Motorola Actiontec wireless broadband router.

That CPE got replaced with a custom-made Linux gateway.

Since forever, I've used ISC DHCP client for interacting with 5 different ISP DHCP servers (mostly Juniper Network).  I've found out that systemd v232 cannot handle these funky ISP DHCP servers.  

Also it was too late, I've updated to Debian 9 and systemd was in near-full force.  Thereby my remaining requirement to continue using ISC DHCP clientt.


## systemd DHCP limitations 

I needed DHCP-Options that are still not found in systemd-dhcp-client. 
So, it becomes imperative that I continue to use ISC DHCP client 
despite invasion of systemd.

I also like Dynamic DNS update which is those fancy communication between BIND9 DNS server and DHCP server.  systemd-ddns is nice and not yet easily integrated with ISC BIND/DHCP server.  Again, too much invested into ISC BIND9 and ISC DHCP server.

systemd-dhcp-server also cannot do custom database interfaces.

systemd-dhcp-serer cannot do dynamic hostname replacement regardless of MAC address.

systemd-dhcp-server cannott do failover and high-redundancy.


## Building your own customizatiton

There is only one script file.   It should be run in non-root mode.

This script file does not and will not make any modification toward your system, instead it places all new files into its build/ subdirectory for your casual integration step.  As a bonus, it will search for your existing settings and copy it to the build/ so you can preview it firstly before venturing out into the infinite horizon, or something.

I cannot safely write a script to auto-modify all these root-owned system files without breaking systemd boot-up sequence.  Hence, the build/ subdir approach.

You can run it in as a root-user.  If you do run as a root user, the files in build/ will have their correct file permissions and file ownerships too.


## Obtaining help

To report a bug, use the [issue tracker](https://github.com/egberts/systemd-dhclient/issues).

