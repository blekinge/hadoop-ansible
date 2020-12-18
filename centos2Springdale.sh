#!/bin/bash
# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# Script to switch CentOS (or other similar distribution) to the
# Springdale Linux yum repository.
#

set -e
unset CDPATH

yum_url=ftp://ftp.kac.kb.dk/pub/yum_repofiles/SDL7/int/
contact_email=abr@kb.dk
bad_packages=(centos-release-cr libreport-plugin-rhtsupport yum-rhn-plugin desktop-backgrounds-basic centos-logos libreport-centos libreport-plugin-mantisbt sl-logos)

usage() {
    echo "Usage: ${0##*/} [OPTIONS]"
    echo
    echo "OPTIONS"
    echo "-h"
    echo "        Display this help and exit"
    exit 1
} >&2

have_program() {
    hash "$1" >/dev/null 2>&1
}

dep_check() {
    if ! have_program "$1"; then
        exit_message "'${1}' command not found. Please install or add it to your PATH and try again."
    fi
}

exit_message() {
    echo "$1"
    echo "For assistance, please email <${contact_email}>."
    exit 1
} >&2

restore_repos() {
    yum remove -y "${new_releases}"
    find . -name 'repo.*' | while read -r repo; do
        destination=$(head -n1 "$repo")
        if [ "${destination}" ]; then
            tail -n+2 "${repo}" > "${destination}"
        fi
    done
    rm "${reposdir}/${repo_file}"
    exit_message "Could not install Springdale Linux packages.
Your repositories have been restored to your previous configuration."
}

## Start of script

while getopts "h" option; do
    case "$option" in
        h) usage ;;
        *) usage ;;
    esac
done

if [ "$(id -u)" -ne 0 ]; then
    exit_message "You must run this script as root.
Try running 'su -c ${0}'."
fi

echo "Checking for required packages..."
for pkg in rpm yum python2 curl; do
    dep_check "${pkg}"
done

echo "Checking your distribution..."
if ! old_release=$(rpm -q --whatprovides redhat-release); then
    exit_message "You appear to be running an unsupported distribution."
fi

if [ "$(echo "${old_release}" | wc -l)" -ne 1 ]; then
    exit_message "Could not determine your distribution because multiple
packages are providing redhat-release:
$old_release
"
fi

case "${old_release}" in
    redhat-release*) ;;
    centos-release*) ;;
    sl-release*) ;;
    sprindale-release*)
        exit_message "You appear to be already running Springdale Linux."
        ;;
    *) exit_message "You appear to be running an unsupported distribution." ;;
esac

rhel_version=$(rpm -q "${old_release}" --qf "%{version}")
base_packages=(basesystem initscripts springdale-logos)
case "$rhel_version" in
    7*)
        repo_file=springdale7i-core.repo
        new_releases=(springdale-release)
        base_packages=("${base_packages[@]}" plymouth grub2 grubby kernel)
        ;;
    *) exit_message "You appear to be running an unsupported distribution." ;;
esac

echo "Checking for yum lock..."
if [ -f /var/run/yum.pid ]; then
    yum_lock_pid=$(cat /var/run/yum.pid)
    yum_lock_comm=$(cat "/proc/${yum_lock_pid}/comm")
    exit_message "Another app is currently holding the yum lock.
The other application is: $yum_lock_comm
Running as pid: $yum_lock_pid
Run 'kill $yum_lock_pid' to stop it, then run this script again."
fi

echo "Looking for yumdownloader..."
if ! have_program yumdownloader; then
    yum -y install yum-utils || true
    dep_check yumdownloader
fi

echo "Finding your repository directory..."

reposdir=$(python2 -c "
import yum
import os

for dir in yum.YumBase().doConfigSetup(init_plugins=False).reposdir:
    if os.path.isdir(dir):
        print dir
        break
")

if [ -z "${reposdir}" ]; then
    exit_message "Could not locate your repository directory."
fi
cd "$reposdir"

#TODO handle multiple files here
echo "Downloading Springdale Linux yum repository file..."
if ! curl -o "switch-to-springdalelinux.repo" "${yum_url}/${repo_file}"; then
    exit_message "Could not download $repo_file from $yum_url.
Are you behind a proxy? If so, make sure the 'http_proxy' environment
variable is set with your proxy address."
fi

cd "$(mktemp -d)"
trap restore_repos ERR

echo "Backing up and removing old repository files..."
rpm -ql "$old_release" | grep '\.repo$' > repo_files
while read -r repo; do
    if [ -f "$repo" ]; then
        cat - "$repo" > "$repo".disabled <<EOF
# This is a yum repository file that was disabled by
# ${0##*/}, a script to convert CentOS to Springdale Linux.
# Please see $yum_url for more information.

EOF
        tmpfile=$(mktemp repo.XXXXX)
        echo "$repo" | cat - "$repo" > "$tmpfile"
        rm "$repo"
    fi
done < repo_files

echo "Downloading Springdale Linux release package..."
if ! yumdownloader "${new_releases[@]}"; then
    {
        echo "Could not download the following packages from $yum_url:"
        echo "${new_releases[@]}"
        echo
        echo "Are you behind a proxy? If so, make sure the 'http_proxy' environment"
        echo "variable is set with your proxy address."
    } >&2
    restore_repos
fi

echo "Switching old release package with Springdale Linux..."
rpm -i --force '*.rpm'
rpm -e --nodeps "$old_release"
rm -f "${reposdir}/switch-to-springdalelinux.repo"

# At this point, the switch is completed.
trap - ERR

echo "Installing base packages for Springdale Linux..."
if ! yum shell -y <<EOF
remove ${bad_packages[@]}
install ${base_packages[@]}
run
EOF
then
    exit_message "Could not install base packages.
Run 'yum distro-sync' to manually install them."
fi
if [ -x /usr/libexec/plymouth/plymouth-update-initrd ]; then
    echo "Updating initrd..."
    /usr/libexec/plymouth/plymouth-update-initrd
fi

echo "Switch successful. Syncing with Springdale Linux repositories."

if ! yum -y distro-sync; then
    exit_message "Could not automatically sync with Springdale Linux repositories.
Check the output of 'yum distro-sync' to manually resolve the issue."
fi


echo "Switch complete. Springdale recommends rebooting this system."