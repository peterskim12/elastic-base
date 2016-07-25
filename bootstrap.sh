#!/usr/bin/env bash

apt-get update
mkdir /opt/elastic
chown vagrant:vagrant /opt/elastic
cd /opt/elastic

add-apt-repository -y ppa:webupd8team/java
apt-get -y -q update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y -q install oracle-java8-installer
update-java-alternatives -s java-8-oracle

wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/5.0.0-alpha4/elasticsearch-5.0.0-alpha4.tar.gz
wget https://download.elastic.co/kibana/kibana/kibana-5.0.0-alpha4-linux-x64.tar.gz
wget https://download.elastic.co/logstash/logstash/logstash-5.0.0-alpha4.tar.gz
wget https://download.elastic.co/beats/metricbeat/metricbeat-5.0.0-alpha4-linux-x86_64.tar.gz
wget https://download.elastic.co/beats/packetbeat/packetbeat-5.0.0-alpha4-linux-x86_64.tar.gz
wget https://download.elastic.co/beats/filebeat/filebeat-5.0.0-alpha4-linux-x86_64.tar.gz


sudo -u vagrant bash -c 'for f in *.tar.gz; do tar xf $f; done'

# Disable shield
cat <<ES_CONF > /opt/elastic/elasticsearch-5.0.0-alpha4/config/elasticsearch.yml
xpack.security.enabled: false
ES_CONF
cat <<KIBANA_CONF > /opt/elastic/kibana-5.0.0-alpha4-linux-x64/config/kibana.yml
xpack.security.enabled: false
KIBANA_CONF

cd /opt/elastic/elasticsearch-5.0.0-alpha4
sudo -u vagrant bash -c 'bin/elasticsearch-plugin install x-pack'
sudo -u vagrant nohup bash -c 'bin/elasticsearch' <&- &>/dev/null &

cd /opt/elastic/kibana-5.0.0-alpha4-linux-x64
sudo -u vagrant bash -c 'bin/kibana-plugin install x-pack'
sudo -u vagrant nohup bash -c 'bin/kibana' <&- &>/dev/null &

# Recommended ES network settings
# cat <<ES_CONF > /opt/elastic/elasticsearch-5.0.0-alpha4/config/elasticsearch.yml
# network.host: [_local_, _eth0_]
#
# bootstrap.memory_lock: true
# discovery.zen.minimum_master_nodes: 1
# ES_CONF
