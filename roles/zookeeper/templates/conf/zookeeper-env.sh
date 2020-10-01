# The java implementation to use.  Required.
export JAVA_HOME="{{ jvm_home }}"

export ZOOKEEPER_HOME="{{ zookeeper_home }}"
export ZOO_LOG_DIR="{{ zookeeper_path }}"
export ZOOPIDFILE="{{ zookeeper_pid_dir }}/zookeeper_server.pid"
export SERVER_JVMFLAGS=-Xmx1024m
export JAVA="$JAVA_HOME/bin/java"
export CLASSPATH="$CLASSPATH:/usr/share/zookeeper/*"

export SERVER_JVMFLAGS="$SERVER_JVMFLAGS -Djava.security.auth.login.config=/etc/zookeeper/conf/zookeeper_server_jaas.conf"
export CLIENT_JVMFLAGS="$CLIENT_JVMFLAGS -Djava.security.auth.login.config=/etc/zookeeper/conf/zookeeper_client_jaas.conf"
