# ubuntu-provision
Provisioning script template for vagrant ubuntu virtual environment. 

```
Included List
* Language - Java, NodeJS, PHP, Ruby(using rbenv)
* DB - MariaDB, MySQL, Postgres
* APP - Code Server, Docker, Drupal, Hugo, Ruby on Rails, Rclone, Seatable, Wordpress

```

## how to use
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
$ vagrant up 
```

