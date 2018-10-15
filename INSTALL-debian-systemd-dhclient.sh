#!/bin/bash

echo "This installer makes ZERO changes to your system."
echo "It can run as non-root user, and is recommended to do so"
echo "All stuff to install are in build/ subdirectory."
echo " "
echo "Putting all new and changed files into build/ subdirectory"
if [ -d build/ ]; then
  echo "Cleaning out build/ subdirectory ..."
    rm -rf build/*
else
  echo "Creating build/ subdirectory ..."
  mkdir build
  chmod a+rx build
fi
echo " "
echo "This is ususally your public-facing, internet interface name"
echo "Most commonly 'eth0'"
echo -n "What is your DHCLIENT interface name? (default: eth0): "
read INTERFACE
if [ -z ${INTERFACE} ]; then
    INTERFACE=eth0
fi
echo " "
echo "This is NOT your ISP router's MAC. This may take some digging..."
echo "  See https://192.168.1.1/ for ONT's MAC address"
echo "What is your ONT's MAC address? (no default): "
read ISP_CPE_ROUTER_WAN_MAC
if [ -z ${ISP_CPE_ROUTER_WAN_MAC} ]; then
    echo "Go do some research and get the ONT MAC address."
    echo "No, Verizon cannot tell you this."
    echo "No, it is not the ones that is marked on your Actiontec Modem."
    exit 1
fi
echo "My ISP-provided WAN-side MAC address is: ${ISP_CPE_ROUTER_WAN_MAC}"


mkdir -p build/etc/default
echo "Copying default environment file..."
cp etc/default/dhclient build/etc/default/dhclient
sed -i '1 i# File: \/etc\/default\/dhclient' build/etc/default/dhclient
chown root:root build/etc/default/dhclient
chmod 0640 build/etc/default/dhclient

DEFAULT_DHCLIENT_INTF=etc/default/dhclient.${INTERFACE}
cp etc/default/dhclient.interface-specific build/${DEFAULT_DHCLIENT_INTF}
sed -i "1 i# File: \/${DEFAULT_DHCLIENT_INTF}" build/${DEFAULT_DHCLIENT_INTF}
sed -i "s/dhclient@/dhclient@${INTERFACE}/g" build/${DEFAULT_DHCLIENT_INTF}
chown root:root build/${DEFAULT_DHCLIENT_INTF}
chmod 0640 build/${DEFAULT_DHCLIENT_INTF}

echo "Appending to your /etc/rc.local file..."
mkdir -p build/etc
sed "s/REPLACE_WITH_ISP_WAN_MACADDRESS/${ISP_CPE_ROUTER_WAN_MAC}/g" etc/rc.local.supplemental> build/etc/rc.local

echo "If you got stuff to run after your gateway receives an IP address"
echo "from your ISP provider, then put startup scripts into"
echo "the /etc/dhcp/dhclient-enter-hooks.d/ subdirectory."
echo "Sample files are in etc/dhcp/dhclient-enter-hooks.d directory."


# .link files for systemd network
echo " "
echo "Going through *.link files in /etc/systemd/network ..."
DOTLINK_FILELIST=`find /etc/systemd/network -name "*.link" -printf "%f "`
DOTLINK_COUNT=0
for THISFILE in ${DOTLINK_FILELIST}; do
  # Search for any prior or existing interface amongst the systemd link files
  grep -qc -r "^[Nn][Aa][Mm][Ee] *= *${INTERFACE}" /etc/systemd/network/${THISFILE}
  RETSTS=$?
  if [ ${RETSTS} -eq 0 ]; then
    echo "Found ${INTERFACE} in ${THISFILE} systemd .link file."
    let DOTLINK_COUNT=${DOTLINK_COUNT}+1
    FOUND_DOTLINKFILE=${THISFILE}
  fi
done
mkdir -p build/etc/systemd/network
if [ 0 -eq ${DOTLINK_COUNT} ]; then
  NEW_DOTLINKFILE=etc/systemd/network/10-${INTERFACE}.link
  echo " "
  echo "Creating build/${NEW_DOTLINKFILE} file ..."
  cp etc/systemd/network/10-eth.link build/${NEW_DOTLINKFILE}
  sed -i "s/REPLACE_WITH_MY_NEW_GATEWAY_PUBLIC_INTERNET_NETDEV_NAME/${INTERFACE}/g" build/${NEW_DOTLINKFILE}
  sed -i "s/REPLACE_WITH_ISP_CPE_WAN_MAC_ADDRESS/${ISP_CPE_ROUTER_WAN_MAC}/g" build/${NEW_DOTLINKFILE}
  chown root:root build/${NEW_DOTLINKFILE}
  chmod 0640 build/${NEW_DOTLINKFILE}
  echo " "
  echo "Press RETURN to continue."
  read ANYKEY
elif [ 1 -eq ${DOTLINK_COUNT} ]; then
  EXISTING_DOTLINKFILE=etc/systemd/network/${FOUND_DOTLINKFILE}
  echo "Found your ${INTERFACE} in /${EXISTING_DOTLINKFILE}."
  echo "Copying it aside into build/${EXISTING_DOTLINKFILE}"
  cp /${EXISTING_DOTLINKFILE} build/${EXISTING_DOTLINKFILE}
  echo "Modifying build/${EXISTING_DOTLINKFILE} ..."
  sed -i "s/^MACAddress=.*/MACAddress=${ISP_CPE_ROUTER_WAN_MAC}/g" build/${EXISTING_DOTLINKFILE}
  chown root:root build/${EXISTING_DOTLINKFILE}
  chmod 0640 build/${EXISTING_DOTLINKFILE}
  echo " "
  echo "Press RETURN to continue."
  read ANYKEY
else
  echo "SYSTEM CONFIGURATION ERROR"
  echo "You have multiple .link files in /etc/systemd/network having"
  echo "the same ${INTERFACE} interface.  Fix that first. ABORTING..."
  exit 1
fi

# .network files for systemd network
echo " "
echo "Going through *.network files in /etc/systemd/network ..."
DOTNETWORK_FILELIST=`find /etc/systemd/network -name "*.network" -printf "%f "`
DOTNETWORK_COUNT=0
for THISFILE in ${DOTNETWORK_FILELIST}; do
  # Search for any prior or existing interface amongst the systemd link files
  grep -qc -r "^[Nn][Aa][Mm][Ee] *= *${INTERFACE}" /etc/systemd/network/${THISFILE}
  RETSTS=$?
  if [ ${RETSTS} -eq 0 ]; then
    echo "Found ${INTERFACE} in ${THISFILE} systemd .network file."
    let DOTNETWORK_COUNT=${DOTNETWORK_COUNT}+1
    FOUND_NETWORKFILE=${THISFILE}
  fi
done

mkdir -p build/etc/systemd/network
if [ 0 -eq ${DOTNETWORK_COUNT} ]; then
  NEW_NETWORKFILE=etc/systemd/network/20-${INTERFACE}-public-internet-red.network
  echo " "
  echo "Creating build/${NEW_NETWORKFILE} file ..."
  cp  etc/systemd/network/20-public-internet-red.network build/${NEW_NETWORKFILE}
  sed -i "1 i# File: /${NEW_NETWORKFILE}" build/${NEW_NETWORKFILE}
  sed -i "s/REPLACE_WITH_MY_NEW_GATEWAY_PUBLIC_INTERNET_NETDEV_NAME/${INTERFACE}/g" build/${NEW_NETWORKFILE}
  chown root:root build/${NEW_NETWORKFILE}
  chmod 0640 build/${NEW_NETWORKFILE}
  echo " "
  echo "Press RETURN to continue."
  read ANYKEY
elif [ 1 -eq ${DOTNETWORK_COUNT} ]; then
  EXISTING_DOTNETWORKFILE=etc/systemd/network/${FOUND_NETWORKFILE}
  echo "Found your ${INTERFACE} in /${EXISTING_DOTNETWORKFILE}."
  echo "Copying it aside into build/${EXISTING_DOTNETWORKFILE}"
  cp /${EXISTING_DOTNETWORKFILE} build/${EXISTING_DOTNETWORKFILE}
  echo "Modifying build/${EXISTING_DOTNETWORKFILE} ..."
  sed -i 's/^DHCP=.*/DHCP=off/g' build/${EXISTING_DOTNETWORKFILE}
  grep -i "^Unmanaged *=" build/${EXISTING_DOTNETWORKFILE}
  RETSTS=$?
  if [ $RETSTS -ne 0 ]; then
    echo "Modifying Unmanaged= option missing in build/${EXISTING_DOTNETWORKFILE}..."
    sed -i 's/^[Uu][Nn][Mm][Aa][Nn][Aa][Gg][Ee][Dd] *= *.*/Unmanaged=yes/g' build/${EXISTING_DOTNETWORKFILE}
  else
    echo "Unmanaged=yes option missing, inserting into build/${EXISTING_DOTNETWORKFILE}..."
    sed 's/.*Name *=.*/&\nUnmanaged=yes\n/' build/${EXISTING_DOTNETWORKFILE}
  fi
  chown root:root build/${EXISTING_DOTNETWORKFILE}
  chmod 0640 build/${EXISTING_DOTNETWORKFILE}
  echo " "
  echo "Press RETURN to continue."
  read ANYKEY
else
  echo "SYSTEM CONFIGURATION ERROR"
  echo "You have multiple .network files in /etc/systemd/network having"
  echo "the same ${INTERFACE} interface.  Fix that first. ABORTING..."
  exit 1
fi

mkdir -p build/etc/systemd/system
echo "Copying dhclient@.service file to /etc/systemd/system directory..."

# Copy the generic systemd service file for dhclient
DOTSERVICEFILE=etc/systemd/system/dhclient@.service
cp etc/systemd/system/dhclient@.service build/${DOTSERVICEFILE}
chmod 0640 build/${DOTSERVICEFILE}
chown root:root build/${DOTSERVICEFILE}

# Make a link of the interface-specific systemd service file for dhclient
NEW_DOTSERVICEFILE=etc/systemd/system/dhclient@${INTERFACE}.service
ln -s build/${DOTSERVICEFILE} build/${NEW_DOTSERVICEFILE}

# We cannot make hard copy of interface-specific systemd service file
# Only symbolic link is allowed on interface-specific service file
