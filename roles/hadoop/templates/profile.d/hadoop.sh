{{ ansible_managed | comment() }}

# Location of Hadoop.  By default, Hadoop will attempt to determine
# this location based upon its execution path.
export HADOOP_HOME={{current_hadoop_home}}

# Location of Hadoop's configuration information.  i.e., where this
# file is living. If this is not defined, Hadoop will attempt to
# locate it based upon its execution path.
#
# NOTE: It is recommend that this variable not be set here but in
# /etc/profile.d or equivalent.  Some options (such as
# --config) may react strangely otherwise.
export HADOOP_CONF_DIR={{ hadoop_config_path }}

export PATH=$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$PATH
