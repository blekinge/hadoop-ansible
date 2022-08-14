#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{ ansible_managed | comment() }}

##
## THIS FILE ACTS AS AN OVERRIDE FOR hadoop-env.sh FOR ALL
## WORK DONE BY THE yarn AND RELATED COMMANDS.
##
## Precedence rules:
##
## yarn-env.sh > hadoop-env.sh > hard-coded defaults
##
## YARN_xyz > HADOOP_xyz > hard-coded defaults
##

if [ -f "{{ hadoop_config_path }}/hadoop-env.sh" ]; then
  source "{{ hadoop_config_path }}/hadoop-env.sh"
fi

export HADOOP_YARN_HOME={{ current_hadoop_home | quote }}
HADOOP_OPTS="$HADOOP_OPTS -Dyarn.home.dir=$HADOOP_YARN_HOME"

export HADOOP_LOG_DIR={{ (hadoop_log_dir + '/' + yarn_user.name) | quote }}
export HADOOP_DAEMON_ROOT_LOGGER={{ yarn_daemon_logger | quote }}

export HADOOP_PID_DIR={{ (hadoop_pid_dir + '/' + yarn_user.name) | quote }}
export HADOOP_LIBEXEC_DIR="$HADOOP_YARN_HOME/libexec"
export HADOOP_CONF_DIR="{{ hadoop_config_path | quote }}"

# User for YARN daemons
HADOOP_IDENT_STRING="{{ yarn_user.name }}"
HADOOP_OPTS="$HADOOP_OPTS -Dyarn.id.str=$HADOOP_IDENT_STRING"

export HADOOP_YARN_USER="${HADOOP_YARN_USER:-{{ yarn_user.name }}}"

# The java implementation to use.  Required.
export JAVA_HOME="{{ jvm_home }}"

# some Java parameters
# export JAVA_HOME=/home/y/libexec/jdk1.6.0/
if [ "$JAVA_HOME" != "" ]; then
  #echo "run java in $JAVA_HOME"
  JAVA_HOME="$JAVA_HOME"
fi

if [ "$JAVA_HOME" = "" ]; then
  echo "Error: JAVA_HOME is not set."
  exit 1
fi

JAVA="$JAVA_HOME/bin/java"
JAVA_HEAP_MAX=-Xmx1000m

if [ "x$JAVA_LIBRARY_PATH" != "x" ]; then
  HADOOP_OPTS="$HADOOP_OPTS -Djava.library.path=$JAVA_LIBRARY_PATH"
fi

# For setting YARN specific HEAP sizes please use this
# Parameter and set appropriately
YARN_HEAPSIZE=1024

# check envvars which might override default args
if [ "$YARN_HEAPSIZE" != "" ]; then
  JAVA_HEAP_MAX="-Xmx${YARN_HEAPSIZE}m"
fi

# so that filenames w/ spaces are handled correctly in loops below
IFS=

# default policy file for service-level authorization
if [ "$YARN_POLICYFILE" = "" ]; then
  YARN_POLICYFILE="hadoop-policy.xml"
fi
HADOOP_OPTS="$HADOOP_OPTS -Dyarn.policy.file=$YARN_POLICYFILE"

# restore ordinary behaviour
unset IFS


###
# Resource Manager specific parameters
###

# Specify the max heapsize for the ResourceManager.  If no units are
# given, it will be assumed to be in MB.
# This value will be overridden by an Xmx setting specified in either
# HADOOP_OPTS and/or YARN_RESOURCEMANAGER_OPTS.
# Default is the same as HADOOP_HEAPSIZE_MAX
#export YARN_RESOURCEMANAGER_HEAPSIZE=
export YARN_RESOURCEMANAGER_HEAPSIZE=2048

# Specify the JVM options to be used when starting the ResourceManager.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# Examples for a Sun/Oracle JDK:
# a) override the appsummary log file:
# export YARN_RESOURCEMANAGER_OPTS="-Dyarn.server.resourcemanager.appsummary.log.file=rm-appsummary.log -Dyarn.server.resourcemanager.appsummary.logger=INFO,RMSUMMARY"
#
# b) Set JMX options
# export YARN_RESOURCEMANAGER_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=1026"
#
# c) Set garbage collection logs from hadoop-env.sh
# export YARN_RESOURCE_MANAGER_OPTS="${HADOOP_GC_SETTINGS} -Xloggc:${HADOOP_LOG_DIR}/gc-rm.log-$(date +'%Y%m%d%H%M')"
#
# d) ... or set them directly
# export YARN_RESOURCEMANAGER_OPTS="-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xloggc:${HADOOP_LOG_DIR}/gc-rm.log-$(date +'%Y%m%d%H%M')"
#
# e) Enable ResourceManager audit logging
# export YARN_RESOURCEMANAGER_OPTS="-Drm.audit.logger=INFO,RMAUDIT"
#
#
# export YARN_RESOURCEMANAGER_OPTS=
YARN_RESOURCEMANAGER_OPTS="-Dyarn.server.resourcemanager.appsummary.logger={{ yarn_resourcemanager_appsummary_logger | quote }}"
YARN_RESOURCEMANAGER_OPTS="-Dzookeeper.sasl.client=true -Dzookeeper.sasl.client.username={{ zookeeper_service_name|quote }} -Djava.security.auth.login.config={{ hadoop_config_path }}/yarn_jaas.conf -Dzookeeper.sasl.clientconfig=Client $YARN_RESOURCEMANAGER_OPTS"
export YARN_RESOURCEMANAGER_OPTS="$YARN_RESOURCEMANAGER_OPTS -Drm.audit.logger={{ yarn_resourcemanager_audit_logger | quote }} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"



###
# Node Manager specific parameters
###

# Specify the max heapsize for the NodeManager.  If no units are
# given, it will be assumed to be in MB.
# This value will be overridden by an Xmx setting specified in either
# HADOOP_OPTS and/or YARN_NODEMANAGER_OPTS.
# Default is the same as HADOOP_HEAPSIZE_MAX.
#export YARN_NODEMANAGER_HEAPSIZE=
export YARN_NODEMANAGER_HEAPSIZE=1024

# Specify the JVM options to be used when starting the NodeManager.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# a) Enable NodeManager audit logging
# export YARN_NODEMANAGER_OPTS="-Dnm.audit.logger=INFO,NMAUDIT"
#
# See ResourceManager for some examples
#
#export YARN_NODEMANAGER_OPTS=

# Node Manager specific parameters
export YARN_NODEMANAGER_OPTS="$YARN_NODEMANAGER_OPTS -Dnm.audit.logger={{ yarn_nodemanager_audit_logger | quote }}"

###
# TimeLineServer specific parameters
###

# Specify the max heapsize for the timelineserver.  If no units are
# given, it will be assumed to be in MB.
# This value will be overridden by an Xmx setting specified in either
# HADOOP_OPTS and/or YARN_TIMELINESERVER_OPTS.
# Default is the same as HADOOP_HEAPSIZE_MAX.
#export YARN_TIMELINE_HEAPSIZE=
export YARN_TIMELINESERVER_HEAPSIZE=1024

# Specify the JVM options to be used when starting the TimeLineServer.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# See ResourceManager for some examples
#
#export YARN_TIMELINESERVER_OPTS=

###
# TimeLineReader specific parameters
###

# Specify the JVM options to be used when starting the TimeLineReader.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# See ResourceManager for some examples
#
#export YARN_TIMELINEREADER_OPTS=

###
# Web App Proxy Server specifc parameters
###

# Specify the max heapsize for the web app proxy server.  If no units are
# given, it will be assumed to be in MB.
# This value will be overridden by an Xmx setting specified in either
# HADOOP_OPTS and/or YARN_PROXYSERVER_OPTS.
# Default is the same as HADOOP_HEAPSIZE_MAX.
#export YARN_PROXYSERVER_HEAPSIZE=

# Specify the JVM options to be used when starting the proxy server.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# See ResourceManager for some examples
#
#export YARN_PROXYSERVER_OPTS=

###
# Shared Cache Manager specific parameters
###
# Specify the JVM options to be used when starting the
# shared cache manager server.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# See ResourceManager for some examples
#
#export YARN_SHAREDCACHEMANAGER_OPTS=

###
# Router specific parameters
###

# Specify the JVM options to be used when starting the Router.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# See ResourceManager for some examples
#
#export YARN_ROUTER_OPTS=

###
# Registry DNS specific parameters
# This is deprecated and should be done in hadoop-env.sh
###
# For privileged registry DNS, user to run as after dropping privileges
# This will replace the hadoop.id.str Java property in secure mode.
# export YARN_REGISTRYDNS_SECURE_USER=yarn

# Supplemental options for privileged registry DNS
# By default, Hadoop uses jsvc which needs to know to launch a
# server jvm.
# export YARN_REGISTRYDNS_SECURE_EXTRA_OPTS="-jvm server"

###
# YARN Services parameters
###
# Directory containing service examples
# export YARN_SERVICE_EXAMPLES_DIR = $HADOOP_YARN_HOME/share/hadoop/yarn/yarn-service-examples
# export YARN_CONTAINER_RUNTIME_DOCKER_RUN_OVERRIDE_DISABLE=true

export HADOOP_OPTS
