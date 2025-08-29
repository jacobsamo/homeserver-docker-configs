#!/bin/bash

echo "Setting up Traefik with Cloudflare configuration..."

# Rename env file
if [ -f .env.example ]; then
    mv .env.example .env
    echo "✓ Created .env file from .env.example"
else
    echo "⚠ .env.example not found"
fi

# Setup the acme.json file
chmod 600 config/acme.json
echo "✓ Created and secured acme.json file"

# Create the docker proxy network
if ! docker network ls | grep -q "proxy"; then
    docker network create proxy
    echo "✓ Created proxy network"
else
    echo "✓ Proxy network already exists"
fi

# Check if required files exist
echo ""
echo "Checking required configuration files..."

if [ ! -f cf_api_token.txt ]; then
    echo "❌ cf_api_token.txt is missing"
    echo "   Please add your Cloudflare API token to this file"
    MISSING_FILES=true
fi

if [ ! -f cf_tunnel_token.txt ]; then
    echo "❌ cf_tunnel_token.txt is missing" 
    echo "   Please add your Cloudflare tunnel token to this file"
    MISSING_FILES=true
fi

if [ ! -f config/traefik.yml ]; then
    echo "❌ config/traefik.yml is missing"
    echo "   Please ensure the traefik configuration file exists"
    MISSING_FILES=true
fi

# Check .env file content
if [ -f .env ]; then
    if ! grep -q "TRAEFIK_DASHBOARD_CREDENTIALS=" .env || [ -z "$(grep "TRAEFIK_DASHBOARD_CREDENTIALS=" .env | cut -d'=' -f2)" ]; then
        echo "❌ TRAEFIK_DASHBOARD_CREDENTIALS not set in .env"
        echo "   Generate credentials with: echo \$(htpasswd -nB user) | sed -e s/\\$/\\$\\$/g"
        MISSING_FILES=true
    fi
fi

if [ "$MISSING_FILES" = true ]; then
    echo ""
    echo "❌ Setup incomplete - please address the missing files above"
    exit 1
else
    echo ""
    echo "✓ All configuration files present"
    echo "✓ Setup complete! You can now run: docker-compose up -d"
fi