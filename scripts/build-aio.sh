#!/bin/bash
#
# build-aio.sh - Build an all-in-one openstack-ansible with
#                ironic included
#
# Copyright (C) 2016 Michael Davies <michael@the-davies.net>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.
#

# v1.0 - Support Liberty and Mitaka, with Liberty from mrda's repo
VERSION=1.0.1
USAGE="\nBuild an AIO for an optionally specified release\n\n \
-h|--help - display this help text\n \
-v|--version - display version information about this program\n \
-l|--list - list supported releases \n \
release - the release to build (optional)"

MYNAME="$(basename $0)"
COPY="Copyright (C) 2016 Michael Davies <michael@the-davies.net>"
SUPPORTED_RELS="\n  Liberty\n  Mitaka"

# Make sure we're running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root.  Exiting..." 2>&1
  exit 1
fi

case "$1" in
    -h|--help)
        echo "${MYNAME} [-h|-v|-l|--help|--version|--list] [release]"
        echo "${USAGE}"
        exit 1
        ;;
    -v|--version)
        echo "${MYNAME}: ${VERSION}"
        echo "${COPY}"
        exit 1
        ;;
    -l|--list)
        echo "${MYNAME}: The supported releases are: ${SUPPORTED_RELS}"
        exit 1
        ;;
esac


# Determine what release to build
if [ $# -eq 0 ]; then
  echo "--- No release requested, using the default"
  RELEASE="Liberty"
else
  RELEASE=$1
fi

case "${RELEASE}" in
    [Ll]iberty)
        # Definitions for openstack-ansible Liberty version
        echo "--- Building a Liberty AIO from mrda's repository"
        REPO="https://github.com/mrda/openstack-ansible.git"
        BRANCH="liberty-cba"
        ;;
    [Mm]itaka)
        # Definitions for openstack-ansible Mitaka version
        echo "--- Building a Mitaka AIO from OpenStack's official repository"
        REPO="https://github.com/openstack/openstack-ansible.git"
        BRANCH="stable/mitaka"
        ;;
    *)
        echo "Unsupported version specified"
        exit 1
        ;;
esac

# Required dependencies
read -r -d '' DEPS << EOSTR
git
git-review
ack-grep
build-essential
screen
libssl-dev
libffi-dev
python-dev
screen
EOSTR

# Install dependencies
apt-get update
apt-get -y upgrade
apt-get -y install ${DEPS}

# Clone the repo
git clone ${REPO} /opt/openstack-ansible
cd /opt/openstack-ansible

# Go to the right branch
git fetch
git checkout ${BRANCH}

# Ironic isn't turned on by default, so copy in the environment
mkdir -p /etc/openstack_deploy/env.d/
mkdir -p /etc/openstack_deploy/conf.d
cp etc/openstack_deploy/env.d/ironic.yml /etc/openstack_deploy/env.d/ironic.yml
cp etc/openstack_deploy/conf.d/ironic.yml.aio \
   /etc/openstack_deploy/conf.d/ironic.yml

# Start the install
./scripts/bootstrap-ansible.sh
./scripts/bootstrap-aio.sh
cd playbooks
openstack-ansible haproxy-install.yml
openstack-ansible setup-everything.yml
openstack-ansible os-ironic-install.yml

# Test that it works
echo "--- Quick test to see that ironic is working..."
UTIL=$(lxc-ls | grep utility)
lxc-attach -n $UTIL -- bash -c '. /root/openrc && ironic driver-list'
