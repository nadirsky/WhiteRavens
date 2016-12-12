#!/bin/bash

Analize()
{
	list="Tmp/list"
	rm -f Results/Sale.dat Results/PredictionToCheck.dat Plot/*.png
	
	mysql --defaults-extra-file=./mysql.cnf white_ravens -N -e "SHOW TABLES LIKE '%book978%'" > $list

	python analize.py $list

	sort -t$'\t' -k5,5 -k1,1n Tmp/predictionToCheck.dat2 > Results/PredictionToCheck.dat
	sort -t$'\t' -k3,3 -k1,1n Tmp/Sale.dat2 > Results/Sale.dat
	rm -f Tmp/Sale.dat2 Tmp/predictionToCheck.dat2
}

ChangeSign()
{
    find Data/978*.alle > ISBN.list
    lines=$(wc -l < ISBN.list)
    i="0"

    while read line;
      do
	change=$(cat $line | awk '{gsub(/,/,".")} {print}')
	echo $change > $line
	echo "scale=4; $i/$lines.0" | bc
	echo $line
	i=$(echo "$i+1" | bc) 
      done < ISBN.list
}

CopyToDatabase()
{
    cd Data
    find 978*.dat > ../ISBN.list
    cd ..
    lines=$(wc -l < ISBN.list)
    i="0"

    while read line;
      do
	isbn=$(echo $line | awk '{gsub(/.dat/,"")} {print}')

	mysql --defaults-extra-file=./mysql.cnf white_ravens -e "CREATE TABLE IF NOT EXISTS book$isbn (Year int, Month int, Day int, Hour int, Minute int, Second int, Offers int, MinPrice float);"
	while read line2;
           do
		data=$(echo $line2 | awk '{print $1 "," $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8}')
		mysql --defaults-extra-file=./mysql.cnf white_ravens -e "INSERT INTO book$isbn VALUES ($data);"
	   done < Data/$line
	echo $isbn
	echo "scale=4; $i/$lines.0" | bc
	echo $line
	i=$(echo "$i+1" | bc) 
      done < ISBN.list
}

Clean()
{
column="Binding"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '</div', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<div>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<span>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '243;', 'o');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, 'borszurowa', 'broszurowa');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, 'oprawa', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, 'okladka', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = RTRIM($column);"
column="Title"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '</div', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<div>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<span>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '243;', 'o');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = RTRIM($column);"
column="Author"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '</div', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<div>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<span>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '243;', 'o');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = RTRIM($column);"
column="Publishing"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '</div', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<div>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<span>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '243;', 'o');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = RTRIM($column);"
column="Premiere"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '</div', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<div>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '<span>', '');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = REPLACE($column, '243;', 'o');"
mysql --defaults-extra-file=./mysql.cnf white_ravens -e "UPDATE books SET $column = RTRIM($column);"
}

#CopyToDatabase
Clean
Analize
