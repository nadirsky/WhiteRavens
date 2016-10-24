#!/bin/bash

Analize()
{
    rm Sale.dat Prediction.dat PredictionTrash.dat PredictionToCheck.dat Plot/*.png PredictionCheck/*.png

    find Data/978*.dat > ISBN.list
    lines=$(wc -l < ISBN.list)
    i="0"

    while read line;
      do
	python analize.py $line	
	echo "scale=4; $i/$lines.0" | bc
	echo $line
	i=$(echo "$i+1" | bc) 
      done < ISBN.list

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

Analize
