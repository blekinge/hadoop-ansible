sudo dnf -y install libcurl-devel
sudo dnf -y install \
gcc \
libxml2-devel \
python3-devel

mkvirtualenv ansible-ovirt

pip install ovirt-engine-sdk-python

ansible-galaxy collection install ovirt.ovirt