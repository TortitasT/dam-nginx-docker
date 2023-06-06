#!/bin/sh

curl -s http://admin:secret@localhost/nginx_status | awk '/Active connections: / {print $3}' | cut -d' ' -f1 > /tmp/nginx_status
