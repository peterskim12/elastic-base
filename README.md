# elastic-base

## Intro

Vagrant script to provision [Elastic Stack](https://www.elastic.co/v5):
* Elasticsearch
* Logstash
* Kibana
* Beats
  * Packetbeat
  * Filebeat
  * Metricbeat
* X-Pack

All software is installed in `/opt/elastic`.
Oracle Java 8 JDK is also installed.

VM is configured as private network since Vagrant port forwarding
does not work with default Elasticsearch network setting of only
allowing localhost access. IP address of 192.168.56.5 is assigned.

## Prereqs

The Vagrantfile will provision 3GB of RAM to the VM. If your machine doesn't
have enough RAM to support running a VM of that size, you can modify
this in the Vagrant file.

## Steps

* Install [Vagrant](https://www.vagrantup.com/docs/installation/)
* Clone this repo
* Run `vagrant up`

For more information on Vagrant, check out their [documentation](https://www.vagrantup.com/docs/).

## How to use

This is not a Vagrant tutorial; see their [docs](https://www.vagrantup.com/docs/) for more info.

Vagrant provides an elegant way to encapsulate dev environments. Once
you provision your Vagrant Elastic Stack environment, Elasticsearch and
Kibana are running and accessible at 192.168.56.5 on ports 9200 and 5601
respectively.

The /vagrant dir gets mounted automatically and is mapped to the directory
on your host containing the Vagrantfile. This makes it convenient to
place files such as Logstash configs, Elasticsearch index templates, raw
data files, etc. in the same dir as your Vagrantfile and execute Logstash
against those files by referencing them on the /vagrant mount.

Over time, as you work on different projects, just clone the elastic-base
project to another directory, place the project-specific files in that dir,
and you have an Elastic Stack environment specific for that project that
isn't muddled with configs and indexes from other projects.
