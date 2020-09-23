systemctl stop namenode
systemctl stop datanode
systemctl stop journalnode

rm -rf /usr/local/hadoop
rm -rf /etc/hadoop

rm -rf /hdfs/data/*
rm -rf /hdfs/name
rm -rf /hdfs/journal