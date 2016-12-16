#!/usr/bin/env bash

# Create repository in origin
echo "Create snapshot repo..."
curl -XPUT -u elastic:changeme http://localhost:9200/_snapshot/my_backup -d '{"type": "fs", "settings": {"compress": "true", "location": "/vagrant/es_snapshots/my_backup"}}'

# Run snapshot
echo ""
echo ""
echo "Run snapshot..."
curl -XPUT -u elastic:changeme http://localhost:9200/_snapshot/my_backup/snapshot_1?wait_for_completion=true -d '{"indices": "+*,-.monitoring*", "include_global_state": true}'

echo ""
echo ""
echo "Reminder: Copy files from your /es_snapshots dir in this env to your new env before running restore"
