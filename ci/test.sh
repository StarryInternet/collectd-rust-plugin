#!/bin/bash

set -euo pipefail

cargo build --features collectd-54
cargo test --features collectd-54

sudo cp target/debug/libmyplugin.so /usr/lib/collectd/myplugin.so

cat <<EOF | sudo tee /etc/collectd/collectd.conf
Hostname "localhost"
LoadPlugin myplugin
LoadPlugin csv
<Plugin csv>
  DataDir "/var/lib/collectd/csv"
  StoreRates false
</Plugin>
<Plugin myplugin>
  Short "2"
  Long "5.5"
</Plugin>
EOF

sudo service collectd start
sleep 15
sudo service collectd status

sudo find /var/lib/collectd/csv/
grep '2.000000,10.000000,5.500000' /var/lib/collectd/csv/localhost/myplugin/load*
exit $?
