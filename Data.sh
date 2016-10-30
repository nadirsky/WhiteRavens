#!/bin/bash

html="Tmp/html.dat"
address="http://www.ceneo.pl/1514285"
wget -q -O $html $address

        
isbn=$(grep -m 1 -E -o ".{0,0}978.{0,10}" $html)

#date=$(grep -m 1 -E -o ".{0,0}now: new Date.{0,25}" $html | awk 'BEGIN{FS="("} {print $2}' | awk 'BEGIN{FS=","} {print $1 "," $2 "," $3 "," $4 "," $5 "," $6}')	
#price=$(grep -m 1 -E -o ".{0,0}minPrice\",\".{0,6}" $html | awk 'BEGIN{FS="\""} {print $3}')
#offers=$(grep -m 1 -E -o ".{0,0}offersNo\",\".{0,3}" $html | awk 'BEGIN{FS="\""} {print $3}')
#echo $isbn, $date, $offers, $price

#mysql --defaults-extra-file=./mysql.cnf white_ravens -e "CREATE TABLE IF NOT EXISTS book$isbn (Year int, Month int, Day int, Hour int, Minute int, Second int, Offers int, MinPrice float);"
#mysql --defaults-extra-file=./mysql.cnf white_ravens -e "INSERT INTO book$isbn VALUES ($date,$offers,$price);" """


ISBN=$(grep -m 1 -E -o ".{0,0}978.{0,10}" $html)
title=$(grep -m 1 -E -o ".{0,0}<title>.{0,50}" $html | awk 'BEGIN{FS="-"} {print $1}' | awk 'BEGIN{FS=">"} {print $2}')
author=$(grep -m 1 -E -o ".{0,0}SublineTags\">.{0,50}" $html | awk 'BEGIN{FS=">"} {print $2}' | awk 'BEGIN{FS=","} {print $1}')
publishing=$(grep -m 1 -E -o ".{0,0}wydawnictwo: .{0,50}" $html | awk 'BEGIN{FS=": "} {print $2}' | awk 'BEGIN{FS="<"} {print $1}')
binding=$(grep -m 1 -E -o ".{0,0}oprawa.{0,20}" $html | awk 'BEGIN{FS=","} {print $1}'| awk 'BEGIN{FS=" "} {print $2}')
premiere=$(grep -m 1 -E -o ".{0,0}rok wydania.{0,8}" $html | awk 'BEGIN{FS=","} {print $1}' | awk 'BEGIN{FS=" "} {print $3}')
echo $ISBN $title $author $publishing $binding $premiere $address

mysql --defaults-extra-file=./mysql.cnf white_ravens -e "CREATE TABLE IF NOT EXISTS books(ISBN int NOT NULL,Title varchar(80),Author varchar(50),Publishing varchar(50),Binding varchar(30),Premiere int,Address varchar(200),PRIMARY KEY (ISBN));"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "INSERT INTO books VALUES ($ISBN, $title, $author, $publishing, $binding, $premiere, $address);"




