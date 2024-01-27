#!/bin/bash

# turn on bash's job control
set -m
echo "Starting nginx.."
nginx &

echo "Starting our application.."
serve -s /esc-configurator/build -l 1234