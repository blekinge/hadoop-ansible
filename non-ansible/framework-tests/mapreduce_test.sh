hdfs dfs -mkdir input
hdfs dfs -put /usr/local/hadoop/current/LICENSE.txt input/
yarn jar /usr/local/hadoop/current/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount /user/$USER/input /user/$USER/output