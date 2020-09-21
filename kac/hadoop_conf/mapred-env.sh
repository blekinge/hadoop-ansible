
# We need to add the DRFAS appender for the mapred daemons only;
# however, HADOOP_SECURITY_LOGGER is shared by the mapred client and the
# daemons. This is restrict the DRFAS appender to daemons only.
INVOKER="${0##*/}"
if [ "$INVOKER" == "mr-jobhistory-daemon.sh" ]; then
    #DRFAS is defined in hdfs-log4j.properties
    export HADOOP_SECURITY_LOGGER=INFO,DRFAS

    #DRFA is defined in hdfs-log4j.properties
    export HADOOP_ROOT_LOGGER=INFO,DRFA
    export HADOOP_MAPRED_ROOT_LOGGER=INFO,DRFA
    export HADOOP_JHS_LOGGER=INFO,DRFA

    #JSA is defined in yarn-log4j.properties
    export HADOOP_MAPRED_JOBSUMMARY_LOGGER=INFO,JSA
fi


#DRFAS is defined in hdfs-log4j.properties
export HADOOP_SECURITY_LOGGER=${HADOOP_SECURITY_LOGGER:-"INFO,DRFAS"}

#DRFA is defined in hdfs-log4j.properties
export HADOOP_ROOT_LOGGER=${HADOOP_ROOT_LOGGER:-"INFO,DRFA"}
export HADOOP_MAPRED_ROOT_LOGGER=${HADOOP_MAPRED_ROOT_LOGGER:-"INFO,DRFA"}
export HADOOP_JHS_LOGGER=${HADOOP_JHS_LOGGER:-"INFO,DRFA"}

#JSA is defined in yarn-log4j.properties
export HADOOP_MAPRED_JOBSUMMARY_LOGGER=${HADOOP_MAPRED_JOBSUMMARY_LOGGER:-"INFO,JSA"}


#export HADOOP_MAPRED_LOG_DIR="" # Where log files are stored.  $HADOOP_MAPRED_HOME/logs by default.

export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=3072

#export HADOOP_JOB_HISTORYSERVER_OPTS=

#export HADOOP_MAPRED_PID_DIR= # The pid files are stored. /tmp by default.
#export HADOOP_MAPRED_IDENT_STRING= #A string representing this instance of hadoop. $USER by default
#export HADOOP_MAPRED_NICENESS= #The scheduling priority for daemons. Defaults to 0.
export HADOOP_OPTS="-Dhdp.version=$HDP_VERSION $HADOOP_OPTS"
export HADOOP_OPTS="-Djava.io.tmpdir=/var/lib/ambari-agent/tmp/hadoop_java_io_tmpdir $HADOOP_OPTS"
export HADOOP_OPTS="-Dhadoop.mapreduce.jobsummary.logger=$HADOOP_MAPRED_JOBSUMMARY_LOGGER $HADOOP_OPTS"
export JAVA_LIBRARY_PATH="${JAVA_LIBRARY_PATH}:/var/lib/ambari-agent/tmp/hadoop_java_io_tmpdir"