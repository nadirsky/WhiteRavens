#!/bin/bash

Analize()
{
	list="Tmp/list"
	rm Sale.dat Prediction.dat PredictionTrash.dat PredictionToCheck.dat Plot/*.png PredictionCheck/*.png
	

	mysql --defaults-extra-file=./mysql.cnf white_ravens -N -e "SHOW TABLES LIKE '%book978%'" > $list

	#find Data/978*.dat > ISBN.list
	lines=$(wc -l < $list)
	i="0"

	while read line;
	do
	python analize.py $line	
	echo "scale=4; $i/$lines.0" | bc
	echo $line
	i=$(echo "$i+1" | bc) 
	done < $list

	sort -n prediction.dat2 > Prediction.dat
	sort -n predictionTrash.dat2 > PredictionTrash.dat
	sort -n predictionToCheck.dat2 > PredictionToCheck.dat
	sort -n Sale.dat2 > Sale.dat
	rm Sale.dat2 prediction.dat2 predictionTrash.dat2 predictionToCheck.dat2
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

#CopyToDatabase
Analize
