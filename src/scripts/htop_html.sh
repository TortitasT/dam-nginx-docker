#!/bin/sh

echo q | htop | aha --black --line-fix > /usr/share/nginx/html/htop.html
