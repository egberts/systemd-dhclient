#!/bin/bash

FILELIST="bind9.service dhclient@eth1.service networking.service network-online.target network-pre.target network.target nginx.service nss-lookup.target shorewall.service sys-subsystem-net-devices-eth1.device system-dhclient.slice"


CUSTOMLIST="nginx.service network-pre.target network-online.target network.target system-dhclient.slice sys-subsystem-net-devices-eth1.device networking.service nss-lookup.target shorewall.service bind9.service dhclient@eth1.service  ddclient.service resolvconf.service system-dhclient.slice"


function create_a_graph
{
  systemd-analyze dot $2 > $1.gv
  # Get rid of pesky 'shutdown.service' for it clutters the graph
  sed -i '/shutdown/d' ./$1.gv
  dot -Tjpg $1.gv > $1.jpg
  
}

for THISFILE in ${FILELIST}; do
  echo "Processing $THISFILE ..."
  create_a_graph $THISFILE "$THISFILE"
done

create_a_graph "custom" "$CUSTOMLIST"


