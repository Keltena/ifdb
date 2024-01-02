#!/bin/bash -ex

#We're not auto-detecting DB updates because if we do any schema changes in production, we'll have to remove them from patch-schema.sql when we download the updated archive, months later
#FILENAME=`curl --silent https://ifarchive.org/if-archive/info/ifdb/ | grep --only-matching "ifdb-archive-\d*.zip" | tail -1`
FILENAME=ifdb-archive-20231201.zip
if [ ! -f sql/$FILENAME ]; then
    curl -o sql/$FILENAME https://ifarchive.org/if-archive/info/ifdb/$FILENAME
fi
unzip -o sql/$FILENAME

rm -rf initdb
mkdir initdb
cat sql/create-db.sql ifdb-archive.sql > initdb/00-init.sql
cp sql/patch-schema.sql initdb/01-patch-schema.sql
cp sql/create-admin.sql initdb/02-create-admin.sql
cp sql/create-test-user.sql initdb/03-create-test-user.sql
cp sql/patch-schema-2.sql initdb/04-patch-schema-2.sql

sed 's/"127.0.0.1", "username", "password"/"db", "root", "secret"/' local-credentials.php.template > www/local-credentials.php
