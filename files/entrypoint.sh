#!/bin/bash

# turn on bash's job control
set -m
read NGINX_PORT JUPYTER_PORT <<< $(python3 -c 'import socket; s1=socket.socket(); s1.bind(("", 0)); s2=socket.socket(); s2.bind(("", 0)); print(str(s1.getsockname()[1]) + " " + str(s2.getsockname()[1])); s1.close(); s2.close()')
echo "Free ports: $NGINX_PORT $JUPYTER_PORT"
sed -i "s/NGINX_PORT/$NGINX_PORT/g; s/JUPYTER_PORT/$JUPYTER_PORT/g" /etc/nginx/nginx.conf
echo "Starting nginx.."
nginx &

echo "Starting our application.."
serve -s /esc-configurator/build -l $JUPYTER_PORT