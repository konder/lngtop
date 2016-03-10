#!/bin/sh
#set -e
#
# This script is meant for quick & easy install via:
#   'curl -sSL https://raw.githubusercontent.com/konder/lngtop/master/devops/init-bj.sh | sh 

echo "*********************************************************************"
echo "****  Prepare account"
echo "*********************************************************************"

mkdir -p /root/.ssh
cat >> /root/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtAVZ5PwNnBTUUO6B7tr9z9IIOvaoJObkU2fxWTz1vPHug9qP97O5rjJ8Ouj1XHtkRg6aJmhTlTNyi9Q7aYC2gBA8n8lPJ9K4rVn6RhsJdw/ueOZuHZFE2OW4g8g9AE+4tjJudxlehf5JIQHg6ASu8qqeeyd5wcX9DDWxn8voIhCQqEPXZGsZhDGZI6YJoz8hAJTxOSMj8X3DqtL53EOpsF2//frEuWaMkygDpzTpmbBzAs4r/2B87l2bQl2vt8WM5Xn9+5IQi+Pkm/LkMh8PJcG7ZmFIiTCO8qijY2JxsnwTclu7pB1xXTueyP+jeHr0nKl86zacm0DCK+s+EsTgvw== zhangnan@relay
EOF
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

cat >> /etc/ssh/sshd_config <<EOF
RSAAuthentication yes
PubkeyAuthentication yes
PasswordAuthentication no
EOF
service sshd restart

sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0

echo "*********************************************************************"
echo "****  Install package"
echo "*********************************************************************"

yum update -y
yum install -y gcc gcc-c++ make
yum install -y ntpdate telnet chkconifg vim openssh-clients
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


cat >> /etc/security/limits.conf <<EOF
* soft nofile 32768
* hard nofile 65536
EOF

echo "*********************************************************************"
echo "****  Done"
echo "*********************************************************************"

exit 1
