{dhcp, nettools}:

{
  name = "dhclient";
  
  job = "
description \"DHCP client\"

start on network-interfaces/started
stop on network-interfaces/stop

env PATH_DHCLIENT_SCRIPT=${dhcp}/sbin/dhclient-script

script
    export PATH=${nettools}/sbin:$PATH

    # Determine the interface on which to start dhclient.
    interfaces=

    for i in $(cd /sys/class/net && ls -d *); do
        if test \"$i\" != \"lo\"; then
            echo \"Running dhclient on $i\"
            interfaces=\"$interfaces $i\"
        fi
    done

    if test -z \"$interfaces\"; then
        echo 'No interfaces on which to start dhclient!'
        exit 1
    fi

    mkdir -m 755 -p /var/state/dhcp

    exec ${dhcp}/sbin/dhclient -d $interfaces -e \"PATH=$PATH\"
end script
  ";
  
}
