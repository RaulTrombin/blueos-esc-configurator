FROM ubuntu:23.10
# FROM debian:stable-20240110-slim

# Node installation instructions:
# https://github.com/nodesource/distributions#installation-instructions
ENV NODE_MAJOR=16

ENV DEBIAN_FRONTEND="noninteractive"

# Default version to check out is master. Use --build-arg to customize this
ARG VERSION
ENV VERSION=${VERSION:-master}

# Install node, npm and a few utilities used for debugging
RUN apt-get update \
    && apt-get install -y ca-certificates gnupg sudo curl wget build-essential git vim nginx python3 xsel\
    && sudo mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list \
    && sudo apt-get update \
    && sudo apt-get install -y npm \
    && npm install -g yarn

# Build the app
RUN git clone https://github.com/stylesuxx/esc-configurator.git \
    && cd esc-configurator \
    && git checkout $VERSION \
    && yarn \
    && yarn global add serve \
    && yarn build

# Move our nginx configuration to the standard nginx path
COPY files/nginx.conf /etc/nginx/nginx.conf

# Add our static files to a common folder to be provided by nginx
RUN mkdir -p /site
COPY files/register_service /site/register_service

# Copy everything for your application
COPY files/entrypoint.sh /entrypoint.sh

RUN mkdir -p /home/workspace/.local

# CMD ["serve", "-s", "/esc-configurator/build", "-l", "1234"]

LABEL permissions='{\
  "NetworkMode": "host",\
  "HostConfig": {\
    "Privileged": true,\
    "Binds": [\
      "/usr/blueos/userdata/jupyter/root:/root:rw",\
      "/dev:/dev:rw"\
    ],\
    "Privileged": true,\
    "NetworkMode": "host"\
  }\
}'
LABEL authors='[\
  {\
    "name": "Raul Victor Trombin",\
    "email": "raulvtrombin@gmail.com"\
  }\
]'
LABEL company='{\
  "about": "",\
  "name": "Blue Robotics",\
  "email": "support@bluerobotics.com"\
}'
LABEL readme="https://raw.githubusercontent.com/patrickelectric/blueos-jupyter/master/README.md"
LABEL type="other"
LABEL tags='[\
  "python",\
  "ide",\
  "development"\
]'


RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/privkey.pem -out /etc/nginx/fullchain.pem -subj "/C=US/ST=California/L=Torrance/O=BlueRobotics/CN=bluerobotics.com"

ENTRYPOINT ["/entrypoint.sh"]