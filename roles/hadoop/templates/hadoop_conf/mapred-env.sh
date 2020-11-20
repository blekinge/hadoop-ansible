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
## WORK DONE BY THE mapred AND RELATED COMMANDS.
##
## Precedence rules:
##
## mapred-env.sh > hadoop-env.sh > hard-coded defaults
##
## MAPRED_xyz > HADOOP_xyz > hard-coded defaults
##


if [ -f "{{ hadoop_config_path }}/hadoop-env.sh" ]; then
  source "{{ hadoop_config_path }}/hadoop-env.sh"
fi


###
# Job History Server specific parameters
###

# Specify the max heapsize for the JobHistoryServer.  If no units are
# given, it will be assumed to be in MB.
# This value will be overridden by an Xmx setting specified in HADOOP_OPTS,
# and/or MAPRED_HISTORYSERVER_OPTS.
# Default is the same as HADOOP_HEAPSIZE_MAX.
#export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=
export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=3072

# Specify the JVM options to be used when starting the HistoryServer.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#export MAPRED_HISTORYSERVER_OPTS=

# Specify the log4j settings for the JobHistoryServer
# Java property: hadoop.root.logger
#export HADOOP_JHS_LOGGER=INFO,RFA
export HADOOP_JHS_LOGGER=${HADOOP_JHS_LOGGER:-"{{mapreduce_daemon_logger}}"}


#DRFAS is defined in log4j.properties
export HADOOP_SECURITY_LOGGER=${HADOOP_SECURITY_LOGGER:-"{{mapreduce_security_logger}}"}


#DRFA is defined in log4j.properties
export HADOOP_ROOT_LOGGER=${HADOOP_ROOT_LOGGER:-"{{hadoop_daemon_logger}}"}

#JSA is defined in yarn-log4j.properties
export HADOOP_MAPRED_JOBSUMMARY_LOGGER=${HADOOP_MAPRED_JOBSUMMARY_LOGGER:-"{{mapreduce_jobsummary_logger}}"}

export HADOOP_OPTS="-Dhadoop.mapreduce.jobsummary.logger=$HADOOP_MAPRED_JOBSUMMARY_LOGGER $HADOOP_OPTS"


# History server logs. This is default from hadoop-env.sh
#export HADOOP_LOG_DIR="{{ hadoop_log_dir }}/$USER"


# History server pid. This is default from hadoop-env.sh
#export HADOOP_PID_DIR="{{ hadoop_pid_dir }}/$USER"

