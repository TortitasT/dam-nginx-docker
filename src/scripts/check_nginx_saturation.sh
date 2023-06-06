#!/bin/sh

active_users=$(curl -s http://localhost/nginx_status | awk '/Active connections: / {print $3}' | cut -d' ' -f1) # will get active users + 1

if [ $active_users -gt 2 ]; then
  touch /tmp/nginx_saturation
else
  rm -f /tmp/nginx_saturation
fi
