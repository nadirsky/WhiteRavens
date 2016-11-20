#!/bin/bash

isbn=$1
address=$2

html=$(wget -qO- $address)


date=$(echo "$html" | grep -m 1 -E ".{0,0}now: new Date.{0,25}" | awk 'BEGIN{FS="("} {print $2}' | awk 'BEGIN{FS=","} {print $1 "," $2 "," $3 "," $4 "," $5 "," $6}')
if [[ $date ]]; then		
	price=$(echo "$html" | grep -m 1 -E ".{0,0}minPrice\",\".{0,6}" | awk 'BEGIN{FS="\""} {print $4}')
	offers=$(echo "$html" | grep -m 1 -E ".{0,0}offers\",\"Value\":\".{0,3}" | awk 'BEGIN{FS="\""} {print $10}' | awk 'BEGIN{FS="\""} {print $1}')

	if [[ $price && $offers ]]; then
		#mysql --defaults-extra-file=./mysql.cnf white_ravens -e "SELECT * FROM book$isbn ORDER BY Year, Month, Day, Hour, Minute, Second ASC;"
		mysql --defaults-extra-file=./mysql.cnf white_ravens -e "INSERT INTO book$isbn VALUES ($date,$offers,$price);"
	fi
else
	echo "$isbn" >> noData
fi

echo "$isbn $date $offers $price"


