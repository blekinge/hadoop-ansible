# How to setup a YAK-like cluster with Ansible

## Configuration structure

All-cluster specific structure should be located in an appropriately named folder in `hosts/`. Currently the YAK2 config is located in `hosts/YAK2/`

To create a cluster run
```bash
ansible-playbook -i hosts/YAK2 playbook-createCluster.yml
```
and wait for a while.

## Installing


In order to use all the tools and modules for this setup, a few things needs to be installed on your machine (the machine where you invoke `ansible-playbook`)

### DNF/YUM packages
```bash
grep -E "^[^#]+" requirements.dnf | grep -E -v "^\s+$" | xargs -r -i sudo dnf install -y {}
```

### Pip packages
You can create a virtualenv for these, but this might not work correctly with ansible. So beware. It is easier to install them system-wide

```bash
sudo pip install -r requirements.pip
```

### Ansible galaxy packages
Install dependent roles and collections from ansible galaxy

```bash
ansible-galaxy install -r requirements.yml
```

## Vault and security

Create a file `vault-password.yml` with the vault password. This password will be used to decrypt passwords from the inventory (`hosts/YAK2`)

Note that the file content is used _as is_ so you cannot put comments in this file.

The vault password can be found in our password database: <https://antigone.statsbiblioteket.dk/index.php?r=account%2Fview%2F83&h=15079e391f1a86eede86ef7bac67d19c470f3342f8c70c3dc882b1ef305e02e3>

This file is configured to be git-ignored by `.gitignore`.


## Cluster config

Most things run well on defaults, but you need to create a host list.

Assign hosts these magic groups

These are the magical hostgroups that are automagically bound to roles and behaviours by the playbooks

* VMs: Machines to auto-create in ovirt

* ipaserver: the FreeIPA server to register all hosts to

* ipaclients: The list of hosts to setup as ipa clients

* zabbix_nodes: The list of hosts to setup zabbix agent on

* hadoop_nodes: = role hadoop, role zookeeper, role spark

* hdfs_namenodes: = role hdfs_namenode.
    * When creating a new cluster, one of these must have the fact `primary: true`. The primary node is the one whose hdfs gets propagated to the other namenodes

* hdfs_journalnodes: = role hdfs_journalnode

* hdfs_datanodes: = role hdfs_datanode

* zookeeper_servers: = role zookeeper_server

* yarn_resource_managers: = role yarn_resource_manager

* yarn_node_managers: = role yarn_node_manager

* yarn_timeline_servers: = role yarn_timeline_server

* mapreduce_history_servers: = role mapreduce_history_server

* spark_history_servers: = role spark_history_server

* project_nodes: = role spark_client, role rstudio_server, role jupyterhub


### Ovirt VMs
To create VMs, it is useful to create a separate inventory (do not worry, all `.yml` in you inventory-folder are read and merged). See this example

```yaml 
VMs: # This is the group of VMs created by 10.playbook-ovirt-vms.yml
  hosts:
    # The "short name", ie. the first part of the name here will be used as the name of the VM
    # IF you have to use a "wrong" hostname or an IP here, use the variables "hostname" and "shortname" to set
    #   the correct hostname for the host
    hist001.yak2.net: #Example of how to set hostname
      hostname: hist001.yak2.net
      shortname: hist001

    zkpr[001:003].yak2.net:
    hdfs[001:002].yak2.net:
    yarn[001:002].yak2.net:

    roda[001:004].yak2.net: #Virtual datanodes
      memory: 8GiB # Set memory
      cpu_sockets: 4 # Set cpus

      host_disks: # This is how to create additional disks
        - name: HDFS
          size: 1024GiB
          mount: /data/sdb1
  
```

You  can create a folder/file named `VMs`/`VMs.yml` for the variables for all VM hosts.

You need to set these blocks

#### Ovirt Auth

```yaml
ovirt_api_host: "ovim001.adm.{{domain}}"
ovirt_username: "admin@internal"
ovirt_password: "..."
ovirt_cluster: "KAC"
```

#### Ovirt new Machine Template
These values are also the defaults, so you only need this if you want to change the defaults
```yaml
template: SDL8-4R-30D-MIN-TMPL
memory: 4GiB
cpu_sockets: 2
cpu_cores: 1
```

#### Network interfaces

Note that I expect you to have set up DNS correctly for the new host beforehand. See 
* <https://sbprojects.statsbiblioteket.dk/display/YAK/How+to+update+forward+DNS+zones>
* <https://sbprojects.statsbiblioteket.dk/display/YAK/How+to+update+reverse+DNS+zones>

The IP is assigned based on a DNS lookup on the provided hostname.


As this setup was written for YAK2, and YAK2 have 2 NICs per host, this is what I assume all clusters must have. I have not generalised this to a list of nics yet.



```yaml
# The network settings used when creating new virtual hosts for the cluster
domain_nfs: "nfs.{{domain}}"
domain_adm: "adm.{{domain}}" # 172.16.216
domain_dmz: "dmz.{{domain}}"

dns_search_domains: "{{ [domain,domain_nfs,domain_adm,domain_dmz] | join(',') }}"

# DNS server used to look up the ip of the new host
# The host should be added to DNS prior to creation
dns_server: "bind001.{{domain}}"

# Nic1 profile
nic1: "yak2net"
nic1_subnet: 172.16.215
nic1_domain: "{{domain}}"

#The dns servers to configure for the new host
dns1: "{{nic1_subnet}}.52" #bind001
dns2: "{{nic1_subnet}}.53" #bind002

# New VMs are always created with this ip, so we can ssh to this and set up the machine
new_vm_ip: "{{nic1_subnet}}.254"

# The gateway to use
gateway: "{{nic1_subnet}}.51"


nic2: "ovirtmgmt"
nic2_subnet: 172.16.216
nic2_domain: "{{domain_adm}}"

nic2_routes_list:
  - "172.16.7.0/24"
  - "172.16.216.1,172.18.0.0/16"
  - "172.16.216.1,172.28.1.0/24"
  - "172.16.216.1,130.225.24.0/23"
  - "172.16.216.1,130.226.220.0/24"
  - "172.16.216.1"

nic2_routes: "{{ nic2_routes_list | join(' ') }}"
```

There are a few (more than one?) undefined variables above. These must be set in the `all` hostgroup.

```yaml
domain: "yak2.net"
```

### Setup ansible account

The playbooks automatically set up an ansible user account (see role `roles/ansible_account`)

This is the `sealbin` account and you can control his name and id with
```yaml
---
sealbin_user: "sealbin"
sealbin_group: "{{sealbin_user}}"

sealbin_user_uid: 1111
sealbin_user_gid: "{{sealbin_user_uid}}"

sealbin_home: "/home/{{sealbin_user}}"

# If no, we disable root ssh logins so you will have to use {{sealbin_user}} to login
permit_root_logins: yes
``` 

Note that the `sealbin_user` name should match the remote user from `ansible.cfg`
```ini
# default user to use for playbooks if user is not specified
# (/usr/bin/ansible will use current user as default)
remote_user = sealbin
```

### Zabbix agent

The next step is setting up the zabbix agent on the hosts.

```yaml
---
zabbix_agent_server: pc543.sb.statsbiblioteket.dk

#This ensures that the zabbix agent uses the 216 address, which the zabbix server can reach
zabbix_agent_ip: "{{hostvars[inventory_hostname]['ansible_all_ipv4_addresses'] | select('match', '^'+nic2_subnet+'.*') | first}}"

zabbix_agent_tlspskidentity: YAKPSK
zabbix_agent_tlspsk_secret: "..."

zabbix_url: "https://{{zabbix_agent_server}}/zabbix/"
zabbix_validate_certs: no

zabbix_api_user: Admin
zabbix_api_pass: "..."

default_zabbix_host_groups__to_merge:
  - "yak2"
```

The ansible will automagically merge all `*_zabbix_host_groups__to_merge` variables into a single list `zabbix_host_groups`

So, for other hostgroups, which you want to place into specific zabbix hostgroups, you must define something like this with a unique prefix:

(for host group `hadoop_nodes`)
```yaml
hadoop_nodes_zabbix_host_groups__to_merge:
  - "yak2-hadoop"
```

(for host group `VMs`)
```yaml
VMs_zabbix_host_groups__to_merge:
  - "Ovirt VMs"
```

(for host group `project_nodes`)
```yaml
project_nodes_zabbix_host_groups__to_merge:
  - "yak2-proj"
```


### IPA client config

Then we get to the ipa client config. These are the non-defaultable variables that must be set

```yaml
---
ipa_domain: "{{domain}}"
ipa_realm: YAK2.NET

ipaclient_force_join: true
ipaclient_ntp_servers:
  - kac-gway-001.kach.sblokalnet

autohome_nfs_export_iprange: "172.16.215.0/24"

# This user group is referred to from a lot of roles, so it must be defined
users_group:
  name: "yakusers"
  gid: 20000
  description: Standard user accounts, for unprivileged users.

vpnu_group:
  name: vpnu
  gid: 10067
  description: VPN access group

# default_user_groups are the groups that all new (human) users will be made member of
default_user_groups:
  - "{{vpnu_group}}"
  - "{{users_group}}"

ipaadmin_password: "..."
```


### SSL

Everything I could get to use SSL uses SSL (looking at you, `RStudio`....)

For now this is just unrelated self-signed certificates.

To set up ssl, you must define the nessesary passwords
```yaml

# Secret ssl variables
ssl_key_pass: "..."
ssl_keystore_pass: "..."
ssl_truststore_pass: "..."
```

These should probably be set up for the host group `all` as almost every machine will use SSL for something

You must also set up 
```yaml
jupyterhub_ssl_password: "..."
```
for host group `project_nodes` as jupyterhub uses some different certificates

### Hadoop

You control the hadoop versions with
```yaml
hadoop_version: "3.3.0"
zookeeper_version: "3.6.2"
spark_version: "3.0.1"
```

Note that if you change major versions, errors in the playbooks will probably arrise. I have not tested this on other versions, so beware.

There are really no other nessesary config for hadoop. Everything you would want to configure is already controlled by defaults and host groups.

The playbooks will set up a cluster:

* with ssl on all interfaces
* with firewalld enabled
* with kerberos authentification for all auth
* With a Zookeeper quorum
* With 2 HDFS namenodes
    * in a failover-configuration
* And 2 Yarn Resource managers
    * in a failover-configuration
* And history server instances for YARN/MapReduce/Spark
* and a number of project nodes
    * with RStudio
    * with Jupyterhub




