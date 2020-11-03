# Resources for learnings on Ansible

Start by skimming <https://docs.ansible.com/ansible/latest/user_guide/index.html>

Make sure you are clear on <https://docs.ansible.com/ansible/latest/user_guide/basic_concepts.html>

If you got these, you can understand pretty much everything else.

# Relevant Ansible modules and roles

These are my GoTo modules and roles for building this cluster. I have used few modules not on this list.

If you understand the basics of what each of these do, you should be able to understand what my scripts do.


* Ansible internals
    * ansible.builtin.**set_fact** – Set host facts from a task: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/set_fact_module.html>

    * ansible.builtin.**include_tasks** – Dynamically include a task list: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_tasks_module.html>

    * **block** - Blocks create logical groups of tasks. <https://docs.ansible.com/ansible/latest/user_guide/playbooks_blocks.html>

    * **when** - execute different tasks, or have different goals, depending on the value of a thing: <https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html>
    
    * **loop** - Sometimes you want to repeat a task multiple times: <https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html>
    
    * **delegate_to** - how to delegate to a different machine or group: <https://docs.ansible.com/ansible/latest/user_guide/playbooks_delegation.html>
    
    * **become** - Ansible uses existing privilege escalation systems to execute tasks with root privileges or with another user’s permissions: <https://docs.ansible.com/ansible/latest/user_guide/become.html>
    
    * **serial** -  If you want to manage only a few machines at a time, for example during a rolling update, you can define how many hosts Ansible should manage at a single time using the serial keyword: <https://docs.ansible.com/ansible/latest/user_guide/playbooks_strategies.html#setting-the-batch-size-with-serial>
    
    * **throttle** - The throttle keyword limits the number of workers for a particular task: <https://docs.ansible.com/ansible/latest/user_guide/playbooks_strategies.html#restricting-execution-with-throttle>
    
    * **run_once** - If you want a task to run only on the first host in your batch of hosts, set run_once to true on that task: <https://docs.ansible.com/ansible/latest/user_guide/playbooks_strategies.html#running-on-a-single-machine-with-run-once>

* When all you have is a hammer:
    * ansible.builtin.shell – Execute shell commands on targets: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html>


* File externals
    
    * ansible.builtin.file – Manage files and file properties: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html>

    * ansible.builtin.stat – Retrieve file or file system status: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/stat_module.html>
  
    
* File internals
    * ansible.builtin.lineinfile – Manage lines in text files: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html>

    * ansible.builtin.replace – Replace all instances of a particular string in a file using a back-referenced regular expression: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/replace_module.html>


* Upload to remote host
    * ansible.builtin.copy – Copy files to remote locations: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html>

    * ansible.builtin.template – Template a file out to a remote server: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html>

    * ansible.posix.synchronize – A wrapper around rsync to make common tasks in your playbooks quick and easy: <https://docs.ansible.com/ansible/latest/collections/ansible/posix/synchronize_module.html>

    * ansible.builtin.unarchive – Unpacks an archive after (optionally) copying it from the local machine: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html>



* System health

    * ansible.builtin.wait_for_connection – Waits until remote system is reachable/usable: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/wait_for_connection_module.html>

    * ansible.builtin.reboot – Reboot a machine: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/reboot_module.html>


* File systems and disks

    * community.general.parted – Configure block device partitions: <https://docs.ansible.com/ansible/latest/collections/community/general/parted_module.html>

    * community.general.filesystem – Makes a filesystem: <https://docs.ansible.com/ansible/latest/collections/community/general/filesystem_module.html>
    
    * ansible.posix.mount – Control active and configured mount points: <https://docs.ansible.com/ansible/latest/collections/ansible/posix/mount_module.html>


* Extra
    merge_vars: TODO

*  System management
    * ansible.builtin.systemd – Manage services: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html>

    * ansible.posix.firewalld – Manage arbitrary ports/services with firewalld: <https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html>


* Install stuff
    
    * ansible.builtin.package – Generic OS package manager: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html>
    
    * ansible.builtin.rpm_key – Adds or removes a gpg key from the rpm db: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/rpm_key_module.html>

    * ansible.builtin.pip – Manages Python library dependencies: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pip_module.html>
    
    * community.general.npm – Manage node.js packages with npm:  <https://docs.ansible.com/ansible/latest/collections/community/general/npm_module.htm>
    

* User management

    * ansible.builtin.user – Manage user accounts: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html>

    * ansible.builtin.group – Add or remove groups: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/group_module.html>
    
    * ansible.posix.authorized_key – Adds or removes an SSH authorized key: <https://docs.ansible.com/ansible/latest/collections/ansible/posix/authorized_key_module.html>


* FreeIPA: <https://github.com/freeipa/ansible-freeipa>
    
    * Client Role: <https://github.com/freeipa/ansible-freeipa/blob/master/roles/ipaclient/README.md>

    * Services
        * ipaservice: <https://github.com/freeipa/ansible-freeipa/blob/master/README-service.md>
    
    * Users and groups
        * ipagroup: <https://github.com/freeipa/ansible-freeipa/blob/master/README-group.md>
    
        * ipauser: <https://github.com/freeipa/ansible-freeipa/blob/master/README-user.md>
    
    * Sudo rules
        * ipasudorule: <https://github.com/freeipa/ansible-freeipa/blob/master/README-sudorule.md>
    
        * ipasudocmdgroup: <https://github.com/freeipa/ansible-freeipa/blob/master/README-sudocmdgroup.md>
    
        * ipasudocmd: <https://github.com/freeipa/ansible-freeipa/blob/master/README-sudocmd.md>
   
    * HBAC rules
        * hbacrule: <https://github.com/freeipa/ansible-freeipa/blob/master/README-hbacrule.md>
        
        * hbacsvc: <https://github.com/freeipa/ansible-freeipa/blob/master/README-hbacsvc.md>
        
        * hbacsvcgroup : <https://github.com/freeipa/ansible-freeipa/blob/master/README-hbacsvcgroup.md>
    

* Ovirt <https://docs.ansible.com/ansible/latest/collections/ovirt/ovirt/>
    
    * ovirt.ovirt.ovirt_auth – Module to manage authentication to oVirt/RHV: <https://docs.ansible.com/ansible/latest/collections/ovirt/ovirt/ovirt_auth_module.html>
    
    * ovirt.ovirt.ovirt_vm – Module to manage Virtual Machines in oVirt/RHV: <https://docs.ansible.com/ansible/latest/collections/ovirt/ovirt/ovirt_vm_module.html>
    
    * ovirt.ovirt.ovirt_disk – Module to manage Virtual Machine and floating disks in oVirt/RHV: <https://docs.ansible.com/ansible/latest/collections/ovirt/ovirt/ovirt_disk_module.html>

    * ovirt.ovirt.ovirt_nic – Module to manage network interfaces of Virtual Machines in oVirt/RHV: <https://docs.ansible.com/ansible/latest/collections/ovirt/ovirt/ovirt_nic_module.html>


* Zabbix: <https://github.com/ansible-collections/community.zabbix/>
    * community.zabbix.zabbix_agent: <https://github.com/ansible-collections/community.zabbix/blob/main/docs/ZABBIX_AGENT_ROLE.md>

