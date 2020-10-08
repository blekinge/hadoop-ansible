hdfs dfs -mkdir input
hdfs dfs -put /usr/local/hadoop/hadoop-3.3.0/LICENSE.txt input/
yarn jar /usr/local/hadoop/hadoop-3.3.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.0.jar wordcount /user/$USER/input /user/$USER/output