#!/usr/bin/env bash

set -ex

ROOT_DIR=/var/www/html
WEB_USER=www-data


# Create WordPress config.
if ! [ -f $ROOT_DIR/wp-config.php ]; then
  runuser $WEB_USER -s /bin/sh -c "\
  wp config create \
    --dbhost=\"${WORDPRESS_DB_HOST:-mysql}\" \
    --dbname=\"${WORDPRESS_DB_NAME:-wordpress}\" \
    --dbuser=\"${WORDPRESS_DB_USER:-root}\" \
    --dbpass=\"$WORDPRESS_DB_PASSWORD\" \
    --skip-check \
    --extra-php <<PHP
$WORDPRESS_CONFIG_EXTRA
PHP"
fi

# Make sure uploads directory exists and is writeable.
mkdir -p $ROOT_DIR/wp-content/uploads
chown $WEB_USER:$WEB_USER $ROOT_DIR/wp-content
chown -R $WEB_USER:$WEB_USER $ROOT_DIR/wp-content/uploads

# MySQL may not be ready when container starts.
set +ex
while true; do
  if curl --fail --show-error --silent "${WORDPRESS_DB_HOST:-mysql}" > /dev/null 2>&1; then break; fi
  echo "Waiting for MySQL to be ready...."
  sleep 3
done
set -ex


# Search and Replace in DB to replace domain name.
#if [ -n \"${DB_SEARCH}\" ] && [ -n \"${DB_REPLACE}\" ]; then
   runuser $WEB_USER -s /bin/sh -c "\
   wp search-replace '\"${DB_SEARCH}\"' '\"${DB_REPLACE}\"' \
   "
#fi


exec "$@"