#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Database setup - use Rails standard approach
echo "Setting up database for production..."

# This will create DB if needed, load schema if empty, or run migrations if schema exists
bundle exec rake db:prepare

echo "Database setup complete"