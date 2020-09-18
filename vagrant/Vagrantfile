BOX_IMAGE = 'centos/7'


HADOOP_NET = "10.0.0"
HADOOP_NETWORK = "nah.hadoop"
IPA_ADM_IP = HADOOP_NET + ".9"


Vagrant.configure("2") do |config|

  config.vagrant.plugins = {"vagrant-sshfs" => {"version" => "1.3.5"}}

  config.vm.provider "virtualbox" do |v|
    # v.gui = true
    #This speeds up recreating containers
    v.linked_clone = true

    v.memory = 2048
    v.cpus = 2
  end

  config.vm.synced_folder ".", "/vagrant", type: "sshfs"

  # config.vm.provision :shell,
  #                     inline: "yum update -y",
  #                     name: "yum update"
  #


  config.vm.provision :shell,
                      inline: "echo -e 'vagrant123\nvagrant123'|  passwd vagrant",
                      name: "vagrant password set"

  #Vagrant places hostname in /etc/hosts. This cause our scripts to get the wrong IP address. Remove it
  config.vm.provision "shell", inline: "cp /etc/hosts /etc/hosts.orig", name: "backing up /etc/hosts"
  config.vm.provision "shell", inline: "grep localhost /etc/hosts.orig > /etc/hosts", name: "Removing hostname from hosts", run: "always"

  config.vm.provision :shell,
                      name: "Fixing DNS",
                      path: "vagrant/fixDNS.sh",
                      run: "always"


  # FreeIPA and nfs server
  config.vm.define "nah-adm" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.hostname = "nah-adm." + HADOOP_NETWORK
    subconfig.vm.network :private_network, ip: IPA_ADM_IP

    # config.vm.provider :virtualbox do |vb|
    #   vb.auto_nat_dns_proxy = false
    # end
  end


  # DataNodes
  #

  (1..3).each { |j|
    config.vm.define "nah-data-00#{j}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vm.hostname = "nah-data-00#{j}.#{HADOOP_NETWORK}"
      subconfig.vm.network :private_network, ip: "#{HADOOP_NET}.1#{j}"

      subconfig.vm.provider "virtualbox" do |v|
        v.memory = 8192
        v.cpus = 4
      end
    end
  }


  # Ambari Server
  config.vm.define "nah-master" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.hostname = "nah-master." + HADOOP_NETWORK
    subconfig.vm.network :private_network, ip: HADOOP_NET + ".113"

    subconfig.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 4
    end

  end



end

