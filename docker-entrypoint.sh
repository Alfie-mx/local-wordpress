#!/bin/bash

set -ex

ROOT_DIR=/var/www/html
WEB_USER=www-data

echo "==========================================================================="
echo ${ROOT_DIR}
echo ${WEB_USER}


# Create WordPress config.
if ! [ -f ${ROOT_DIR}/wp-config.php ]; then
  runuser ${WEB_USER} -s /bin/sh -c "\
  wp config create \
    --dbhost=\"${WORDPRESS_DB_HOST:-mysql}\" \
    --dbname=\"${WORDPRESS_DB_NAME:-wordpress}\" \
    --dbuser=\"${WORDPRESS_DB_USER:-root}\" \
    --dbpass=\"${WORDPRESS_DB_PASSWORD}\" \
    --skip-check \
    --extra-php <<PHP
${WORDPRESS_CONFIG_EXTRA}
PHP"
fi

# MySQL may not be ready when container starts.
set +ex
while true; do
  if curl --fail --show-error --silent "db:3306" > /dev/null 2>&1; then break; fi
  echo "Waiting for MySQL to be ready...."
  sleep 3
done
set -ex

# Install WordPress.
runuser ${WEB_USER} -s /bin/sh -c "\
wp core install
"

#runuser $WEB_USER -s /bin/sh -c "\
#wp core $([ "${WORDPRESS_INSTALL_TYPE}" == "multisite" ] && echo "multisite-install" || echo "install") \
#  --title=\"${WORDPRESS_SITE_TITLE:-Project}\" \
#  --admin_user=\"${WORDPRESS_SITE_USER:-wordpress}\" \
#  --admin_password=\"${WORDPRESS_SITE_PASSWORD:-wordpress}\" \
#  --admin_email=\"${WORDPRESS_SITE_EMAIL:-admin@example.com}\" \
#  --url=\"${WORDPRESS_SITE_URL:-http://project.dev}\" \
#  --skip-email"

#if [ -n "${DB_SEARCH}" ]; then
#runuser ${WEB_USER} -s /bin/sh -c "\
#wp search-replace \"${DB_SEARCH}\" \"${DB_REPLACE}\" \
# --allow-root \
#"
#fi

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


exec "$@"
