#!/bin/bash

html="Tmp/html.dat"
adres="http://www.ceneo.pl/1514285"
wget -q -O $html $adres
        
isbn=$(grep -m 1 -E -o ".{0,0}978.{0,10}" $html)
date=$(grep -m 1 -E -o ".{0,0}now: new Date.{0,25}" $html | awk 'BEGIN{FS="("} {print $2}' | awk 'BEGIN{FS=","} {print $1 "," $2 "," $3 "," $4 "," $5 "," $6}')	
price=$(grep -m 1 -E -o ".{0,0}minPrice\",\".{0,6}" $html | awk 'BEGIN{FS="\""} {print $3}')
offers=$(grep -m 1 -E -o ".{0,0}offersNo\",\".{0,3}" $html | awk 'BEGIN{FS="\""} {print $3}')

echo $isbn, $date, $offers, $price

password="a"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "CREATE TABLE IF NOT EXISTS book$isbn (Year int, Month int, Day int, Hour int, Minute int, Second int, Offers int, MinPrice float);"

mysql --defaults-extra-file=./mysql.cnf white_ravens -e "INSERT INTO book$isbn VALUES ($date,$offers,$price);"




