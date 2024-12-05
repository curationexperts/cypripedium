#!/bin/sh
set -e

db_host=${DATABASE_HOST}
db_port=${POSTGRES_PORT}

while ! nc -z "$db_host" "$db_port"
do
  echo "waiting for postgresql"
  sleep 1
done

# always run migrations to keep the database up-to-date
bundle exec rails db:migrate

# Then exec the container's main process
# This is what's set as CMD in a) Dockerfile b) compose c) CI
exec "$@"
