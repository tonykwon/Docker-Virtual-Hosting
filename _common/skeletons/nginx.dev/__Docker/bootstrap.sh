#!/bin/sh

# we simply want to replace $DOCUMENT_ROOT with the env value set under environement of docker-compose.yml
sed -e 's,$DOCUMENT_ROOT,'"${DOCUMENT_ROOT}"',g' \
    -e 's,$VIRTUAL_HOST,'"${VIRTUAL_HOST}"',g'   \
    -e 's,$PHP_FPM,'"${PHP_FPM}"',g'             \
    /tmp/default.conf > /tmp/test.conf;

# because there is an issue with in-place replacement with sed (resource busy) hence this work around
cp -f /tmp/test.conf /etc/nginx/conf.d/default.conf; rm -f /tmp/test.conf;

nginx -g "daemon off;"