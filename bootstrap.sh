#!/usr/bin/env bash

apt-get update
mkdir /opt/elastic
chown vagrant:vagrant /opt/elastic
cd /opt/elastic

# Install OpenJDK 8
apt-get -y -q update
apt-get -y -q install openjdk-8-jdk

# Download the Elastic product tarballs
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.1.2.tar.gz
wget https://artifacts.elastic.co/downloads/kibana/kibana-5.1.2-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/logstash/logstash-5.1.2.tar.gz
wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-5.1.2-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-5.1.2-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.1.2-linux-x86_64.tar.gz

# Untar the bits
sudo -u vagrant bash -c 'for f in *.tar.gz; do tar xf $f; done'

# Allow all requests to Kibana
cat <<KIBANA_CONF >> /opt/elastic/kibana-5.1.2-linux-x86_64/config/kibana.yml
server.host: "0.0.0.0"
KIBANA_CONF

# Recommended ES settings to pass bootstrap checks
# START BOOTSTRAP CHECKS CONFIG CHANGES #
cat <<ES_CONF >> /opt/elastic/elasticsearch-5.1.2/config/elasticsearch.yml
http.host: [_local_, _enp0s8_]
path.repo: ["/vagrant/es_snapshots"]

bootstrap.memory_lock: true
discovery.zen.minimum_master_nodes: 1
ES_CONF

sed -i -e 's/Xms2g/Xms1g/g' /opt/elastic/elasticsearch-5.1.2/config/jvm.options
sed -i -e 's/Xmx2g/Xmx1g/g' /opt/elastic/elasticsearch-5.1.2/config/jvm.options

sysctl -w vm.max_map_count=262144
cat <<SYSCTL >> /etc/sysctl.conf
vm.max_map_count=262144
SYSCTL

ulimit -n 65536
ulimit -u 2048
ulimit -l unlimited
cat <<SECLIMITS >> /etc/security/limits.conf
*                soft    nofile         1024000
*                hard    nofile         1024000
*                soft    memlock        unlimited
*                hard    memlock        unlimited
vagrant           soft    nofile         1024000
vagrant           hard    nofile         1024000
vagrant           soft    memlock        unlimited
vagrant           hard    memlock        unlimited
vagrant           soft    nproc        2048
vagrant           hard    nproc        2048
vagrant           soft    as        unlimited
vagrant           hard    as        unlimited
root             soft    nofile         1024000
root             hard    nofile         1024000
root             soft    memlock        unlimited
root           soft    as        unlimited
root           hard    as        unlimited
SECLIMITS
# END BOOTSTRAP CHECKS CONFIG CHANGES #

# Install X-Pack in Elasticsearch
cd /opt/elastic/elasticsearch-5.1.2
sudo -u vagrant bash -c 'bin/elasticsearch-plugin install x-pack --batch'
# Run Elasticsearch
# sudo -u vagrant nohup bash -c 'bin/elasticsearch' <&- &>/dev/null &

# Install X-Pack in Kibana
cd /opt/elastic/kibana-5.1.2-linux-x86_64
sudo -u vagrant bash -c 'bin/kibana-plugin install x-pack'
# Run Kibana
# sudo -u vagrant nohup bash -c 'bin/kibana' <&- &>/dev/null &
