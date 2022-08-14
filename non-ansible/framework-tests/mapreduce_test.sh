hdfs dfs -mkdir input
hdfs dfs -put /usr/local/hadoop/current/LICENSE.txt input/

#This runs as an uber-task and thus we need a bit more memory than configured per default
yarn jar /usr/local/hadoop/current/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar multifilewc \
-Dyarn.app.mapreduce.am.command-opts="-Xmx2560m" \
-Dyarn.app.mapreduce.am.resource.mb="3072" \
/user/$USER/input /user/$USER/output

#Print and delete results
hdfs dfs -cat output/part-r-00000 | head
hdfs dfs -rm -r output/


# Calc PI
yarn jar /usr/local/hadoop/current/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 1000
