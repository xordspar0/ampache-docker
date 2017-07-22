#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

# Start apache in the background
service apache2 start

# Start cron in the background
cron

# Start a process to watch for changes in the library with inotify
while true; do
    inotifywatch /media
    php /var/www/bin/catalog_update.inc -a
    sleep 30
done
