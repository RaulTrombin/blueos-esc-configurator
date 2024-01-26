# blueos-esc-configurator

instructions:
docker buildx build --progress plain --no-cache --platform linux/arm/v7 . -t raulelektron/blueos_esc-configurator_test:latest --output type=registry

BlueOS custom settings:
{
  "ExposedPorts": {
    "80/tcp": {}
  },
  "HostConfig": {
    "Privileged": true,
    "Binds": [
      "/usr/blueos/userdata/node-red:/data:rw",
      "/etc/hostname:/etc/hostname:ro",
      "/dev:/dev:rw",
      "/:/home/workspace/host:rw"
    ],
    "PortBindings": {
      "80/tcp": [
        {
          "HostPort": ""
        }
      ]
    }
  }
}