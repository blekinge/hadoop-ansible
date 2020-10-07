#ovirt_sdk_setup.sh

workon ansible-ovirt

#ansible-playbook -i hosts/localhost playbook-ovirt.yml -e shortname=hdfs001
#ansible-playbook -i hosts/localhost playbook-ovirt.yml -e shortname=hdfs002
ansible-playbook -i hosts/localhost playbook-ovirt.yml -e shortname=zkpr001
ansible-playbook -i hosts/localhost playbook-ovirt.yml -e shortname=zkpr002
ansible-playbook -i hosts/localhost playbook-ovirt.yml -e shortname=zkpr003
#ansible-playbook -i hosts/localhost playbook-ovirt.yml -e shortname=yarn001
#ansible-playbook -i hosts/localhost playbook-ovirt.yml -e shortname=yarn002
ansible-playbook -i hosts/localhost playbook-ovirt.yml -e shortname=hist001