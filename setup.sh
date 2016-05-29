#download, compile, and install BIND.
apt-get -qq update && apt-get -qq upgrade
apt-get -qq install gcc make wget libssl-dev
cd /tmp
wget -q -O bind-9.9.9-P1.tar.gz ftp://ftp.isc.org/isc/bind9/9.9.9-P1/bind-9.9.9-P1.tar.gz
tar -xzf bind-9.9.9-P1.tar.gz
cd /tmp/bind-9.9.9-P1
./configure --with-openssl --disable-linux-caps
make -j4
groupadd bind && useradd -g bind -d /tmp -M -r -s /bin/false bind
make install
mkdir /var/log/bind && chown bind:bind /var/log/bind
mkdir -p /var/named/zones/slave && chown bind:bind /var/named/zones/slave
rndc-confgen >/etc/rndc.conf
sed -i "s%^.*_RNDC_SECRET_GOES_HERE_.*$%`grep -m 1 'secret' /etc/rndc.conf`%" /etc/named.conf
mkdir /etc/service/bind
echo "#!/bin/sh" >/etc/service/bind/run
echo "exec /usr/local/sbin/named -g -4 -c /etc/named.conf -u bind" >>/etc/service/bind/run
chmod +x /etc/service/bind/run

#Cleanup
cd /
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
