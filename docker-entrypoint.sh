#!/bin/bash

set -ex

ROOT_DIR=/var/www/html
WEB_USER=www-data

echo "==========================================================================="
echo ${ROOT_USER}
echo ${WEB_USER}

# MySQL may not be ready when container starts.
set +ex
while true; do
  if curl --fail --show-error --silent "db:3306" > /dev/null 2>&1; then break; fi
  echo "Waiting for MySQL to be ready...."
  sleep 3
done
set -ex

runuser ${WEB_USER} -s /bin/sh -c "\
wp search-replace \"http://dev.parkroyal.drivedigitaldev.com\" \"http://alfredo-test.local:9000\" \
 --allow-root \
"

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


exec "$@"
