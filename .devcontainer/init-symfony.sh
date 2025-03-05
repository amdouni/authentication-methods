#!/bin/bash

# Ensure correct permissions
chmod -R 777 var/cache var/log var/sessions

# Start Symfony server
symfony server:start --dir=/workspace --daemon

echo "Symfony environment is ready!"
