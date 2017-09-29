# Puma benchmarks

## Requirements

* [VirtualBox](https://www.virtualbox.org)

* [Vagrant](http://vagrantup.com)

* [Vegeta](https://github.com/tsenart/vegeta)

## How To Build The Virtual Machine

Building the virtual machine is this easy:

    host $ git clone https://github.com/stereobooster/puma-benchmarks.git
    host $ cd puma-benchmarks
    host $ vagrant up

That's it.

After the installation has finished, you can access the virtual machine with

    host $ vagrant ssh
    Welcome to Ubuntu 17.04 (GNU/Linux 4.10.0-21-generic x86_64)
    ...
    ubuntu@puma-benchmarks:~$

Port 3000 in the host computer is forwarded to port 3000 in the virtual machine. Thus, applications running in the virtual machine can be accessed via localhost:3000 in the host computer. Be sure the web server is bound to the IP 0.0.0.0, instead of 127.0.0.1, so it can access all interfaces:

    sudo /usr/sbin/nginx -c /vagrant/benchmark/nginx.conf
    bundle exec puma -C config.rb

## What's In The Box

* Development tools

* Git

* Ruby 2.4

* Bundler

* SQLite3

## Recommended Workflow

The recommended workflow is

* edit in the host computer and

* test within the virtual machine.

```
echo "GET http://localhost:3000/" | ./vegeta attack -timeout=61s -duration=30s -rate=100 -workers=100 > results.bin
cat results.bin | ./vegeta report -reporter=plot > plot.html
open plot.html
```

Just clone your Rails fork into the puma-benchmarks directory on the host computer:

    host $ ls
    bootstrap.sh MIT-LICENSE README.md Vagrantfile benchmark

Vagrant mounts that directory as _/vagrant_ within the virtual machine:

    ubuntu@puma-benchmarks:~$ ls /vagrant
    bootstrap.sh MIT-LICENSE rails README.md Vagrantfile benchmark

Install gem dependencies in there:

    ubuntu@puma-benchmarks:~$ cd /vagrant/benchmark
    ubuntu@puma-benchmarks:/vagrant/benchmark$ bundle

We are ready to go to edit in the host, and test in the virtual machine.

## Virtual Machine Management

When done just log out with `^D` and suspend the virtual machine

    host $ vagrant suspend

then, resume to hack again

    host $ vagrant resume

Run

    host $ vagrant halt

to shutdown the virtual machine, and

    host $ vagrant up

to boot it again.

You can find out the state of a virtual machine anytime by invoking

    host $ vagrant status

Finally, to completely wipe the virtual machine from the disk **destroying all its contents**:

    host $ vagrant destroy # DANGER: all is gone

Please check the [Vagrant documentation](http://docs.vagrantup.com/v2/) for more information on Vagrant.

### rsync

Vagrant 1.5 implements a [sharing mechanism based on rsync](https://www.vagrantup.com/blog/feature-preview-vagrant-1-5-rsync.html)
that dramatically improves read/write because files are actually stored in the
guest. Just throw

    config.vm.synced_folder '.', '/vagrant', type: 'rsync'

to the _Vagrantfile_ and either rsync manually with

    vagrant rsync

or run

    vagrant rsync-auto

for automatic syncs. See the post linked above for details.

### NFS

If you're using Mac OS X or Linux you can increase the speed of Rails test suites with Vagrant's NFS synced folders.

With an NFS server installed (already installed on Mac OS X), add the following to the Vagrantfile:

    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
    config.vm.network 'private_network', ip: '192.168.50.4' # ensure this is available

Then

    host $ vagrant up

Please check the Vagrant documentation on [NFS synced folders](http://docs.vagrantup.com/v2/synced-folders/nfs.html) for more information.

## Troubleshooting

On `vagrant up`, it's possible to get this error message:

```
The box 'ubuntu/yakkety64' could not be found or
could not be accessed in the remote catalog. If this is a private
box on HashiCorp's Atlas, please verify you're logged in via
vagrant login. Also, please double-check the name. The expanded
URL and error message are shown below:

URL: ["https://atlas.hashicorp.com/ubuntu/yakkety64"]
Error:
```

And a known work-around (https://github.com/Varying-Vagrant-Vagrants/VVV/issues/354) can be:

    sudo rm /opt/vagrant/embedded/bin/curl

## License

Released under the MIT License, based on https://github.com/rails/rails-dev-box
