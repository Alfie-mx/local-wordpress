#!/usr/bin/env bash

set -ex


## Seed wp-content directory if requested.
#if [ -d /tmp/wordpress/init-wp-content ]; then
#  tar cf - --one-file-system -C /tmp/wordpress/init-wp-content . | tar xf - -C ./wp-content --owner="$(id -u www-data)" --group="$(id -g www-data)"
#  echo "Seeded wp-content directory from /tmp/wordpress/init-wp-content."
#fi


# Update WP-CLI config with current virtual host.
sed -i -E "s#^url: .*#url: ${WORDPRESS_SITE_URL:-http://project.local}#" /etc/wp-cli/config.yml


# Create WordPress config.
if ! [ -f /var/www/html/wp-config.php ]; then
  runuser www-data -s /bin/sh -c "\
  wp config create \
    --dbhost=\"${WORDPRESS_DB_HOST:-mysql}\" \
    --dbname=\"${WORDPRESS_DB_NAME:-wordpress}\" \
    --dbprefix=\"${WORDPRESS_DB_PREFIX:-wp_}\" \
    --dbuser=\"${WORDPRESS_DB_USER:-root}\" \
    --dbpass=\"$WORDPRESS_DB_PASSWORD\" \
    --skip-check \
    --extra-php <<PHP
$WORDPRESS_CONFIG_EXTRA
PHP"
fi


if ! [ -f /tmp/db-dump/*.sql ]; then
   runuser www-data -s /bin/sh -c "\
   wp search-replace \"${DB_SEARCH}\" \"${DB_REPLACE}\" \
   "
fi

exec "$@"