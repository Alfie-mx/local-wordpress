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

#if ! [ -f /tmp/db-dump/*.sql ]; then
#   runuser www-data -s /bin/sh -c "\
#   wp search-replace \"${DB_SEARCH}\" \"${DB_REPLACE}\" \
#   "
#fi


exec "$@"