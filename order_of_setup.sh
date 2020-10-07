ansible-playbook -i hosts/host.yml playbook-baseVMs.yml
ansible-playbook -i hosts/host.yml playbook-install-hadoop.yml
ansible-playbook -i hosts/host.yml playbook-kerberos-services.yml
ansible-playbook -i hosts/host.yml playbook-zookeeper.yml
ansible-playbook -i hosts/host.yml playbook-hdfs-setup.yml
ansible-playbook -i hosts/host.yml playbook-yarn-setup.yml
ansible-playbook -i hosts/host.yml playbook-mapreduce-setup.yml