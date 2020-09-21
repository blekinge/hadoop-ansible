#!/usr/bin/env bash


if [ -f "/etc/profile.d/hadoop_env.sh" ]; then
  source /etc/profile.d/hadoop_env.sh
fi


executable=$1
  shift

exec "$HADOOP_HOME/bin/$executable" "$@"

