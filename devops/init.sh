#!/bin/sh
#set -e
#
# This script is meant for quick & easy install via:
#   'curl -sSL http://vm-support.lngtop.com/devops/init.sh | sh 

echo "*********************************************************************"
echo "****  Install package"
echo "*********************************************************************"

yum update -y
yum install -y gcc gcc-c++ make
yum install -y ntpdate  chkconifg
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

echo "*********************************************************************"
echo "****  Done"
echo "*********************************************************************"

exit 1
