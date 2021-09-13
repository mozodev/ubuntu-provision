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
