#!/bin/bash

set -e
set -u
set -x

cd /opt

cp /runtime/bootstrap bootstrap
cp /runtime/bootstrap.php bootstrap.php

chmod 755 bin/*
chmod 755 bootstrap
chmod 755 bootstrap.php

#cp microsoft/msodbcsql17/lib64/libmsodbcsql-17.5.so.2.1 lib
#mkdir -p share
#cp vapor/msodbcsql/lib/* lib/
#cp -r vapor/msodbcsql/share/* share/
#cp -r vapor/msodbcsql/include/* include/

#cat <<EOF > odbcinst.ini
#[ODBC Driver 17 for SQL Server]
#Description=Microsoft ODBC Driver 17 for SQL Server
#Driver=/opt/lib/libmsodbcsql.17.dylib
#EOF

rm -rf vapor/

#cat <<EOF > odbcinst.ini
#[ODBC Driver 17 for SQL Server]
#Description=Microsoft ODBC Driver 17 for SQL Server
#Driver=/opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.5.so.2.1
#UsageCount=1
#EOF
#
#cat <<EOF > odbc.ini
#[ODBC Driver 17 for SQL Server]
#Driver = ODBC Driver 17 for SQL Server
#Description = My ODBC Driver 17 for SQL Server
#Trace = No
#EOF

mkdir -p vapor/etc/php/conf.d
cp /runtime/php.ini vapor/etc/php/conf.d/vapor.ini

ls -la

zip --quiet --recurse-paths /export/php-${PHP_SHORT_VERSION}.zip . --exclude "*php-cgi"
# zip --delete /export/php-${PHP_SHORT_VERSION}.zip vapor/sbin/php-fpm bin/php-fpm
