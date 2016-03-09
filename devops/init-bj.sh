#!/bin/sh
#set -e
#
# This script is meant for quick & easy install via:
#   'curl -sSL https://raw.githubusercontent.com/konder/lngtop/master/devops/init-bj.sh | sh 

echo "*********************************************************************"
echo "****  Prepare account"
echo "*********************************************************************"

useradd zhangnan
mkdir -p /home/zhangnan/.ssh
cat >> /home/zhangnan/.ssh/ <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGsu4nRVbnMyLOg0wxd3q3LAj6mNrDacLhiGLAcfTawv6tWQzIqldJS+1lTb/X3u9OX4FFxkXexM1X3iZkR040xzb+pQbdSzBocZe7dt0bNtvAUsBQAyJyPKOoOQgn9lkJ0CIZcaH8yTxUNkhKQGElYhl/GWbHH2tQIW+0dcv9/d1UfpQd7C1FI6tNGA/muTD2HevOsmB8IF6bGAApnU1TV88Kx5nthUd/aeWWtOJeC9IqsCKK1vHu0XT/97gYW4GQT9PZV4yigMqiRQz7fJQ/JUqDQafIQOqumlu3hdmIjWPO6NEkvTzTe7U+b7FozvSCrrrWk6mzh1utqn2DeM7r zhangnan.it
EOF
chown zhangnan:zhangnan /home/zhangnan

cat >> /etc/ssh/sshd_config <<EOF
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys
PasswordAuthentication no
EOF
service sshd restart

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


cat >> /etc/security/limits.conf <<EOF
* soft nofile 32768
* hard nofile 65536
EOF

echo "*********************************************************************"
echo "****  Done"
echo "*********************************************************************"

exit 1
