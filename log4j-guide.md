Efter meget besvær med 

https://github.com/claranet/ansible-role-log4shell

endte jeg med at lave mit eget plugin

Det kan ses her
https://sbprojects.statsbiblioteket.dk/stash/projects/YAK/repos/hadoop-ansible/browse/roles/log4jshell



Det køres med

ansible-playbook -i hosts/narchive-test/ playbook_log4j.yml

og outputter ala

...
TASK [log4jshell : patch] *********************************************************************************************************************************************************************************************************
changed: [narchive-t-yarn01.kb.dk] => (item=/usr/local/hive/apache-hive-3.1.2-bin/lib/log4j-core-2.10.0.jar)
changed: [narchive-t-admn02.kb.dk] => (item=/usr/local/hive/apache-hive-3.1.2-bin/lib/log4j-core-2.10.0.jar)
...



De to vigtige dele er

```yaml
- name: "Search for JNDILookup.class"
  loop: "{{ log4shell_scan_path }}"
  shell: "grep --recursive --include '*.jar' --include '*.war' --files-with-matches --fixed-strings '{{_log4shell_defect_class}}' {{item}}"
  register: grep_output
  failed_when: "grep_output.rc|int > 1" # 0 means hit, 1 means no hit. 2+ means error
  changed_when: "grep_output.rc|int == 0" # 0 means hit, 1 means no hit. 2+ means error
  ignore_errors: true
```

og 

```yaml
- name: patch
  loop: "{{ _log4shell_files }}"
  shell: "zip -q -d {{item}} '{{_log4shell_defect_class}}' "
```    


Playbooken jeg brugte er her

https://sbprojects.statsbiblioteket.dk/stash/projects/YAK/repos/hadoop-ansible/browse/playbook_log4j.yml

og her
```yaml

- hosts: hostgroup_all:!localhost
  remote_user: root
#  serial: 1
  roles:
    - role: log4jshell
      log4shell_scan_path:
        - /opt/
        - /usr/
        - /var/lib/


# TODO Check for war-files like this
#  ansible -i hosts/KAC hostgroup_all -a 'bash -c "find /usr -name *.war -size +10k | xargs -r -i unzip -l {} | (grep log4j-core || echo clean) | grep -v log4j-core  "' -u root
```

