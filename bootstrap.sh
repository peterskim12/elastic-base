#!/usr/bin/env bash

apt-get update
mkdir /opt/elastic
chown vagrant:vagrant /opt/elastic
cd /opt/elastic

# Install OpenJDK 8
apt-get -y -q update
apt-get -y -q install openjdk-8-jdk

# Download the Elastic product tarballs
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-beta2.tar.gz
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.0.0-beta2-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.0.0-beta2.tar.gz
wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-6.0.0-beta2-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-6.0.0-beta2-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.0.0-beta2-linux-x86_64.tar.gz

# Untar the bits
sudo -u vagrant bash -c 'for f in *.tar.gz; do tar xf $f; done'

# Allow all requests to Kibana
cat <<KIBANA_CONF >> /opt/elastic/kibana-6.0.0-beta2-linux-x86_64/config/kibana.yml
server.host: "0.0.0.0"
KIBANA_CONF

# Recommended ES settings to pass bootstrap checks
# START BOOTSTRAP CHECKS CONFIG CHANGES #
cat <<ES_CONF >> /opt/elastic/elasticsearch-6.0.0-beta2/config/elasticsearch.yml
http.host: [_local_, _enp0s8_]
path.repo: ["/vagrant/es_snapshots"]

bootstrap.memory_lock: true
discovery.zen.minimum_master_nodes: 1
ES_CONF

sysctl -w vm.max_map_count=262144
cat <<SYSCTL >> /etc/sysctl.conf
vm.max_map_count=262144
SYSCTL

ulimit -n 65536
ulimit -u 4096
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
vagrant           soft    nproc        4096
vagrant           hard    nproc        4096
vagrant           soft    as        unlimited
vagrant           hard    as        unlimited
root             soft    nofile         1024000
root             hard    nofile         1024000
root             soft    memlock        unlimited
root           soft    as        unlimited
root           hard    as        unlimited
SECLIMITS
# END BOOTSTRAP CHECKS CONFIG CHANGES #

cat <<LS_CONF >> /opt/elastic/logstash-6.0.0-beta2/config/logstash.yml
xpack.monitoring.enabled: true
xpack.management.enabled: true
xpack.management.elasticsearch.url: "http://localhost:9200/"
xpack.management.logstash.poll_interval: 5s
xpack.management.pipeline.id: ["apache"]
LS_CONF

# Install X-Pack in Elasticsearch
cd /opt/elastic/elasticsearch-6.0.0-beta2
sudo -u vagrant bash -c 'bin/elasticsearch-plugin install repository-s3 --batch'
sudo -u vagrant bash -c 'bin/elasticsearch-plugin install x-pack --batch'
# Run Elasticsearch
# sudo -u vagrant nohup bash -c 'bin/elasticsearch' <&- &>/dev/null &

# Install X-Pack in Kibana
cd /opt/elastic/kibana-6.0.0-beta2-linux-x86_64
sudo -u vagrant bash -c 'bin/kibana-plugin install x-pack'
# Run Kibana
# sudo -u vagrant nohup bash -c 'bin/kibana' <&- &>/dev/null &

# Install X-Pack in Logstash
cd /opt/elastic/logstash-6.0.0-beta2
sudo -u vagrant bash -c 'bin/logstash-plugin install x-pack'

# Run password setup
# Run Elasticsearch
cd /opt/elastic/elasticsearch-6.0.0-beta2
sudo -u vagrant nohup bash -c 'bin/elasticsearch' <&- &>/dev/null &

# Wait for Elasticsearch to startup
sleep 30

# Generate system user passwords
sudo -u vagrant bash -c 'bin/x-pack/setup-passwords auto --batch > /opt/elastic/passwords.txt'

# Write generated passwords to config files
elasticpwd=$(sed -n 's/PASSWORD elastic = \(.\+\)/\1/p' /opt/elastic/passwords.txt)
kibanapwd=$(sed -n 's/PASSWORD kibana = \(.\+\)/\1/p' /opt/elastic/passwords.txt)
logstashpwd=$(sed -n 's/PASSWORD logstash_system = \(.\+\)/\1/p' /opt/elastic/passwords.txt)

cat <<KIBANA_CONF >> /opt/elastic/kibana-6.0.0-beta2-linux-x86_64/config/kibana.yml
elasticsearch.username: kibana
elasticsearch.password: $kibanapwd
KIBANA_CONF

cat <<LS_CONF >> /opt/elastic/logstash-6.0.0-beta2/config/logstash.yml
xpack.monitoring.elasticsearch.username: logstash_system
xpack.monitoring.elasticsearch.password: $logstashpwd
xpack.management.elasticsearch.username: elastic
xpack.management.elasticsearch.password: $elasticpwd
LS_CONF
