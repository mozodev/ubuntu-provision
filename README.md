# ubuntu-provision

Provisioning script template for ubuntu virtual environment using vagrant or multipass cloud init.

## Included List

* Language - Java, NodeJS, PHP, Ruby(using rbenv)
* DB - MariaDB, MySQL, Postgres
* APP - Code Server, Docker, Drupal, Hugo, Ruby on Rails, Rclone, Seatable, Wordpress, [mecab-ko](https://bitbucket.org/eunjeon/mecab-ko/src/master/README.md)

## how to use with VAGRANT

1. clone the repo
2. modify your environment variables to use this repo's template as [VAGRANT_DEFAULT_TEMPLATE](https://www.vagrantup.com/docs/other/environmental-variables#vagrant_default_template).

```
## ~/.bashrc # or your file of choice.
export VAGRANT_DEFAULT_TEMPLATE=~/path/to/ubuntu-provision/vagrant/Vagrantfile.erb
```

```
$ source ~/.bashrc
```

3. Create vagrant file with necessary application(s) you need as parameter(s) and boot virtual environment. 
```
$ mkdir foo
$ cd foo
$ APP=hugo vagrant init
```
* Reference vagrant/Vagrantfile.erb for list of parameters to include as provision scripts.
* If declaring multiple langs, db, apps, delimit them with comma(s).
```
$ APP=hugo,rclone,mecab-ko vagrant init
```

4. Further modify your Vagrantfile or .env file and then vagrant up.
```
$ cd path/to/vagrantfile
$ vagrant up 
```

## How to use with multipass and cloud init

1. clone the repo
2. copy cloud-init.yml.example to create cloud-init.yml configuration file
3. edit cloud-init.yml to include variables or scripts
4. launch multipass 
```
$ multipass launch -n project_name --cloud-init path/to/cloud-init.yml
```

## troubleshooting

### How to mount a qcow2 disk image on Ubuntu 

https://docs.j7k6.org/mount-qcow2-disk-image-linux/

```bash
$ sudo apt -y install qemu-utils
# $ IMG=/var/snap/multipass/common/data/multipassd/vault/instances/php7/ubuntu-20.04-server-cloudimg-amd64.img
$ IMG=/var/snap/multipass/common/data/multipassd/vault/instances/mariadb/ubuntu-20.04-server-cloudimg-amd64.img
$ sudo modprobe nbd max_part=8
$ sudo qemu-nbd --connect=/dev/nbd0 --read-only $IMG
$ sudo fdisk -l /dev/nbd0
$ sudo mount -o ro /dev/nbd0p1 /home/mozo/mnt
$ mkdir ~/php7
$ cd /home/mozo/mnt/home/ubuntu/projects/
$ cp -r ./*  ~/php7/*

$ sudo umount /home/mozo/mnt
$ sudo qemu-nbd --disconnect /dev/nbd0
```
