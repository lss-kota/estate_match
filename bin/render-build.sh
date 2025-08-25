#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Database setup for first deploy
if ! bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')" 2>/dev/null; then
  echo "Database not accessible, creating..."
  bundle exec rake db:create
fi

# Check if database is empty and load schema if needed
if ! bundle exec rails runner "User.first" 2>/dev/null; then
  echo "Database appears empty, loading schema..."
  bundle exec rake db:schema:load
fi

# Run any pending migrations
bundle exec rake db:migrate