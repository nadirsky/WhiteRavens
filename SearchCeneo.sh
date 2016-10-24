#!/bin/bash


SearchCeneo()
{
    press="Publishing/Vesper"
    cp $press.isbn $press.isbn2 
    grep -E -o ".{0,0}978.{0,10}" $press.isbn2 > $press.isbn
    rm $press.isbn2
    lines=$(wc -l < $press.isbn)
    i="0"

    while read line;
      do
	wget -q -O html.dat2 "www.ceneo.pl/Ksiegarnia;szukaj-$line"
	
	adres=$(grep -m 1 -E -o ".{0,0}data-pid=.{0,15}" html.dat2 | awk 'BEGIN{FS="\""} {print "http://www.ceneo.pl/"$2}')	
        wget -q -O html.dat $adres      
	isbn=$(grep -m 1 -E -o ".{0,0}ISBN: .{0,13}" html.dat | awk '{print $2}')

        if [ "$line" = "$isbn" ]; then
		echo $line " = " $isbn
		echo -n $line " " >> $press.dat2
		echo $adres >> $press.dat2
	else
		echo $line " != " $isbn
	fi

	echo "scale=4; $i/$lines.0" | bc
	i=$(echo "$i+1" | bc) 
      done < $press.isbn
    sort -u $press.dat2 > $press.dat 
    rm $press.dat2
}

SearchCeneo
