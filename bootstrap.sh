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
wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/5.0.0-alpha5/elasticsearch-5.0.0-alpha5.tar.gz
wget https://download.elastic.co/kibana/kibana/kibana-5.0.0-alpha5-linux-x86_64.tar.gz
wget https://download.elastic.co/logstash/logstash/logstash-5.0.0-alpha5.tar.gz
wget https://download.elastic.co/beats/metricbeat/metricbeat-5.0.0-alpha5-linux-x86_64.tar.gz
wget https://download.elastic.co/beats/packetbeat/packetbeat-5.0.0-alpha5-linux-x86_64.tar.gz
wget https://download.elastic.co/beats/filebeat/filebeat-5.0.0-alpha5-linux-x86_64.tar.gz

# Untar the bits
sudo -u vagrant bash -c 'for f in *.tar.gz; do tar xf $f; done'

# Disable shield
cat <<ES_CONF >> /opt/elastic/elasticsearch-5.0.0-alpha5/config/elasticsearch.yml
xpack.security.enabled: false
ES_CONF
cat <<KIBANA_CONF >> /opt/elastic/kibana-5.0.0-alpha5-linux-x86_64/config/kibana.yml
xpack.security.enabled: false
KIBANA_CONF

# Recommended ES settings to pass bootstrap checks
# START BOOTSTRAP CHECKS CONFIG CHANGES #
cat <<ES_CONF >> /opt/elastic/elasticsearch-5.0.0-alpha5/config/elasticsearch.yml
network.host: [_local_, _eth1_]

bootstrap.memory_lock: true
discovery.zen.minimum_master_nodes: 1
ES_CONF

sed -i -e 's/Xms256m/Xms512m/g' /opt/elastic/elasticsearch-5.0.0-alpha5/config/jvm.options
sed -i -e 's/Xmx2g/Xmx512m/g' /opt/elastic/elasticsearch-5.0.0-alpha5/config/jvm.options

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
cd /opt/elastic/elasticsearch-5.0.0-alpha5
sudo -u vagrant bash -c 'bin/elasticsearch-plugin install x-pack --batch'
# Run Elasticsearch
sudo -u vagrant nohup bash -c 'bin/elasticsearch' <&- &>/dev/null &

# Install X-Pack in Kibana
cd /opt/elastic/kibana-5.0.0-alpha5-linux-x86_64
sudo -u vagrant bash -c 'bin/kibana-plugin install x-pack'
# Run Kibana
sudo -u vagrant nohup bash -c 'bin/kibana' <&- &>/dev/null &
