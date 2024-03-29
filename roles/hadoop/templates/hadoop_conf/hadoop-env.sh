#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{ ansible_managed | comment() }}


# Set Hadoop-specific environment variables here.

##
## THIS FILE ACTS AS THE MASTER FILE FOR ALL HADOOP PROJECTS.
## SETTINGS HERE WILL BE READ BY ALL HADOOP COMMANDS.  THEREFORE,
## ONE CAN USE THIS FILE TO SET YARN, HDFS, AND MAPREDUCE
## CONFIGURATION OPTIONS INSTEAD OF xxx-env.sh.
##
## Precedence rules:
##
## {yarn-env.sh|hdfs-env.sh} > hadoop-env.sh > hard-coded defaults
##
## {YARN_xyz|HDFS_xyz} > HADOOP_xyz > hard-coded defaults
##
# The only required environment variable is JAVA_HOME.  All others are
# optional.  When running a distributed configuration it is best to
# set JAVA_HOME in this file, so that it is correctly defined on
# remote nodes.

# Many of the options here are built from the perspective that users
# may want to provide OVERWRITING values on the command line.
# For example:
#
#  JAVA_HOME=/usr/java/testing hdfs dfs -ls
#
# Therefore, the vast majority (BUT NOT ALL!) of these defaults
# are configured for substitution and not append.  If append
# is preferable, modify this file accordingly.

###
# Generic settings for HADOOP
###

# Technically, the only required environment variable is JAVA_HOME.
# All others are optional.  However, the defaults are probably not
# preferred.  Many sites configure these options outside of Hadoop,
# such as in /etc/profile.d

# The java implementation to use. By default, this environment
# variable is REQUIRED on ALL platforms except OS X!
export JAVA_HOME={{ jvm_home | quote }}

# Location of Hadoop.  By default, Hadoop will attempt to determine
# this location based upon its execution path.
export HADOOP_HOME={{ current_hadoop_home | quote }}

# Location of Hadoop's configuration information.  i.e., where this
# file is living. If this is not defined, Hadoop will attempt to
# locate it based upon its execution path.
#
# NOTE: It is recommend that this variable not be set here but in
# /etc/profile.d or equivalent.  Some options (such as
# --config) may react strangely otherwise.
export HADOOP_CONF_DIR={{ hadoop_config_path | quote }}


# The minimum amount of heap to use (Java -Xms).  If no unit
# is provided, it will be converted to MB.  Daemons will
# prefer any Xms setting in their respective _OPT variable.
# There is no default; the JVM will autoscale based upon machine
# memory size.
export HADOOP_HEAPSIZE="1024M"

# The maximum amount of heap to use (Java -Xmx).  If no unit
# is provided, it will be converted to MB.  Daemons will
# prefer any Xmx setting in their respective _OPT variable.
# There is no default; the JVM will autoscale based upon machine
# memory size.
#export HADOOP_HEAPSIZE_MAX=
export HADOOP_HEAPSIZE_MAX="$HADOOP_HEAPSIZE"

# The minimum amount of heap to use (Java -Xms).  If no unit
# is provided, it will be converted to MB.  Daemons will
# prefer any Xms setting in their respective _OPT variable.
# There is no default; the JVM will autoscale based upon machine
# memory size.
# export HADOOP_HEAPSIZE_MIN=
export HADOOP_HEAPSIZE_MIN="$HADOOP_HEAPSIZE"

# Enable extra debugging of Hadoop's JAAS binding, used to set up
# Kerberos security.
# export HADOOP_JAAS_DEBUG=true

# Extra Java runtime options for all Hadoop commands. We don't support
# IPv6 yet/still, so by default the preference is set to IPv4.
# export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true"
# For Kerberos debugging, an extended option set logs more information
# export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true -Dsun.security.krb5.debug=true -Dsun.security.spnego.debug"
export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true ${HADOOP_OPTS}"

# Some parts of the shell code may do special things dependent upon
# the operating system.  We have to set this here. See the next
# section as to why....
export HADOOP_OS_TYPE="${HADOOP_OS_TYPE:-$(uname -s)}"

# Extra Java runtime options for some Hadoop commands
# and clients (i.e., hdfs dfs -blah).  These get appended to HADOOP_OPTS for
# such commands.  In most cases,
# this should be left empty and
# let users supply it on the command line.
# export HADOOP_CLIENT_OPTS=""

#
# A note about classpaths.
#
# By default, Apache Hadoop overrides Java's CLASSPATH
# environment variable.  It is configured such
# that it starts out blank with new entries added after passing
# a series of checks (file/dir exists, not already listed aka
# de-deduplication).  During de-deduplication, wildcards and/or
# directories are *NOT* expanded to keep it simple. Therefore,
# if the computed classpath has two specific mentions of
# awesome-methods-1.0.jar, only the first one added will be seen.
# If two directories are in the classpath that both contain
# awesome-methods-1.0.jar, then Java will pick up both versions.

# An additional, custom CLASSPATH. Site-wide configs should be
# handled via the shellprofile functionality, utilizing the
# hadoop_add_classpath function for greater control and much
# harder for apps/end-users to accidentally override.
# Similarly, end users should utilize ${HOME}/.hadooprc .
# This variable should ideally only be used as a short-cut,
# interactive way for temporary additions on the command line.
# export HADOOP_CLASSPATH="/some/cool/path/on/your/machine"

# Should HADOOP_CLASSPATH be first in the official CLASSPATH?
# export HADOOP_USER_CLASSPATH_FIRST="yes"

# If HADOOP_USE_CLIENT_CLASSLOADER is set, the classpath along
# with the main jar are handled by a separate isolated
# client classloader when 'hadoop jar', 'yarn jar', or 'mapred job'
# is utilized. If it is set, HADOOP_CLASSPATH and
# HADOOP_USER_CLASSPATH_FIRST are ignored.
# export HADOOP_USE_CLIENT_CLASSLOADER=true

# HADOOP_CLIENT_CLASSLOADER_SYSTEM_CLASSES overrides the default definition of
# system classes for the client classloader when HADOOP_USE_CLIENT_CLASSLOADER
# is enabled. Names ending in '.' (period) are treated as package names, and
# names starting with a '-' are treated as negative matches. For example,
# export HADOOP_CLIENT_CLASSLOADER_SYSTEM_CLASSES="-org.apache.hadoop.UserClass,java.,javax.,org.apache.hadoop."

# Enable optional, bundled Hadoop features
# This is a comma delimited list.  It may NOT be overridden via .hadooprc
# Entries may be added/removed as needed.
# export HADOOP_OPTIONAL_TOOLS="hadoop-openstack,hadoop-kafka,hadoop-aliyun,hadoop-azure,hadoop-azure-datalake,hadoop-aws"

###
# Options for remote shell connectivity
###

# There are some optional components of hadoop that allow for
# command and control of remote hosts.  For example,
# start-dfs.sh will attempt to bring up all NNs, DNS, etc.

# Options to pass to SSH when one of the "log into a host and
# start/stop daemons" scripts is executed
# export HADOOP_SSH_OPTS="-o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10s"
export HADOOP_SSH_OPTS="-o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10s -o SendEnv=HADOOP_CONF_DIR"

# The built-in ssh handler will limit itself to 10 simultaneous connections.
# For pdsh users, this sets the fanout size ( -f )
# Change this to increase/decrease as necessary.
# export HADOOP_SSH_PARALLEL=10

# Filename which contains all of the hosts for any remote execution
# helper scripts # such as workers.sh, start-dfs.sh, etc.
export HADOOP_WORKERS="${HADOOP_CONF_DIR}/workers"

###
# Options for all daemons
###
#

#
# Many options may also be specified as Java properties.  It is
# very common, and in many cases, desirable, to hard-set these
# in daemon _OPTS variables.  Where applicable, the appropriate
# Java property is also identified.  Note that many are re-used
# or set differently in certain contexts (e.g., secure vs
# non-secure)
#

# Where (primarily) daemon log files are stored.
# ${HADOOP_HOME}/logs by default.
# Java property: hadoop.log.dir
# export HADOOP_LOG_DIR=${HADOOP_HOME}/logs
export HADOOP_LOG_DIR="{{ hadoop_log_dir }}/$USER"

# A string representing this instance of hadoop. $USER by default.
# This is used in writing log and pid files, so keep that in mind!
# Java property: hadoop.id.str
# export HADOOP_IDENT_STRING=$USER
export HADOOP_IDENT_STRING="$USER"

# How many seconds to pause after stopping a daemon
# export HADOOP_STOP_TIMEOUT=5

# Where pid files are stored.  /tmp by default.
# export HADOOP_PID_DIR=/tmp
export HADOOP_PID_DIR="{{ hadoop_pid_dir }}/$USER"

# Default log4j setting for interactive commands
# Java property: hadoop.root.logger
export HADOOP_ROOT_LOGGER="INFO,console"

# Default log4j setting for daemons spawned explicitly by
# --daemon option of hadoop, hdfs, mapred and yarn command.
# Java property: hadoop.root.logger
# export HADOOP_DAEMON_ROOT_LOGGER=INFO,RFA
export HADOOP_DAEMON_ROOT_LOGGER="${HADOOP_DAEMON_ROOT_LOGGER:-{{ hadoop_daemon_logger | quote }}}"

# Default log level and output location for security-related messages.
# You will almost certainly want to change this on a per-daemon basis via
# the Java property (i.e., -Dhadoop.security.logger=foo). (Note that the
# defaults for the NN and 2NN override this by default.)
# Java property: hadoop.security.logger
# export HADOOP_SECURITY_LOGGER=INFO,NullAppender
#export HADOOP_SECURITY_LOGGER={{ hadoop_security_logger | quote }}


# Default process priority level
# Note that sub-processes will also run at this level!
# export HADOOP_NICENESS=0

# Default name for the service level authorization file
# Java property: hadoop.policy.file
export HADOOP_POLICYFILE="hadoop-policy.xml"

#
# NOTE: this is not used by default!  <-----
# You can define variables right here and then re-use them later on.
# For example, it is common to use the same garbage collection settings
# for all the daemons.  So one could define:
#
# export HADOOP_GC_SETTINGS="-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps"
#
# .. and then use it as per the b option under the namenode.

#export HADOOP_SECURE_USER=${HADOOP_SECURE_USER:-"{{ hdfs_user.name | quote }}"}

# ???
export HADOOP_HOME_WARN_SUPPRESS=1



#Options commons for all the HDFS daemons
HADOOP_COMMON_DAEMON_OPTS="-server \
                           -XX:ErrorFile=\"{{ hadoop_log_dir }}/$USER/hs_err_pid%p.log\""

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


# File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
# export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

# host:path where hadoop code should be rsync'd from.  Unset by default.
# export HADOOP_MASTER=master:/home/$USER/src/hadoop

# Seconds to sleep between slave commands.  Unset by default.  This
# can be useful in large clusters, where, e.g., slave rsyncs can
# otherwise arrive faster than the master can service them.
# export HADOOP_SLAVE_SLEEP=0.1


# Add database libraries
JAVA_JDBC_LIBS=""
if [ -d "/usr/share/java" ]; then
  for jarFile in $(ls /usr/share/java | grep -E "(mysql|ojdbc|postgresql|sqljdbc)" 2>/dev/null); do
    JAVA_JDBC_LIBS="${JAVA_JDBC_LIBS}:$jarFile"
  done
fi

# Add libraries to the hadoop classpath - some may not need a colon as they already include it
export HADOOP_CLASSPATH="${HADOOP_CLASSPATH}${JAVA_JDBC_LIBS}"

# Setting path to hdfs command line
export HADOOP_LIBEXEC_DIR="$HADOOP_HOME/libexec"

# Mostly required for hadoop 2.0
export JAVA_LIBRARY_PATH="${JAVA_LIBRARY_PATH}:${HADOOP_HOME}/lib/native/"

###
# Secure/privileged execution
###

#
# Out of the box, Hadoop uses jsvc from Apache Commons to launch daemons
# on privileged ports.  This functionality can be replaced by providing
# custom functions.  See hadoop-functions.sh for more information.
#

# The jsvc implementation to use. Jsvc is required to run secure datanodes
# that bind to privileged ports to provide authentication of data transfer
# protocol.  Jsvc is not required if SASL is configured for authentication of
# data transfer protocol using non-privileged ports.
# export JSVC_HOME=/usr/bin

#
# This directory contains pids for secure and privileged processes.
#export HADOOP_SECURE_PID_DIR=${HADOOP_PID_DIR}

#
# This directory contains the logs for secure and privileged processes.
# Java property: hadoop.log.dir
export HADOOP_SECURE_LOG="{{ hadoop_log_dir }}/$USER"

#
# When running a secure daemon, the default value of HADOOP_IDENT_STRING
# ends up being a bit bogus.  Therefore, by default, the code will
# replace HADOOP_IDENT_STRING with HADOOP_xx_SECURE_USER.  If one wants
# to keep HADOOP_IDENT_STRING untouched, then uncomment this line.
# export HADOOP_SECURE_IDENT_PRESERVE="true"

###
# NameNode specific parameters
###

# Default log level and output location for file system related change
# messages. For non-namenode daemons, the Java property must be set in
# the appropriate _OPTS if one wants something other than INFO,NullAppender
# Java property: hdfs.audit.logger
# export HDFS_AUDIT_LOGGER=INFO,NullAppender
export HDFS_AUDIT_LOGGER="{{ hdfs_audit_logger | quote }}"

# Specify the JVM options to be used when starting the NameNode.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# a) Set JMX options
# export HDFS_NAMENODE_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=1026"
#
# b) Set garbage collection logs
# export HDFS_NAMENODE_OPTS="${HADOOP_GC_SETTINGS} -Xloggc:${HADOOP_LOG_DIR}/gc-rm.log-$(date +'%Y%m%d%H%M')"
#
# c) ... or set them directly
# export HDFS_NAMENODE_OPTS="-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xloggc:${HADOOP_LOG_DIR}/gc-rm.log-$(date +'%Y%m%d%H%M')"

# this is the default:
# export HDFS_NAMENODE_OPTS="-Dhadoop.security.logger=INFO,RFAS"

#Common options for the Primary and Secondary NameNode
SHARED_HDFS_NAMENODE_OPTS="$HADOOP_COMMON_DAEMON_OPTS \
                             $HADOOP_NAMENODE_GC_OPTS \
                             $GC_LOG_OPTS  \
                             -Xms{{ hdfs_namenode_memory }} \
                             -Xmx{{ hdfs_namenode_memory }} \
                             $HADOOP_LOG_OPTS \
                             -Dhadoop.security.logger={{ hdfs_security_logger | quote }} \
                             -Dhdfs.audit.logger={{ hdfs_audit_logger | quote }}"


#The Primary NameNode opts

export HDFS_NAMENODE_OPTS="${SHARED_HDFS_NAMENODE_OPTS} \
                             -Dorg.mortbay.jetty.Request.maxFormContentSize=-1"

###
# SecondaryNameNode specific parameters
###
# Specify the JVM options to be used when starting the SecondaryNameNode.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# This is the default:
# export HDFS_SECONDARYNAMENODE_OPTS="-Dhadoop.security.logger=INFO,RFAS"

#The Secondary NameNode opts
export HDFS_SECONDARYNAMENODE_OPTS="${SHARED_HDFS_NAMENODE_OPTS} \
                                      ${HDFS_SECONDARYNAMENODE_OPTS}"

###
# DataNode specific parameters
###
# Specify the JVM options to be used when starting the DataNode.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# This is the default:
# export HDFS_DATANODE_OPTS="-Dhadoop.security.logger=ERROR,RFAS"


#The Garbage collector config for the DataNode
HADOOP_DATANODE_GC_OPTS="-XX:ParallelGCThreads=4 \
                         -XX:+UseConcMarkSweepGC \
                         -XX:NewSize=200m \
                         -XX:MaxNewSize=200m \
                         -XX:CMSInitiatingOccupancyFraction=70 \
                         -XX:+UseCMSInitiatingOccupancyOnly"

#The DataNode opts
export HDFS_DATANODE_OPTS="$HADOOP_COMMON_DAEMON_OPTS \
                             $HADOOP_DATANODE_GC_OPTS \
                             $GC_LOG_OPTS  \
                             -Xms{{ hdfs_datanode_memory }} \
                             -Xmx{{ hdfs_datanode_memory }} \
                             $HADOOP_LOG_OPTS \
                             -Dhadoop.security.logger={{ hdfs_security_logger | quote }}"


# On secure datanodes, user to run the datanode as after dropping privileges.
# This **MUST** be uncommented to enable secure HDFS if using privileged ports
# to provide authentication of data transfer protocol.  This **MUST NOT** be
# defined if SASL is configured for authentication of data transfer protocol
# using non-privileged ports.
# This will replace the hadoop.id.str Java property in secure mode.
# export HDFS_DATANODE_SECURE_USER=hdfs
#export HDFS_DATANODE_SECURE_USER={{ hdfs_user.name }}

# Supplemental options for secure datanodes
# By default, Hadoop uses jsvc which needs to know to launch a
# server jvm.
# export HDFS_DATANODE_SECURE_EXTRA_OPTS="-jvm server"

###
# NFS3 Gateway specific parameters
###
# Specify the JVM options to be used when starting the NFS3 Gateway.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HDFS_NFS3_OPTS=""

HADOOP_NFS3_OPTS="-Xmx$HADOOP_HEAPSIZE_MAX \
                  ${HADOOP_LOG_OPTS} \
                  ${HADOOP_NFS3_OPTS} \
                  -Dhadoop.security.logger={{ hdfs_security_logger | quote }}"

# Specify the JVM options to be used when starting the Hadoop portmapper.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HDFS_PORTMAP_OPTS="-Xmx512m"
export HDFS_PORTMAP_OPTS="-Dhadoop.security.logger={{ hdfs_security_logger | quote }}"

# Supplemental options for priviliged gateways
# By default, Hadoop uses jsvc which needs to know to launch a
# server jvm.
# export HDFS_NFS3_SECURE_EXTRA_OPTS="-jvm server"

# On privileged gateways, user to run the gateway as after dropping privileges
# This will replace the hadoop.id.str Java property in secure mode.
# export HDFS_NFS3_SECURE_USER=nfsserver

###
# ZKFailoverController specific parameters
###
# Specify the JVM options to be used when starting the ZKFailoverController.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HDFS_ZKFC_OPTS=""
export HDFS_ZKFC_OPTS="-Dzookeeper.sasl.client=true -Dzookeeper.sasl.client.username={{ zookeeper_service_name|quote }} -Djava.security.auth.login.config={{ hadoop_config_path }}/hdfs_nn_jaas.conf -Dzookeeper.sasl.clientconfig=Client -Dhadoop.security.logger={{ hdfs_security_logger | quote }}"


###
# QuorumJournalNode specific parameters
###
# Specify the JVM options to be used when starting the QuorumJournalNode.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HDFS_JOURNALNODE_OPTS=""
export HDFS_JOURNALNODE_OPTS="-Dhadoop.security.logger={{ hdfs_security_logger | quote }}"

###
# HDFS Balancer specific parameters
###
# Specify the JVM options to be used when starting the HDFS Balancer.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HDFS_BALANCER_OPTS=""
HADOOP_BALANCER_OPTS="-server \
                      -Xmx$HADOOP_HEAPSIZE_MAX \
                      ${HADOOP_BALANCER_OPTS} \
                      -Dhadoop.security.logger={{ hdfs_security_logger | quote }}"


###
# HDFS Mover specific parameters
###
# Specify the JVM options to be used when starting the HDFS Mover.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HDFS_MOVER_OPTS=""
export HDFS_MOVER_OPTS="-Dhadoop.security.logger={{ hdfs_security_logger | quote }}"

###
# Router-based HDFS Federation specific parameters
# Specify the JVM options to be used when starting the RBF Routers.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HDFS_DFSROUTER_OPTS=""
export HDFS_DFSROUTER_OPTS="-Dhadoop.security.logger={{ hdfs_security_logger | quote }}"

###
# Ozone Manager specific parameters
###
# Specify the JVM options to be used when starting the Ozone Manager.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HDFS_OM_OPTS=""
export HDFS_OM_OPTS="-Dhadoop.security.logger={{ hdfs_security_logger | quote }}"


###
# HDFS StorageContainerManager specific parameters
###
# Specify the JVM options to be used when starting the HDFS Storage Container Manager.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HDFS_STORAGECONTAINERMANAGER_OPTS=""
export HDFS_STORAGECONTAINERMANAGER_OPTS="-Dhadoop.security.logger={{ hdfs_security_logger | quote }}"

###
# Advanced Users Only!
###

#
# When building Hadoop, one can add the class paths to the commands
# via this special env var:
# export HADOOP_ENABLE_BUILD_PATHS="true"

#
# To prevent accidents, shell commands be (superficially) locked
# to only allow certain users to execute certain subcommands.
# It uses the format of (command)_(subcommand)_USER.
#
# For example, to limit who can execute the namenode command,
# export HDFS_NAMENODE_USER=hdfs
export HDFS_NAMENODE_USER={{ hdfs_user.name | quote }}
