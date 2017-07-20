#!/system/bin/sh

# setup bridge with all external interfaces and the i210
/system/bin/brctl addbr br0
for IFACE in netleft netright netaux gigabit_proc; do
	/system/bin/brctl addif br0 $IFACE
done
/system/bin/sleep 1

# bring everything up
for IFACE in eth0 eth1 netleft netright netaux gigabit_proc br0; do
	/system/bin/ip link set dev $IFACE up
done
/system/bin/sleep 1

# static IP addressing in the i210
/system/bin/ip addr add 172.16.1.1/16 dev eth1

