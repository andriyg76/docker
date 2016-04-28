#!/bin/sh

# Verify TOKEN is provided
if [ -z "$TOKEN" ]; then
  echo "Env variable TOKEN needs to be defined"
  exit 1
fi

# Verify HOST is provided
if [ -z "$NODE_HOSTNAME" ]; then
  echo "Env variable NODE_HOSTNAME needs to be defined"
  exit 1
fi

exec fluentd -c /fluentd/etc/fluent.conf -p /fluentd/plugins
