#!/bin/bash

path="/home/nadirsky/Desktop/Books"

mysqldump --defaults-extra-file=$path/src/mysql.cnf white_ravens --single-transaction > $path/white_ravens.sql
zip $path/white_ravens.sql.zip $path/white_ravens.sql

