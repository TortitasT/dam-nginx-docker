#!/bin/sh

export TERM=xterm
echo q | htop | aha --black --line-fix > /usr/share/nginx/html/htop.html
