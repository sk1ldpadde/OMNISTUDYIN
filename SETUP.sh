#!/bin/bash

# Building and starting docker-compose services
docker-compose build
docker-compose up

# Wait for the user to press a key before exiting
read -p "Press any key to continue... " -n1 -s
echo
