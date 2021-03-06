#!/bin/bash

# Get current host name
setup_file=$(hostname)
setup_file=cfg/$setup_file".sh"

# Execute configuration file
echo "Looking for $setup_file ..."
if [ -f $setup_file ]; then
  echo "Configuration file exists!"
  ./$setup_file
  exit 0
else
  echo "Configuration file does not exist!"
  exit 1
fi
