#!/bin/bash

path="/home/nadirsky/Desktop/Books"

mysqldump --defaults-extra-file=$path/mysql.cnf white_ravens --single-transaction > $path/white_ravens.sql
zip white_ravens.sql.zip white_ravens.sql
#cd $path
#git add white_ravens.sql
