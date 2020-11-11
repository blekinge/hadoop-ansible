#!/usr/bin/env bash
{{ ansible_managed | comment() }}

executable=$1
shift

env_file=$1
shift

if [ -f "{{ hadoop_config_path }}/${env_file}" ]; then
  source "{{ hadoop_config_path }}/${env_file}"
fi


exec "$HADOOP_HOME/bin/$executable" "$@"
