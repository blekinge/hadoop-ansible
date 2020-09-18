
      # Set Hadoop-specific environment variables here.

      # The only required environment variable is JAVA_HOME.  All others are
      # optional.  When running a distributed configuration it is best to
      # set JAVA_HOME in this file, so that it is correctly defined on
      # remote nodes.

      # The java implementation to use.  Required.
      export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
      export HADOOP_HOME_WARN_SUPPRESS=1

      # Hadoop home directory
      export HADOOP_HOME=${HADOOP_HOME:-/usr/hdp/2.6.5.0-292/hadoop}

      # Hadoop Configuration Directory

      
      # Path to jsvc required by secure HDP 2.0 datanode
      export JSVC_HOME=/usr/lib/bigtop-utils


      # We need to add the HADOOP Root logger for the daemons only;
      # however, HADOOP_ROOT_LOGGER is shared by the client and the
      # daemons. This is restrict the root logger appender to daemons only.
      INVOKER="${0##*/}"
      if [ "$INVOKER" == "hadoop-daemon.sh" ]; then
        export HADOOP_ROOT_LOGGER=${HADOOP_ROOT_LOGGER:-"INFO,DRFA"}
        export HADOOP_SECURITY_LOGGER=${HADOOP_SECURITY_LOGGER:-"INFO,DRFAS"}
        export HDFS_AUDIT_LOGGER=${HDFS_AUDIT_LOGGER:-"INFO,DRFAAUDIT"}

        export MAPRED_AUDIT_LOGGER=${MAPRED_AUDIT_LOGGER:-"INFO,MRAUDIT"}
        export MAPRED_JOBSUMMARY_LOGGER=${MAPRED_JOBSUMMARY_LOGGER:-"INFO,JSA"}
      fi

      #Basic hadoop log config
      HADOOP_LOG_OPTS="-Dhadoop.security.logger=$HADOOP_SECURITY_LOGGER \
                       -Dhdfs.audit.logger=$HDFS_AUDIT_LOGGER \
                       $RANGER_LOGGER"


      # The maximum amount of heap to use, in MB. Default is 1000.
      export HADOOP_HEAPSIZE="1024"

      export HADOOP_NAMENODE_INIT_HEAPSIZE="-Xms4096m"

      # Extra Java runtime options.  Empty by default.
      export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true ${HADOOP_OPTS}"




      #Options commons for all the HDFS daemons
      HADOOP_COMMON_DAEMON_OPTS="-server \
                                 -XX:ErrorFile=/var/log/hadoop/$USER/hs_err_pid%p.log"

      #The Garbage collector config for the NameNode
      HADOOP_NAMENODE_GC_OPTS="-XX:ParallelGCThreads=8 \
                                -XX:+UseConcMarkSweepGC \
                                -XX:NewSize=512m \
                                -XX:MaxNewSize=512m \
                                -XX:CMSInitiatingOccupancyFraction=70 \
                                -XX:+UseCMSInitiatingOccupancyOnly"

      #Garbage Collection log config. This is shared between namenode and datanode
#      GC_LOG_OPTS="-Xloggc:/var/log/hadoop/$USER/gc.log-`date +'%Y%m%d%H%M'` \
#                   -verbose:gc \
#                   -XX:+PrintGCDetails \
#                   -XX:+PrintGCTimeStamps \
#                   -XX:+PrintGCDateStamps"


      #Common options for the Primary and Secondary NameNode
      SHARED_HADOOP_NAMENODE_OPTS="$HADOOP_COMMON_DAEMON_OPTS \
                                   $HADOOP_NAMENODE_GC_OPTS \
                                   $GC_LOG_OPTS  \
                                   -Xms4096m \
                                   -Xmx4096m \
                                   $HADOOP_LOG_OPTS"

      #The Primary NameNode opts
      export HADOOP_NAMENODE_OPTS="${SHARED_HADOOP_NAMENODE_OPTS} \
                                   -XX:OnOutOfMemoryError=\"/usr/hdp/current/hadoop-hdfs-namenode/bin/kill-name-node\" \
                                   -Dorg.mortbay.jetty.Request.maxFormContentSize=-1"
      #The Secondary NameNode opts
      export HADOOP_SECONDARYNAMENODE_OPTS="${SHARED_HADOOP_NAMENODE_OPTS} \
                                            -XX:OnOutOfMemoryError=\"/usr/hdp/current/hadoop-hdfs-secondarynamenode/bin/kill-secondary-name-node\" \
                                            ${HADOOP_SECONDARYNAMENODE_OPTS}"

      #The Garbage collector config for the DataNode
      HADOOP_DATANODE_GC_OPTS="-XX:ParallelGCThreads=4 \
                               -XX:+UseConcMarkSweepGC \
                               -XX:NewSize=200m \
                               -XX:MaxNewSize=200m \
                               -XX:CMSInitiatingOccupancyFraction=70 \
                               -XX:+UseCMSInitiatingOccupancyOnly"

      #The DataNode opts
      export HADOOP_DATANODE_OPTS="$HADOOP_COMMON_DAEMON_OPTS \
                                   $HADOOP_DATANODE_GC_OPTS \
                                   $GC_LOG_OPTS  \
                                   -Xms2048m \
                                   -Xmx2048m \
                                   $HADOOP_LOG_OPTS"




      # The following applies to multiple commands (fs, dfs, fsck, distcp etc)
      export HADOOP_CLIENT_OPTS="-Xmx${HADOOP_HEAPSIZE}m $HADOOP_CLIENT_OPTS"

      HADOOP_NFS3_OPTS="-Xmx1024m \
                        -Dhadoop.security.logger=ERROR,DRFAS \
                        ${HADOOP_NFS3_OPTS}"
      
      HADOOP_BALANCER_OPTS="-server \
                            -Xmx1024m \
                            ${HADOOP_BALANCER_OPTS}"


      # On secure datanodes, user to run the datanode as after dropping privileges
      export HADOOP_SECURE_DN_USER=${HADOOP_SECURE_DN_USER:-hdfs}

      # Extra ssh options.  Empty by default.
      export HADOOP_SSH_OPTS="-o ConnectTimeout=5 -o SendEnv=HADOOP_CONF_DIR"

      # Where log files are stored.  $HADOOP_HOME/logs by default.
      export HADOOP_LOG_DIR=/var/log/hadoop/$USER

      # History server logs
      export HADOOP_MAPRED_LOG_DIR=/var/log/hadoop-mapreduce/$USER

      # Where log files are stored in the secure data environment.
      export HADOOP_SECURE_DN_LOG_DIR=/var/log/hadoop/$HADOOP_SECURE_DN_USER

      # File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
      # export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

      # host:path where hadoop code should be rsync'd from.  Unset by default.
      # export HADOOP_MASTER=master:/home/$USER/src/hadoop

      # Seconds to sleep between slave commands.  Unset by default.  This
      # can be useful in large clusters, where, e.g., slave rsyncs can
      # otherwise arrive faster than the master can service them.
      # export HADOOP_SLAVE_SLEEP=0.1

      # The directory where pid files are stored. /tmp by default.
      export HADOOP_PID_DIR=/var/run/hadoop/$USER
      export HADOOP_SECURE_DN_PID_DIR=/var/run/hadoop/$HADOOP_SECURE_DN_USER

      # History server pid
      export HADOOP_MAPRED_PID_DIR=/var/run/hadoop-mapreduce/$USER

      YARN_RESOURCEMANAGER_OPTS="-Dyarn.server.resourcemanager.appsummary.logger=INFO,RMSUMMARY"

      # A string representing this instance of hadoop. $USER by default.
      export HADOOP_IDENT_STRING=$USER

      # The scheduling priority for daemon processes.  See 'man nice'.

      # export HADOOP_NICENESS=10

      # Add database libraries
      JAVA_JDBC_LIBS=""
      if [ -d "/usr/share/java" ]; then
        for jarFile in `ls /usr/share/java | grep -E "(mysql|ojdbc|postgresql|sqljdbc)" 2>/dev/null`
        do
            JAVA_JDBC_LIBS=${JAVA_JDBC_LIBS}:$jarFile
        done
      fi

      # Add libraries to the hadoop classpath - some may not need a colon as they already include it
      export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}${JAVA_JDBC_LIBS}

      # Setting path to hdfs command line
      export HADOOP_LIBEXEC_DIR=/usr/hdp/2.6.5.0-292/hadoop/libexec

      # Mostly required for hadoop 2.0
      export JAVA_LIBRARY_PATH=${JAVA_LIBRARY_PATH}:/usr/lib/hadoop/lib/native/Linux-amd64-64:/usr/hdp/current/hadoop-client/lib/native/Linux-amd64-64

      export HADOOP_OPTS="-Dhdp.version=$HDP_VERSION $HADOOP_OPTS"


      # Fix temporary bug, when ulimit from conf files is not picked up, without full relogin.
      # Makes sense to fix only when runing DN as root
      if [ "$command" == "datanode" ] && [ "$EUID" -eq 0 ] && [ -n "$HADOOP_SECURE_DN_USER" ]; then
      
        ulimit -n 128000
      fi

      # Enable ACLs on zookeper znodes if required
      
      export HADOOP_ZKFC_OPTS="-Dzookeeper.sasl.client=true -Dzookeeper.sasl.client.username=zookeeper -Djava.security.auth.login.config=/usr/hdp/2.6.5.0-292/hadoop/conf/secure/hdfs_jaas.conf -Dzookeeper.sasl.clientconfig=Client $HADOOP_ZKFC_OPTS"
      