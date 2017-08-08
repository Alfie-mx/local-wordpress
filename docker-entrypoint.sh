#!/usr/bin/env bash

set -ex



if ! [ -f /tmp/db-dump/*.sql ]; then
   runuser www-data -s /bin/sh -c "\
   wp search-replace \"${DB_SEARCH}\" \"${DB_REPLACE}\" \
   "
fi


exec "$@"