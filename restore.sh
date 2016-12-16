#!/usr/bin/env bash

# Create repository in origin
curl -XPUT -u elastic:changeme http://localhost:9200/_snapshot/my_backup -d '{"type": "fs", "settings": {"compress": "true", "location": "/vagrant/es_snapshots/my_backup"}}'

# Restore
curl -XPOST -u elastic:changeme http://localhost:9200/_snapshot/my_backup/snapshot_1/_restore -d '{"indices": "+*,-.monitoring*", "include_global_state": true}'
