#!/bin/sh
#set -e
#
# This script is meant for quick & easy install via:
#   'curl -sSL https://raw.githubusercontent.com/konder/lngtop/master/devops/init.sh | sh 

echo "*********************************************************************"
echo "****  Install package"
echo "*********************************************************************"

yum update -y
yum install -y gcc gcc-c++ make
yum install -y ntpdate  chkconifg vim
chkconfig ntpdate on

echo "*********************************************************************"
echo "****  Change timezone"
echo "*********************************************************************"

cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
tmpfile=/tmp/crontab.tmp

# add custom entries to crontab
echo '*/1 * * * * /usr/sbin/ntpdate time.windows.com &>/var/log/ntpdate.log' > $tmpfile

#load crontab from file
crontab $tmpfile

# remove temporary file
rm $tmpfile

# restart crontab
service crond restart

echo "*********************************************************************"
echo "****  watch by ganglia"
echo "*********************************************************************"

rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum install -y ganglia-gmond
sed -i 's/name = "unspecified"/name = "Production"/' /etc/ganglia/gmond.conf
service gmond start

echo "*********************************************************************"
echo "****  monitor by newrelic"
echo "*********************************************************************"
rpm -Uvh https://download.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm
yum install -y newrelic-sysmond
nrsysmond-config --set license_key=c7809bb456d5f623fec2539113ecb3c11515eb19
/etc/init.d/newrelic-sysmond start

echo "*********************************************************************"
echo "****  mount disk"
echo "*********************************************************************"

fdisk /dev/vda << End
n
p
2


w
End

partx -a /dev/vda
partx -a /dev/vda
mkfs.ext4 /dev/vda2
mkdir /data 
mount  /dev/vda2 /data
echo "/dev/vda2 /data ext4 defaults 0 0" >> /etc/fstab

sed -i 's/openstacklocal/openstacklocal\nnameserver 172.16.100.111/' /etc/resolv.conf

cat >> /etc/security/limits.conf <<EOF
* soft nofile 32768
* hard nofile 65536
EOF

echo "*********************************************************************"
echo "****  Done"
echo "*********************************************************************"

exit 1
