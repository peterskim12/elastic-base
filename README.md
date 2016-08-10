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
* X-Pack (Shield disabled)

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
