#!/usr/bin/env bash
{{ ansible_managed | comment() }}

env_file=$1
shift


executable=$1
shift

if [ -f "{{ spark_config_path }}/${env_file}" ]; then
  source "{{ spark_config_path }}/${env_file}"
fi


exec "$SPARK_HOME/sbin/$executable" "$@"
