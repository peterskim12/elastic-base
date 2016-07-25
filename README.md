# elastic-base

Vagrant script to provision Elastic Stack:
* Elasticsearch
* Logstash
* Kibana
* Beats
  * Packetbeat
  * Filebeat
  * Metricbeat
* X-Pack (Shield disabled)

All software is installed in /opt/elastic.
Oracle Java 8 JDK is also installed.

VM is configured as private network since Vagrant port forwarding
does not work with default Elasticsearch network setting of only
allowing localhost access. IP address of 192.168.56.5 is assigned.
