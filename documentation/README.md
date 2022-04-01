# Socratic Intro

__So, what is this?__ Well, this is most (or all) the Ansible Playbooks nessesary to set up a Hadoop cluster.

__How does this work?__ By magic and blood, mostly. Understand it at your own peril.

__Does it actually work?__ Normally not on the first try. There is always something that needs to be altered in some of the playbooks or roles. 
If you came for a turn-key solution, leave now. This is not for you.

__How do I get started?__ I thought you would never ask. Let me learn you a Hadoop.

# What is Hadoop?

Hadoop is <https://hadoop.apache.org/>

__That did'nt help much!__ Well, Hadoop is a "thing", consisting of several "components".

The most primary components are

* Hadoop Distributed File System (HDFS)
* Yet Another Resource Negotiator (YARN)

## What is HDFS

HDFS is, as the name implies a Distributed File system. 

A cluster will have a (small) number of HDFS Namenodes and a (large) number of HDFS Datanodes

The HDFS Namenodes hold the "FAT" table for the file system. The Data nodes hold the blocks.

Each block is normally 128MB, but unused space is not wasted.  

To read a file from HDFS, a client must contact a Namenode to get pointers to the blocks of the file. Then the client
must contact the relevant datanodes to get the contents of the file.

Files are (often) replicated, meaning that the same block can be found on multiple data nodes.

The datanodes do NOT know which blocks correspond to which files. All they know is which blocks they themself holds.
Only the Namenodes know which blocks corresponds to which files.

HDFS is NOT a POSIX filesystem and cannot (normally) be mounted as such. This seems to be done solely to make it more difficult to work with.

__So what IS a Datanode actually?__ The term can be used interchangebly about both the datanode java process and the machine it runs on.

A Datanode is a (linux) machine (with some local storage) running a HDFS Datanode daemon

Similarly, a Namenode is a (linux) machine running a HDFS Namenode daemon

For the [Narchive (prod) cluster](/hosts/narchive-prod/narchive-prod.yml), `prod-hadoop-bur-[01:09].hadoop-mgmt.bitarkiv.kb.dk` function as Data nodes.



Each of these have 4 4TB disks. 3 of these (sbb, sbc, sbd) are used for HDFS.

HDFS is NOT a disk-filesystem, and the storage disks are formatted with some standard linux filesystem and mounted.

The HDFS Datanode daemon is configured to use these mount-points as storage. Each file-block is a normal file, up to 128MB.

__And the Namenodes?__

Yes, the Namenodes are `narchive-p-hdfs[01:02].hadoop-mgmt.bitarkiv.kb.dk`

## The Networks

One of the "funny" things about a Hadoop cluster is how everything is connected to everything else. I cannot explain  
HDFS further without explaining the network setup or user management.

So let's talk about the network. You can see the simple and straightforward setup here

![https://sbprojects.
statsbiblioteket.dk/display/HPC/NA-HDP+layer+3+diagram](narchive-hdp-network-layer3-WIP.png)

### What does "access" actually mean? Everybody knows (something different)

Why is this so complicated? Because somebody decided that "access" to the netarchive should be highly restricted. 
But this somebody did not define what "access" meant.

So for the network engineers, it meant that the netarchive should be on it's own subnet, with no access to other things.

For Operations it meant that the netarchive cluster should be in a special locked server room ("the cage" or "buret"), 
separate from the other servers.

For the Storage engineers, it meant that the netarchive data had to be on it's own special storage system 
(bitarkiv-isilon), not on the general Isilon cluster used in the organisation. 

For the VM engineers, it meant that a special VMWare cluster had to be created inside the special server room, as 
the netarchive could not use the general VMWare cluster. 

After thus having duplicated almost every part of our IT infrastructure inside the special server room, the work of 
punching holes through the (multiple) firewalls began.

#### Swiss Cheese firewalls

It is worth knowing about the route your `ssh` session will take to get to one of the hadoop machines, from Aarhus.

Btw, all the references to SB reference "Statsbiblioteket". Within the next decade or two we will probably get most 
of them replaced with kb.dk. But until then, you can think of SB as a reference to Aarhus.

Your session will start on a machine, like `abr-pc.sb.statsbiblioteket.dk`. This machine MUST have a specific IP, or 
it will be denied by a firewall somewhere in along the route.

```
abr@abr-pc:~$ traceroute -I narchive-p-hdfs01.hadoop-mgmt.bitarkiv.kb.dk
 1  _gateway (172.18.0.1)  0.488 ms  0.555 ms  0.668 ms
 2  x1-10g.statsbiblioteket.dk (130.225.247.65)  1.019 ms  1.108 ms  1.275 ms
 3  pfsense-bitarkiv.kb.dk (10.12.4.6)  6.683 ms  6.682 ms  6.764 ms
 4  10.205.0.21 (10.205.0.21)  6.680 ms  6.678 ms  6.677 ms
:) 16:32:24 abr@abr-pc:~$ 
``` 

`x1-10g.statsbiblioteket.dk` is the firewall that handles "Aarhus" access to the KB KBH internal network.

`pfsense-bitarkiv.kb.dk` is the central firewall in the diagram above. 

`10.205.0.21` is the machine `narchive-p-hdfs01.hadoop-mgmt.bitarkiv.kb.dk`, also with it's own internal firewall.

So whenever a connection have to be made from you workstation to the Hadoop cluster, all these firewalls have to be 
configured correctly.


#### Dependent services external to the cage

You need to know that these services are strictly nessesary for the proper functioning of the Hadoop cluster, but 
reside externally to the cage. Interruption in connectivity might have bad consequences for the proper function of 
the cluster.

##### FreeIPA Authentication server

All, including service users, are managed by FreeIPA. Local users (except root) is not used at all. 

The FreeIPA installation is `kbhpc-fipa-001.kbhpc.kb.dk`, which is a VMWare VM in Aarhus. 

We will return to this server and how it is set up later on 

##### NTP servers

All the Hadoop machines (i.e.) the ones managed with these ansible scripts have been set up to use the pool `pool.ntp.kb.dk`

It is IMPERATIVE that the clock stay synchronized between the machines, as the [Kerberos] authentication is highly 
dependent on this. We will return to Kerberos later on in this guide.

I have no idea what pool or servers the machines outside the hadoop cluster uses, but I HOPE that the netarchive 
machines (kb-prod-adm-001.kb.dk, kb-prod-way-001.kb.dk, kb-prod-acs-001.kb.dk, kb-prod-ana-001.kb.dk) use the same 
pool...

#### To sum up

You can read more about the firewall config [here](https://sbprojects.statsbiblioteket.dk/display/HPC/NA-HDP+Prod+cluster+hosts)

This is the (probably incomplete) list of resources that MUST be reachable from the Hadoop cluster:

* <https://deimos.statsbiblioteket.dk> : YUM repos; ports: 80, 443 TCP
* <172.16.0.11> + <172.16.0.12> : DNS servers;
* <https://sbprojects.statsbiblioteket.dk> : Git + Nexus repos; porte: 80, 443, 7999 TCP
* <pool.ntp.kb.dk> : NTP server
* <https://kbhpc-fipa-001.kbhpc.kb.dk> : ports (TCP): 80, 443, ldap, ldaps, ssh, 464, 749, 88; ports (UDP): 88, 464, 749 

Contact Christian Lange (KBH) and Niels Baggesen (Aarhus) for details about these things.

### The Networks

The Narchive (prod) cluster consist of 5 networks

* `bitarkiv-mgmt` (bitarkiv.kb.dk) (10.20.0.0/24) (vlan 203)
  * This the network of the VMWare cluster
* `bitarkiv-hadoop` (hadoop.bitarkiv.kb.dk) (10.204.0.0/24) (vlan 204)
  * The primary network for inter-cluster communication.
  * This network is routed to the Netarchive machines for them to access the Hadoop cluster
* `bitarkiv-hadoop-mgmt` (hadoop-mgmt.bitarkiv.kb.dk) (10.205.0.0/24) (vlan 205)
  * The management network. This is the network that is routed to the internal networks of KB and SB, and the only way for admins to access the cluster
* `bitarkiv-hadoop-san` (hadoop-san.bitarkiv.kb.dk) (10.206.0.0/24) (vlan 206)
  * This network is routed to `bitarkiv-prod` below
* `bitarkiv-prod` (bitarkiv.kb.dk) (172.16.0.0/24) (vlan 200)
  * The network for the Isilon storage cluster. Must be available (for NFS mounts) by the Hadoop cluster

## User Management

Now the fun really starts. 
I really recommed you read <https://steveloughran.gitbooks.io/kerberos_and_hadoop/content/sections/kerberos_the_madness.html>

> When HP Lovecraft wrote his books about forbidden knowledge which would reduce the reader to insanity, of "Elder Gods" to whom all of humanity were a passing inconvenience, most people assumed that he was making up a fantasy world. **In fact he was documenting Kerberos**.

TODO Authentication

TODO Authorization
 
TODO FreeIPA Client and SSD (no, not that kind, the other one)

TODO Impersonation, i.e. remote sudo

TODO Fun with DNS or how we cannot have nice things

# YARN

# HDFS Revisited (Failover config, Zookeeper and so on)

# Other Hadoop services (Spark, Map-reduce.)

# VMs and Hosts

# SSL, or who cares about Certificate Authorities

# Log collection (Rsyslog)

# Monitoring and how you will learn to write scripts
