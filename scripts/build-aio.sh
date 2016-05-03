#!/bin/sh
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

# Install dependencies
apt-get update && apt-get -y upgrade && apt-get -y install git git-review \
  ack-grep build-essential screen libssl-dev libffi-dev python-dev screen

# Clone the repo
git clone https://github.com/mrda/openstack-ansible.git /opt/openstack-ansible
cd /opt/openstack-ansible

# Go to the right branch
git checkout liberty-cba

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
UTIL=$(lxc-ls | grep utility)
lxc-attach -n $UTIL
cd /root
. openrc
ironic driver-list
ironic node-list
