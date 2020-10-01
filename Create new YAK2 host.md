

1. Go to https://ovim001.adm.yak2.net/ovirt-engine/webadmin/?locale=en_US#vms
and clone SDL8-4R-30D

2. Edit the new machine, and set the NICs to yak2net and ovirtmng in this order

3. Check if the machine already exists in DNS with `host hist001.yak2.net`
If so, you know which IP to assign to it. If it does not, go to 
* <https://sbprojects.statsbiblioteket.dk/display/YAK/How+to+update+forward+DNS+zones>
* <https://sbprojects.statsbiblioteket.dk/display/YAK/How+to+update+reverse+DNS+zones>

4. Run the machine and log in. This requires firefox due to the VNC plugin

5. Change the hostname to the correct name `hist001.yak2.net`

6. When starting up, the machine will bind to the ip `172.16.215.254`. This allows you to ssh to it directly, but if you started multiple, you cannot be sure which got the ip. This is why we set the hostname with the Ovirt Console (where we can be sure which machine we are on)

7. `ssh root@172.16.215.254` 

8. Set up the network


```bash
HOSTNUMBER=146
#General values for all hosts
export SUBNET1="172.16.215"
export IPRANGE1="${SUBNET1}.0/24"
export DOMAIN_NAME1="yak2.net"
export REALM_NAME="YAK2.NET"
export STO_DATA_DIR=/sto-data
export SYSHOME_DIR="$STO_DATA_DIR/syshome"
export AUTOHOME_DIR="$STO_DATA_DIR/home"
export IPA_SERVER=fipa001.$DOMAIN_NAME1
nmcli con add type ethernet con-name yak2net ifname ens3 ipv4.method manual ipv4.addresses 172.16.215.$HOSTNUMBER/24 ipv4.dns 172.16.215.52,172.16.215.53 ipv4.dns-search yak2.net,adm.yak2.net,dmz.yak2.net,nfs.yak2.net ipv4.gateway 172.16.215.51
nmcli con add type ethernet con-name adm ifname ens4 ipv4.method manual ipv4.addresses 172.16.216.$HOSTNUMBER/24 ipv4.routes "172.16.7.0/24 172.16.216.1,172.18.0.0/16 172.16.216.1,172.28.1.0/24 172.16.216.1,130.225.24.0/23 172.16.216.1,130.226.220.0/24 172.16.216.1"
nmcli con del ens4
nmcli con up adm
nmcli con del ens3
nmcli con up yak2net
```
The final command will hang as it kills your ssh connection to the host. Disregard this and start a new terminal.

9. Fix repo files and update all
You will have to log in with ssh-agent-forwarding for this (`ssh -A root@hist001`)
```bash
#Fix borken repo files in template
scp -p root@bind002.yak2.net:/etc/yum.repos.d/* /etc/yum.repos.d/
yum install -y git rsync wget
yum update -y
systemctl reboot
```
This automatically reboots afterwards to ensure that the new kernel and software is loaded.

10. Install IPA client and register host
```bash
yum install ipa-client -y
mkdir -p /autohome
ipa-client-install --domain=yak2.net  --realm=YAK2.NET --principal=admin --ntp-server=kac-gway-001.kach.sblokalnet --automount-location=default --force-join
#General values for all hosts
export SUBNET1="172.16.215"
export IPRANGE1="${SUBNET1}.0/24"
export DOMAIN_NAME1="yak2.net"
export REALM_NAME="YAK2.NET"
export STO_DATA_DIR=/sto-data
export SYSHOME_DIR="$STO_DATA_DIR/syshome"
export AUTOHOME_DIR="$STO_DATA_DIR/home"
export IPA_SERVER=fipa001.$DOMAIN_NAME1
#Make mount point
mkdir -p /syshome
# _netdev cause the mounting to wait for network to be up
echo "$IPA_SERVER:$SYSHOME_DIR      /syshome        nfs4    rw,defaults,_netdev,hard,intr,_netdev   0 0" >> /etc/fstab
#Set the sudo timeout
sed -i "s|\(\[domain/${DOMAIN_NAME1}\]\)|\1\nentry_cache_sudo_timeout = 10|g" /etc/sssd/sssd.conf
mount -a
```

11. Fix the kerberos ticket cache locations

```bash
sed -i "s|default_ccache_name.*|default_ccache_name = /tmp/krb5cc_%{uid}|g" /etc/krb5.conf

echo "export KRB5CCNAME=FILE:/tmp/krb5cc_$UID" > /etc/profile.d/kerberos.sh

sed -i -E 's|^( *default_ccache_name *= *KCM: *)|#\1|' /etc/krb5.conf.d/kcm_default_ccache 

```