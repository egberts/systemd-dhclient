
DHCLIENT on systemd (starting with Debian distro).


## About systemd-dhclient

You have choices of many different DHCP clients, but the ones that is built into systemd is stunted and too simple for use with  Verizon FiOS network.  

This here will allow one (or many separate) ISC dhclients to run independently on platforms running `systemd`.


## Why did I make this?

I replaced the Verizon-supplied customer-premise-equipment (CPE) (aka cablemodem, MoCA media gateway router) which was
a Motorola Actiontec wireless broadband router.

I replaced the ISP-provided CPE with my custom-made Linux gateway.

Since the dawn of time, I have been using the ISC DHCP client for interacting with 5 different ISPs' DHCP server (mostly Juniper Network).  I've found out that systemd v232 still cannot handle these funky ISP DHCP servers.  

Also it was too late, for I had upgraded to Debian 9 and the feature-weak systemd was nearly a solid Debian default.  I needed to revert back to ISC DHCP client.

## systemd DHCP limitations 

Some of the limitation of systemd's DHCP client is that there is no DHCP-Options.

Hence the need to use ISC DHCP client despite pervasiveness of systemd's own built-in DHCP client.

I also like Dynamic DNS update which is those fancy communication between BIND9 DNS server and DHCP server.  systemd-ddns is also nice but it didn't have other things (described in next section).  Again, my gateway had too much invested into the usages of ISC BIND9 and ISC DHCP server.

systemd-dhcp-server also cannot do custom database interfaces.

systemd-dhcp-server cannot do dynamic hostname replacement regardless of MAC address.

systemd-dhcp-server cannot do failover and high-redundancy.


## Building your own customization

I have provided only one INSTALL script file.   It should be run firstly in non-root mode.

This INSTALL script file will read various configuration files in /etc as needed and attempt to create a customized version for starting ISC DHCP client within systemd framework.

This script file does not and will not make any modification toward your system, instead it places all new files into its build/ subdirectory for your casual integration effort.  As a bonus, it will search for your existing settings and copy it to the build/ so you can preview it firstly before venturing out into the infinite horizon, or something.

I cannot safely write a script to auto-modify all these root-owned system files without breaking systemd boot-up sequence.  Hence, this `build/` subdir approach.

You can also safely run it in as a root-user with zero impact on your /etc directory and its content.  If you do run as a root user, the files in build/ will have their correct file permissions and file ownerships too.

## Your prerequisites

After creating the build/ subdirectory and its content, you'll want to do a checklist before copying your custom-built files over as is.

NOTE: You cannot have both systemd-networkd and NetworkManager systemd units enabled and/or running: pick only one, then disable the other.

    systemctl is-active systemd-networkd NetworkManager

output result should show:

    active
    inactive

If systemd-networkd is active, you're good to continue.


##  Final Step 

Kill off all older DHCP client daemons.

    killall -KILL dhclient
    killall -KILL dhcpcd
    killall -KILL udhcp
    # older systemd DHCP client will go away ... in following steps

Make your current systemd take in all those new files.

    systemctl daemon-reload

Activate the new systemd unit file, dhclient@ethX.service

    systemctl enable dhclient@ethX.service
    systemctl start dhclient@ethX.service

And restart the network

    systemctl restart networking.service

## Obtaining help

To report a bug, use the [issue tracker](https://github.com/egberts/systemd-dhclient/issues).

## Graphs of systetmd

For a graph of various systemd dependency chart related to dhclient@.service, see [this wiki here](https://github.com/egberts/systemd-dhclient/wiki).
