#!/bin/bash

Analize()
{
	rm -f Results/Sale.dat Results/Prediction.dat Plot/*.png
	
	python analize.py

	sort -t$'\t' -k5,5 -k1,1n Tmp/prediction.dat2 > Results/Prediction.dat
	sort -t$'\t' -k3,3 -k1,1n Tmp/Sale.dat2 > Results/Sale.dat
	rm -f Tmp/Sale.dat2 Tmp/prediction.dat2
}

Clean()
{
#mysql --defaults-extra-file=./mysql.cnf white_ravens -e "SELECT * FROM book$isbn ORDER BY Year, Month, Day, Hour, Minute, Second ASC;"
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

Clean
Analize
