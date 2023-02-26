#!/bin/bash

java -version

echo "RUN:source /etc/profile"
source /etc/profile
# 申请给start-all.sh使用
# tnnd,start-all.sh内部接收不到JAVA_HOME的环境变量
declare JAVA_HOME=$JAVA_HOME



# start 1
echo "RUN:/usr/sbin/sshd"
nohup /usr/sbin/sshd -D 2>&1 &

# hdfs namenode -format
FILE=/data/hdfs_format
if [ ! -f "$FILE" ]; then
    echo "RUN:hdfs namenode -format"
    # mkdir /data
    # chmod 750 /data
    hdfs namenode -format
    touch $FILE
fi

# start 2
echo "RUN:start-all.sh"
start-all.sh
# nohup bash start-all.sh 2>&1 &
# start 3
echo "RUN:mapred --daemon start historyserver"
mapred --daemon start historyserver
# nohup mapred --daemon start historyserver  2>&1 &


echo "RUN:Keep Script,EXPOSE 22 9000 9870 8088 19888"
# just keep this script running
while [[ true ]]; do
    sleep 100
done