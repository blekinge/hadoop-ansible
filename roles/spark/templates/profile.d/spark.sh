

# Location of Hadoop.  By default, Hadoop will attempt to determine
# this location based upon its execution path.
export SPARK_HOME={{spark_home}}

# Location of Hadoop's configuration information.  i.e., where this
# file is living. If this is not defined, Hadoop will attempt to
# locate it based upon its execution path.
#
# NOTE: It is recommend that this variable not be set here but in
# /etc/profile.d or equivalent.  Some options (such as
# --config) may react strangely otherwise.
export SPARK_CONF_DIR={{ spark_config_path }}

export PATH=$SPARK_HOME/bin:$PATH
