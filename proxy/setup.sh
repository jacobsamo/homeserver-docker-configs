#!/bin/bash

# Rename env file
rn .env.example .env

# Setup the acme.json file
chmod 600 /config/acme.json

# Create the docker proxy network
docker network create proxy