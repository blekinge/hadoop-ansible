{{ ansible_managed | comment() }}


# Location of Hadoop.  By default, Hadoop will attempt to determine
# this location based upon its execution path.
export HIVE_HOME={{ current_hive_home }}

# Location of Hadoop's configuration information.  i.e., where this
# file is living. If this is not defined, Hadoop will attempt to
# locate it based upon its execution path.
#
# NOTE: It is recommend that this variable not be set here but in
# /etc/profile.d or equivalent.  Some options (such as
# --config) may react strangely otherwise.
export HIVE_CONF_DIR={{ hive_config_path }}

export PATH=$HIVE_HOME/bin:$PATH
