#!/usr/bin/env bash

apt-get update
mkdir /opt/elastic
chown vagrant:vagrant /opt/elastic
cd /opt/elastic

# Install Oracle JDK 8
add-apt-repository -y ppa:webupd8team/java
apt-get -y -q update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y -q install oracle-java8-installer
update-java-alternatives -s java-8-oracle

# Download the Elastic product tarballs
wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.4.0/elasticsearch-2.4.0.tar.gz
wget https://download.elastic.co/kibana/kibana/kibana-4.6.0-linux-x86_64.tar.gz
wget https://download.elastic.co/logstash/logstash/logstash-2.4.0.tar.gz
wget https://download.elastic.co/beats/topbeat/topbeat-1.3.0-x86_64.tar.gz
wget https://download.elastic.co/beats/packetbeat/packetbeat-1.3.0-x86_64.tar.gz
wget https://download.elastic.co/beats/filebeat/filebeat-1.3.0-x86_64.tar.gz

# Untar the bits
sudo -u vagrant bash -c 'for f in *.tar.gz; do tar xf $f; done'

# Add required encryptionKey for Reporting
cat <<KIBANA_CONF >> /opt/elastic/kibana-4.6.0-linux-x86_64/config/kibana.yml
reporting.encryptionKey: "FeelTheBern"
KIBANA_CONF

# Recommended ES settings
# START BOOTSTRAP CHECKS CONFIG CHANGES #
cat <<ES_CONF >> /opt/elastic/elasticsearch-2.4.0/config/elasticsearch.yml
network.host: [_local_, _eth1_]

bootstrap.mlockall: true
discovery.zen.minimum_master_nodes: 1
ES_CONF

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

# Install license plugin
cd /opt/elastic/elasticsearch-2.4.0
sudo -u vagrant bash -c 'bin/plugin install elasticsearch/license/latest'

# Install Watcher in Elasticsearch
sudo -u vagrant bash -c 'bin/plugin install elasticsearch/watcher/latest'
# Install Marvel in Elasticsearch
sudo -u vagrant bash -c 'bin/plugin install marvel-agent'
# Install Graph in Elasticsearch
sudo -u vagrant bash -c 'bin/plugin install graph'

# Run Elasticsearch
sudo -u vagrant nohup bash -c 'bin/elasticsearch' <&- &>/dev/null &

# Install Marvel, Graph and Reporting in Kibana
cd /opt/elastic/kibana-4.6.0-linux-x86_64
sudo -u vagrant bash -c 'bin/kibana plugin --install elasticsearch/marvel/latest'
sudo -u vagrant bash -c 'bin/kibana plugin --install kibana/reporting/latest'
sudo -u vagrant bash -c 'bin/kibana plugin --install elasticsearch/graph/latest'

# Run Kibana
sudo -u vagrant nohup bash -c 'bin/kibana' <&- &>/dev/null &
