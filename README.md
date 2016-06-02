# Shiny-Engine

Clouds are meant to be easy to use, buit often they're not.
Shiny-Engine is a bunch of things to make things easy.  Like what?

* se-mkinstance - make a public cloud instance.  This is an interactive script, not a script with a bazillion parameters.  If you want that, just use `rack` instead.
* se-rm-instance - delete a cloud vm instance forever
* se-mv-instance - rename a cloud instance, noting this doesn't change the hostname, only the identifier in the Rackspace MyCloud control panel that is used for other Shiney-Engine operations
* se-ls-instances - list your public cloud instances
* se-ls-regions - list the regions you have setup
* se-ip-addr - find the IP address of your public cloud instance

On top of these, there's a couple other things that are provided.  For using the [openstack-ansible](https://github.com/openstack/openstack-ansible) code base, we have the following helper scripts:

* aio-build - build an openstack-ansible "All in One" on localhost.  You can choose which tagged OpenStack release to use - just use `aio-build -h` to find out how to do that.
* os-cmd - run a particular command in the lxc utility container, on localhost.  This is so you don't have to lxc-attach to the container, source the openrc, and run your command.  It makes life a little easier :)

## Install
The easiest way to run the Shiny-Engine scripts is to run the set up script: \./se-setup.sh`.  Just remember to have ${HOME}/bin/noarch in your path.
