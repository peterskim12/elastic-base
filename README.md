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
OpenJDK 8 is also installed.

VM is configured as private network since Vagrant port forwarding
does not work with default Elasticsearch network setting of only
allowing localhost access. IP address of 192.168.56.5 is assigned.

Default u/p for Elasticsearch: elastic/changeme

## Prereqs

The Vagrantfile will provision 3GB of RAM to the VM. If your machine doesn't
have enough RAM to support running a VM of that size, you can modify
this in the Vagrant file.

## Steps

* Install VirtualBox (if you haven't already)
* Install [Vagrant](https://www.vagrantup.com/docs/installation/) (if you haven't already)
* Clone this repo or [download a release](https://github.com/peterskim12/elastic-base/releases)
* Run `vagrant up`
* Run `vagrant ssh` to log into the VM

You can communicate with Elasticsearch on http://192.168.56.5:9200 or hit
Kibana at http://192.168.56.5:5601.

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

## Snapshot and restore

Use the snapshot.sh and restore.sh scripts to migrate data from one environment
to another.

### snapshot.sh

* If necessary, copy snapshot.sh to your previous environment.
* Ensure Elasticsearch is running.
* Run snapshot.sh within the guest OS. This will write the snapshot files
in your es_snapshots directory.

When the snapshot operation is complete, copy the my_backup files from the
es_snapshots directory in your previous environment to the es_snapshots dir in
your new environment.

### restore.sh

Within the guest OS of your new environment, run restore.sh.
