The Netarchive
==============

Ask <csr@kb.dk> for in-depth explanation here.

Netarchive Storage
------------------

The Netarchive harvesters downloads web content and stores in a BitRepository system.

This Bitrepository system consist of 3 pillars, but we will only concern ourselves with one of them, the KBH Netarchive Online Disk Pillar.

This Pillar uses an Isilon storage system as backing.

So in effekt, the Netarchive Harvesters stores their downloaded contents (in the form of .warc.gz files) on an Isilon system


Netarchive Jobs
---------------

The Netarchive system will run a number of "jobs" on the warc files.

There are various kind of jobs (Details to be provided by <csr@kb.dk>), but they all involve reading some warc files, processing this content in some fashion and writing some output files with the result

As mentioned, the KBH Netarchive Online Disk Pillar uses Isilon as storage. 
The same Isilon filesystems are NFS mounted read-only on the Hadoop Cluster Worker Nodes.

This means that the Hadoop jobs can read the Bitrepository contents directly and as files, without going through the Bitrepository protocol.

Some Netarchive Jobs will copy the data files to HDFS, the Hadoop Distributed Filesystem for better performance, while others will just use the files directly from the NFS mount.

This is a decision made by the Developer who programmed the job. The (current) worker nodes only have 1Gbs Network connections, so multiple reads of the same file could be done faster if the file was written to a local drive beforehand.

Narchive Hadoop Cluster
=======================

Now that you have been introduced to how the Netarchive USES the Hadoop cluster, it is time to talk about what the cluster actually IS.

The Hadoop Cluster for the Netarchive is called "Narchive", and will be referred to as such in the following.


Narchive Hosts
--------------
Overall, the Hadoop Cluster is a collection of **9** physical machines as well as 14 VMs.

The physical nodes will be the worker/storage nodes, while the VMs will be the management and control nodes.

The 10 physical nodes have these specs

| Thing       | Value                                                             |
|-------------|-------------------------------------------------------------------|
| Memory      | 4 X 16GB DIMM DDR4 Synchronous Unbuffered 2666 MHz (0.4 ns)       |
| Processor   | Intel(R) Xeon(R) E-2186G CPU @ 3.80GHz (6 cores, 12 threads)      |
| system disk | Toshiba 200GB SSD 2.5" 6Gb/s SATA Solid State Drive THNSF8200CCSE |
| data disks  | 3 X TOSHIBA MG04SCA40ENY Enterprise 4TB 7200rpm Sas-12gbps 128mb  |
| Network     | 2 X Broadcom NetXtreme BCM5720 Gigabit Ethernet PCIe              |


The VMs run in a VMWare system dedicated to Narchive, and will have specs like these

| Thing       | Value                                  |
|-------------|----------------------------------------|
| Memory      | 4-8 GB                                 |
| Processor   | 1 core, 2 threads                      |
| system disk | 50-100 GB                              |
| Network     | 3 X VMware VMXNET3 Ethernet Controller |


There are a few servers outside the Narchive cluster, that you need to know about

* `https://deimos.statsbiblioteket.dk` : YUM repos. Maintained by <tgc@kb.dk>
* `172.16.0.11` + `172.16.0.12` : DNS servers. Maintained by <nba@kb.dk>
* `https://sbprojects.statsbiblioteket.dk` : Git + Nexus repos. Maintained partly by you and partly by  <tgc@kb.dk>
* `pool.ntp.kb.dk` : NTP server. I do not know who maintains this.
* `https://kbhpc-fipa-001.kbhpc.kb.dk` : FreeIPA (Authentication and Authorization). **Maintained by you.**

Narchive Host OS
----------------

All the hosts have been installed with `Red Hat Enterprise Linux release 8.5 (Ootpa)` but are NOT added to our Redhat Subscription. Instead, <tgc@kb.dk> hosts `deimos.statsbiblioteket.dk` which hosts the Redhat Enterprise packages. So when doing a `yum update` be aware that you will get messages like this, and that you can safely ignore them:

```
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered with an entitlement server. You can use subscription-manager to register.
```

I do NOT know if this setup is compatible with our Redhat Subscription, but I will leave this as an exercise for the reader.


Narchive Networking
-------------------

This diagram will hopefully explain the networks involved with the cluster

![https://sbprojects.
statsbiblioteket.dk/display/HPC/NA-HDP+layer+3+diagram](narchive-hdp-network-layer3-WIP.png)


The Narchive cluster consist of 5 networks

* `bitarkiv-mgmt` BLACK (bitarkiv.kb.dk) (10.20.0.0/24) (vlan 203) 
  * This the network of the VMWare cluster

* `bitarkiv-hadoop` BLUE (hadoop.bitarkiv.kb.dk) (10.204.0.0/24) (vlan 204)
  * The primary network for inter-cluster communication.
  * This network is routed to the Netarchive machines for them to access the Hadoop cluster

* `bitarkiv-hadoop-mgmt` RED (hadoop-mgmt.bitarkiv.kb.dk) (10.205.0.0/24) (vlan 205)
  * The management network. This is the network that is routed to the internal networks of KB and SB, and the only way for admins to access the cluster

* `bitarkiv-hadoop-san` YELLOW (hadoop-san.bitarkiv.kb.dk) (10.206.0.0/24) (vlan 206)
  * This network is routed to `bitarkiv-prod` below

* `bitarkiv-prod` BLACK (bitarkiv.kb.dk) (172.16.0.0/24) (vlan 200)
  * The network for the Isilon storage cluster.

But the diagram also introduce some other hosts that have not been mentioned before, so let us review them


**pfsense-bitarkiv.kb.dk** is a ([pfsense](https://www.pfsense.org/)) firewall, maintained by <chla@kb.dk> and handle all the communication between Narchive and other systems.

You can read more about the firewall config [here](https://sbprojects.statsbiblioteket.dk/display/HPC/NA-HDP+Prod+cluster+hosts)

### Jumphosts and ssh access

Due to the security concerns, only a specific set of IP addresses are allowed to access Narchive from the outside.


The primary one of these is the **Linux Jumphost** (`linux-drift-01.kb.dk`, `130.226.221.57`). I do not know who maintains this host. You should be allowed to `ssh` to this host as your KB AD user. As you have to authenticate per AD, you CANNOT use public/private key authentication. For this reason, I have not used this jumphost.

To facilitate direct access for Admins, these machines were given static IPs and allowed through the firewall

* tamo `172.28.141.180` <tamo@kb.dk>
* chla KB009822.kb.dk `10.6.0.196` <chla@kb.dk>
* abr-pc.sb.statsbiblioteket.dk `172.18.0.19` <abr@kb.dk> (former employee)
* pc876.sb.statsbiblioteket.dk `172.18.97.234` <tba@kb.dk> (former employee)

This list is maintained (or not) by <chla@kb.dk>

If you need this kind of access, contact <servicedesk@kb.dk> to get your machines MAC-address registeret for a static IP. Then contact <chla@kb.dk> to get this IP registered in <pfsense-bitarkiv.kb.dk>

It is worth knowing about the route your `ssh` session will take to get to one of the hadoop machines, from Aarhus.

Your session will start on a machine, like `abr-pc.sb.statsbiblioteket.dk`.

```
abr@abr-pc:~$ traceroute -I narchive-p-hdfs01.hadoop-mgmt.bitarkiv.kb.dk
 1  _gateway (172.18.0.1)  0.488 ms  0.555 ms  0.668 ms
 2  x1-10g.statsbiblioteket.dk (130.225.247.65)  1.019 ms  1.108 ms  1.275 ms
 3  pfsense-bitarkiv.kb.dk (10.12.4.6)  6.683 ms  6.682 ms  6.764 ms
 4  10.205.0.21 (10.205.0.21)  6.680 ms  6.678 ms  6.677 ms
:) 16:32:24 abr@abr-pc:~$ 
``` 
* `_gateway` is the router handling the internal KB-Aarhus network.

* `x1-10g.statsbiblioteket.dk` is the firewall that handles "Aarhus" access to the KB KBH internal network.

* `pfsense-bitarkiv.kb.dk` is the central firewall in the diagram above.

* `10.205.0.21` is the machine `narchive-p-hdfs01.hadoop-mgmt.bitarkiv.kb.dk`, also with it's own internal firewall.

### Zabbix server

The next "new" server is **Zabbix** (<https://pc588.sb.statsbiblioteket.dk/> `172.18.95.44`). This is where we run a [Zabbix](https://www.zabbix.com/) server for monitoring the cluster.

This monitoring was never completed due to the TEK (Operations) Department planning to deploy their own Monitoring solution. However, this project have not yet been completed yet (April 2022). So we use Zabbix to monitor the basic properties of the Narchive hosts, but the Hadoop system must be monitored manually. I leave a resolution to this problem to you, dear reader.

### Bitrepository

Then we get to the **Bitmagasin** (danish name for the BitRepository system) servers, namely the MessageBus and Webdav. I know very little about these systems, and I am not entirely sure if they communicate with bitarkiv-isilon through pfsense-bitarkiv.kb.dk or use some other link.

### Netarchive 

The last are the **Netarchive hosts**. These four machines (kb-prod-adm-001.kb.dk, kb-prod-way-001.kb.dk, kb-prod-acs-001.kb.dk, kb-prod-ana-001.kb.dk) are where Hadoop Jobs are started from, so they must have access to the cluster network.

While only 4 hosts are shown on the diagram, I believe that the entire subnet 130.226.228.64/26 are allowed through the firewall. Contact <chla@kb.dk> and/or <csr@kb.dk> for details.


### FreeIPA 

The FreeIPA installation is `kbhpc-fipa-001.kbhpc.kb.dk`, which is a VMWare VM in Aarhus. This FreeIPA handles other Hadoop clusters (in Aarhus), such as the Narchive-test cluster and deprecated YAK2 cluster. Yes, we use the same authentication server for both the Narchive-test and Narchive-prod cluster.

[FreeIPA](https://www.freeipa.org/page/Main_Page) identifies as an "Open Source Identity Management Solution".
               
FreeIPA handles all users for the cluster (except `root` and the ansible user `sealbin`)

You can read about the user config [here](https://sbprojects.statsbiblioteket.dk/display/HPC/Users)

For the Narchive Production cluster, the Hadoop system users are

| name                                                                                  | UID   | GID   | Supp. GID | Notes               |
|---------------------------------------------------------------------------------------|-------|-------|-----------|---------------------|
| [nap-hadp](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/group/member_user/nap-hadp)  | -     | 11200 |           |                     |
| [nap-hdfs](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-hdfs)       | 11201 | 11201 | 11200     | root-access to HDFS |
| [nap-mapr](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-mapr)       | 11202 | 11200 |           |                     |
| [nap-yarn](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-yarn)       | 11203 | 11200 |           |                     |
| [nap-zkpr](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-zkpr)       | 11204 | 11200 |           |                     |


These system users also exist, but relate to services not installed in Narchive-Prod

| name                                                                             | UID         | GID   | Supp. GID |
|----------------------------------------------------------------------------------|-------------|-------|-----------|
| [nap-sprk](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-sprk)  | 11205       | 11200 |           |
| [nap-hive](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-hive)  | 11206       | 11200 |           |
| [nap-rstd](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-rstd)  | 11207       | 11207 |           |
| [nap-jhub](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-jhub)  | 11208       | 11208 |           |


In addition to these system users, a few "human" users also exists

| name                                                                                     | UID   | GID   | Supp. GID | Note                                                                                                                                                                                                  |
|------------------------------------------------------------------------------------------|-------|-------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [nap-subadm](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/group/member_user/nap-subadm) | -     | 11100 |           | [Sudo](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/sudorule/details/nap-subadm). [HBAC rule](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/hbacrule/details/nap-subadm%20allowed%20on%20narchive-p) |
| [nap-abrsadm](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-abrsadm)    | 11101 | 11101 | 11100     | Disabled, former employee                                                                                                                                                                             |
| [nap-tbasadm](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-tbasadm)    | 11101 | 11102 | 11100     | Disabled, former employee                                                                                                                                                                             |
| [nap-users](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/group/member_user/nap-users)   | -     | 11300 |           | General user group                                                                                                                                                                                    |
| [nap-nas](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/user/details/nap-nas)            | 11301 | 11300 |           | The Netarchive user. [HBAC](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/hbacrule/details/nap-users%20allowed%20on%20narchive-p-admn02.hadoop.bitarkiv.kb.dk)                                        |

Notice that a few groups have **Host Based Access Control** rules set up.




#### Kerberos

Hadoop Security is managed by [Kerberos](https://steveloughran.gitbooks.io/kerberos_and_hadoop/content/sections/kerberos_the_madness.html)

> When HP Lovecraft wrote his books about forbidden knowledge which would reduce the reader to insanity, of "Elder Gods" to whom all of humanity were a passing inconvenience, most people assumed that he was making up a fantasy world. **In fact he was documenting Kerberos**.

For reasons I do not recall, we use a single Kerberos Realm (KBHPC.KB.DK) for all the clusters.

<https://sbprojects.statsbiblioteket.dk/display/HPC/FreeIPA+konfiguration>

Firstly, all the Hadoop Services have been created as ["Services" in FreeIPA](https://kbhpc-fipa-001.kbhpc.kb.dk/ipa/ui/#/e/service/search//filter=bitarkiv.kb.dk)

The list can be summed up as this, employing ansible host patterns


* `HTTP/narchive-p-admn02.hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: : Http access to ?

 
* `nn/narchive-p-hdfs[01:02].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: HDFS Namenode Service
* `HTTP/narchive-p-hdfs[01:02].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: Http access to the above service


* `rm/narchive-p-yarn[01:02].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: YARN Resource Manager Service
* `HTTP/narchive-p-yarn[01:02].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: Http access to the above services


* `jn/narchive-p-zook[01:03].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: HDFS Journalnode service
* `zookeeper/narchive-p-zook[01:03].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: Zookeeper service
* `HTTP/narchive-p-zook[01:03].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: Http access to the above services


* `dn/prod-hadoop-bur-[01:09].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: HDFS Datanode service
* `nm/prod-hadoop-bur-[01:09].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: YARN Nodemanager service
* `HTTP/prod-hadoop-bur-[01:09].hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: Http access to the above services


* `jhs/narchive-p-hist01.hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: MapReduce History Server service
* `shs/narchive-p-hist01.hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: Spark History Server service
* `tl/narchive-p-hist01.hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: YARN Timeline Server service
* `HTTP/narchive-p-hist01.hadoop.bitarkiv.kb.dk@KBHPC.KB.DK`: Http access to the above services

Keytabs have been created for all these services, as well as the system users.

A keytab have been created for the user `nap-nas` to enable him to start jobs programmatically.


### SSL

We use SSL and HTTPS for all communication on the Narchive cluster.

We probably should have used LetsEncrypt to generate these certificates, but we did not. Instead we created on Certificate, (`CA.crt`) which we used to sign all the other SSL certificates in use.
So the certificates presented to the browser will mostly look like this

```
subject: C=DK; ST=Copenhagen; L=Copenhaven; O=narchive; OU=Det Kongelige Bibliotek
start date: Oct 21 13:36:11 2021 GMT
expire date: Oct 19 13:36:11 2031 GMT
issuer: C=DK; ST=Copenhagen; L=Copenhaven; O=narchive; OU=Det Kongelige Bibliotek; CN=CA
```


### Systemd Services

The various Hadoop daemons have been deployed as Systemd services.

* [zookeeper.service](../roles/zookeeper/templates/systemd/zookeeper.service)
* [hdfs_backupnode.service](../roles/hadoop/templates/systemd/hdfs/hdfs_backupnode.service)
* [hdfs_balancer.service](../roles/hadoop/templates/systemd/hdfs/hdfs_balancer.service)
* [hdfs_checkpointnode.service](../roles/hadoop/templates/systemd/hdfs/hdfs_checkpointnode.service)
* [hdfs_datanode.service](../roles/hadoop/templates/systemd/hdfs/hdfs_datanode.service)
* [hdfs_dfsrouter.service](../roles/hadoop/templates/systemd/hdfs/hdfs_dfsrouter.service)
* [hdfs_diskbalancer.service](../roles/hadoop/templates/systemd/hdfs/hdfs_diskbalancer.service)
* [hdfs_httpfs.service](../roles/hadoop/templates/systemd/hdfs/hdfs_httpfs.service)
* [hdfs_journalnode.service](../roles/hadoop/templates/systemd/hdfs/hdfs_journalnode.service)
* [hdfs_mover.service](../roles/hadoop/templates/systemd/hdfs/hdfs_mover.service)
* [hdfs_namenode.service](../roles/hadoop/templates/systemd/hdfs/hdfs_namenode.service)
* [hdfs_nfs3.service](../roles/hadoop/templates/systemd/hdfs/hdfs_nfs3.service)
* [hdfs_portmap.service](../roles/hadoop/templates/systemd/hdfs/hdfs_portmap.service)
* [hdfs_secondary_namenode.service](../roles/hadoop/templates/systemd/hdfs/hdfs_secondary_namenode.service)
* [hdfs_sps.service](../roles/hadoop/templates/systemd/hdfs/hdfs_sps.service)
* [hdfs_zkfc.service](../roles/hadoop/templates/systemd/hdfs/hdfs_zkfc.service)
* [yarn_node_manager.service](../roles/hadoop/templates/systemd/yarn/yarn_node_manager.service)
* [yarn_proxy_server.service](../roles/hadoop/templates/systemd/yarn/yarn_proxy_server.service)
* [yarn_registry_dns.service](../roles/hadoop/templates/systemd/yarn/yarn_registry_dns.service)
* [yarn_resource_manager.service](../roles/hadoop/templates/systemd/yarn/yarn_resource_manager.service)
* [yarn_shared_cache_manager.service](../roles/hadoop/templates/systemd/yarn/yarn_shared_cache_manager.service)
* [yarn_timeline_server.service](../roles/hadoop/templates/systemd/yarn/yarn_timeline_server.service)
* [mapreduce_history_server.service](../roles/hadoop/templates/systemd/mapreduce/mapreduce_history_server.service)



# Hadoop, what is it?

Hadoop is <https://hadoop.apache.org/>

The most primary components are

* Hadoop Distributed File System (HDFS)
* Yet Another Resource Negotiator (YARN)

## What is HDFS

[HDFS](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html) is, as the name implies a Distributed File system. 

A cluster will have a (small) number of HDFS Namenodes (`narchive-p-hdfs[01:02].hadoop-mgmt.bitarkiv.kb.dk`) and a (large) number of HDFS Datanodes (`prod-hadoop-bur-[01:09].hadoop-mgmt.bitarkiv.kb.dk`)

The HDFS Namenodes hold the "FAT" table for the file system. The Data nodes hold the data blocks.

Each block is normally 128MB, but unused space is not wasted.  

To read a file from HDFS, a client must contact a Namenode to get pointers to the blocks of the file. The client must then contact the relevant datanodes to get the contents of the file.

Files are (often) replicated, meaning that the same block can be found on multiple data nodes.

The datanodes do NOT know which blocks correspond to which files. All they know is which blocks they themselves hold.
Only the Namenodes know which blocks corresponds to which files.

HDFS is NOT a POSIX filesystem and cannot (normally) be mounted as such. This seems to be done solely to make it more difficult to work with.

__So what IS a Datanode actually?__ The term can be used interchangeably about both the datanode java process and the machine it runs on.

A Datanode is a (linux) machine (with some local storage) running a HDFS Datanode daemon

Similarly, a Namenode is a (linux) machine running a HDFS Namenode daemon

For the [Narchive (prod) cluster](/hosts/narchive-prod/narchive-prod.yml), `prod-hadoop-bur-[01:09].hadoop-mgmt.bitarkiv.kb.dk` function as Data nodes.

Each of these have 3 4TB disks which are used for HDFS.

HDFS is NOT a disk-filesystem, and the storage disks are formatted with some standard linux filesystem and mounted.

The HDFS Datanode daemon is configured to use these mount-points as storage. Each file-block is a normal file, up to 128MB.

__And the Namenodes?__

Yes, the Namenodes are `narchive-p-hdfs[01:02].hadoop-mgmt.bitarkiv.kb.dk`

## HDFS Authentication

HDFS uses Kerberos Authentication, meaning that you must provide a Kerberos ticket to access HDFS.

HDFS provides a POSIX-like interface, with User-Group-Other file permissions. 

Read all about [here](https://steveloughran.gitbooks.io/kerberos_and_hadoop/content/sections/hdfs.html)


## [HDFS High Availability](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html)

It is possible to replicate the HDFS Namenodes and ensure automatic failover.

1. you need a [Zookeeper](https://zookeeper.apache.org/) system for distributed coordination.
2. prepare the HDFS Journalnodes (3+, just pick the zookeeper servers). These are the lightweight daemons that decide which Namenode is the currently active.
3. All Namenode services must be stopped 
4. Pick a single namenode (NN1) and `initializeSharedEdits`
5. Start NN1
6. Choose next Namenode NN2 and `bootstrapStandby`. This SHOULD cause it to sync to NN1
7. pick NN1, stop the zkfc service and format zkfc
8. Restart namenode services on NN1 and NN2
9. Restart all zkfc services on NN1 and NN2

Each HDFS zkfc service will monitor the health of it's local HDFS Namenode service and connect to the Zookeeper quorum.
Should the primary Namenode service fail, the ZKFC service will notice and trigger a re-election by the Journalnodes.

The Journal nodes will then decide on a new primary Namenode and switch the system to be using this. 


## [YARN, Yet Another Resource Negotiator](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/YARN.html)

YARN is the job and resource management system for a Hadoop cluster.



# Other Hadoop services (Spark, Map-reduce.)

# Log collection (Rsyslog)
