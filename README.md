# How to setup a YAK-like cluster with Ansible


## Configuration structure

All-cluster specific structure should be located in an appropriately named folder in `hosts/`. Currently the YAK2 config is located in `hosts/YAK2/`

To create a cluster run
```bash
ansible-playbook -i hosts/YAK2 playbook-createCluster.yml
```
and wait for a while. Then fix whatever went wrong and try again...

There are currently specifications for these cluster in `hosts/`

Currently in use:
* narchive-prod: Cluster for Netarchive Production system. Config here should be up2date
* narchive-test: Cluster for Netarchive Test system. Config here should be up2date

Clusters no longer used, config here might be out of date:
* KAC: KulturArvsClusteret.  
* YAK2-ha: YAK2 is the new KulturArvsCluster. ha stands for High Availability.
* YAK2-nonHa: NonHA means YAK2 without High Availability setup. Written as proof of concept.
* YAK2-abstract: The common parts of YAK2-ha and YAK2-nonHa.
* narcana: Cluster for Webdanica project.







## Installing

In order to use all the tools and modules for this setup, a few things needs to be installed on your machine (the machine where you invoke `ansible-playbook`)

### DNF/YUM packages
```bash
grep -E "^[^#]+" requirements.dnf | grep -E -v "^\s+$" | xargs -r -i sudo dnf install -y {}
```

### Pip packages
You can create a virtualenv for these, but this might not work correctly with ansible. So beware. It is easier to install them system-wide

```bash
pip install -r requirements.pip
```

### Ansible galaxy packages
Install dependent roles and collections from ansible galaxy

```bash
ansible-galaxy collection install -r requirements.yml
ansible-galaxy role install -r requirements.yml
```

## Vault and security

Create a file `vault-password.yml` with the vault password. This password will be used to decrypt passwords from the inventory (`hosts/YAK2`)

Note that the file content is used _as is_ so you cannot put comments in this file.

The vault password can be found in our password database: <https://antigone.statsbiblioteket.dk/index.php?r=account%2Fview%2F83&h=15079e391f1a86eede86ef7bac67d19c470f3342f8c70c3dc882b1ef305e02e3>

This file is configured to be git-ignored by `.gitignore`.


## Cluster config

Most things run well on defaults, but you need to create a host list.

Assign hosts these host groups. These are the magical hostgroups that are automagically bound to roles and behaviours by the playbooks

The hostgroup names are always prefixed with "hostgroup_". This is not required by ansible, but it makes it easier to distinguish hostgroups and roles in error messages

If the hostgroup-name is in singular form, the system expects only a single host in this group. If it is in plural form, 
multiple hosts can be registered.

* `hostgroup_VMs`: Machines to auto-create in ovirt. Not used in Narchive cluster

* `hostgroup_ipaserver`: SINGULAR. the FreeIPA server to register all hosts to

* `hostgroup_ipaclients`: Hosts with FreeIPA Client, i.e. with users managed by the FreeIPA server. This is normally set as `hostgroup_hadoop_nodes`

* `hostgroup_zabbix_nodes`: Hosts with Zabbix Agent. Normally set as `hostgroup_ipaclients`

* `hostgroup_zabbix_proxies`: The list of hosts to setup zabbix proxy

* `hostgroup_rsyslog_server`: SINGULAR. The RSyslog server to collect all logs.

* `hostgroup_with_datamounts`: Nodes that should NFS mount the Isilon data read-only

* `hostgroup_hadoop_nodes`: Nodes with the Hadoop software installed.

  * `hostgroup_project_nodes`: 
    * `hostgroup_jupyter_nodes`:
    * `hostgroup_rstudio_nodes`:
  * `hostgroup_hdfs`:
    * hostgroup_hdfs_namenodes:
    * hostgroup_hdfs_secondary_namenodes:
    * hostgroup_hdfs_journalnodes:
    * hostgroup_hdfs_backupnodes:
    * hostgroup_hdfs_datanodes:
  * hostgroup_zookeeper_servers
  * hostgroup_yarn
    * hostgroup_yarn_resource_managers
    * hostgroup_yarn_node_managers
    * hostgroup_yarn_timeline_servers
  * hostgroup_mapreduce
    * hostgroup_mapreduce_history_servers
  * hostgroup_spark
    * hostgroup_spark_history_servers




* hostgroup_hadoop_nodes: = role hadoop, role zookeeper, role spark

* hostgroup_hdfs_namenodes: = role hadoop_hdfs_namenode.
    * When creating a new cluster, one of these must have the fact `primary: true`. The primary node is the one whose hdfs gets propagated to the other namenodes

* hostgroup_hdfs_journalnodes: = role hadoop_hdfs_journalnode

* hostgroup_hdfs_datanodes: = role hadoop_hdfs_datanode

* hostgroup_zookeeper_servers: = role zookeeper_server

* hostgroup_yarn_resource_managers: = role hadoop_yarn_resource_manager

* hostgroup_yarn_node_managers: = role hadoop_yarn_node_manager

* hostgroup_yarn_timeline_servers: = role hadoop_yarn_timeline_server

* hostgroup_mapreduce_history_servers: = role hadoop_mapreduce_history_server

* hostgroup_spark_history_servers: = role spark_history_server

* hostgroup_project_nodes: = role spark_client, role rstudio_server, role jupyterhub
