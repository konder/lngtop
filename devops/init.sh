#!/bin/sh
set -e
#
# This script is meant for quick & easy install via:
#   'curl -sSL https://github.lngtop.com/lngtop/zhangnan/devops/init.sh | sh 

cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

yum install -y ntpdate  chkconifg
chkconfig ntpdate on

tmpfile=/tmp/crontab.tmp

# add custom entries to crontab
echo '*/1 * * * * /usr/sbin/ntpdate time.windows.com &>/var/log/ntpdate.log' > $tmpfile

#load crontab from file
crontab $tmpfile

# remove temporary file
rm $tmpfile

# restart crontab
/etc/init.d/crond.sh restart
