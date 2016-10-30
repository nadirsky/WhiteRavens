#!/bin/bash

GetBookInfo()
{
	title=$(grep -m 1 -E -o ".{0,0}<title>.{0,50}" $html | awk 'BEGIN{FS="-"} {print $1}' | awk 'BEGIN{FS=">"} {print $2}' | iconv -f utf-8 -t ascii//translit | sed 's/[!@#\$%^&*()'\'']//g')
	author=$(grep -m 1 -E -o ".{0,0}SublineTags\">.{0,50}" $html | awk 'BEGIN{FS=">"} {print $2}' | awk 'BEGIN{FS=","} {print $1}' | iconv -f utf-8 -t ascii//translit | sed 's/[!@#\$%^&*()'\'']//g')
	publishing=$(grep -m 1 -E -o ".{0,0}wydawnictwo: .{0,50}" $html | awk 'BEGIN{FS=": "} {print $2}' | awk 'BEGIN{FS="<"} {print $1}' | iconv -f utf-8 -t ascii//translit |sed 's/[!@#\$%^&*()'\'']//g')
	binding=$(grep -m 1 -E -o ".{0,0}oprawa.{0,20}" $html | awk 'BEGIN{FS=","} {print $1}'| awk 'BEGIN{FS=" "} {print $2}' | iconv -f utf-8 -t ascii//translit | sed 's/[!@#\$%^&*()'\'']//g')
	premiere=$(grep -m 1 -E -o ".{0,0}rok wydania.{0,8}" $html | awk 'BEGIN{FS=","} {print $1}' | awk 'BEGIN{FS=" "} {print $3}' | iconv -f utf-8 -t ascii//translit | sed 's/[!@#\$%^&*()'\'']//g')
	echo $isbn $title $author $publishing $binding $premiere $address

	#mysql --defaults-extra-file=./mysql.cnf white_ravens -e "CREATE TABLE IF NOT EXISTS books(ISBN varchar(13) NOT NULL,Title tinytext,Author tinytext,Publishing tinytext,Binding tinytext,Premiere tinytext,Address tinytext,PRIMARY KEY (ISBN));"
	mysql --defaults-extra-file=./mysql.cnf white_ravens -e "INSERT INTO books VALUES ($isbn, '$title', '$author', '$publishing', '$binding', '$premiere', '$address');"
}

GatheringData()
{
    database0="Ceneo/Publishing.dat"
    databaseCeneo="Ceneo/Ceneo.dat"
    database="Publishing.dat"
    databaseTmp="Tmp/temp"
    html="Tmp/html.dat"
    temp="Tmp/temp"
    cat Publishing/Mag.dat Publishing/Rebis.dat Publishing/Znak.dat Publishing/Zysk.dat Publishing/Publicat.dat Publishing/Literackie.dat Publishing/Olesiejuk.dat Publishing/Proszynski.dat Publishing/FabrykaSlow.dat Publishing/Solaris.dat Publishing/Vesper.dat | awk '{print $2}' > $databaseTmp
    cat $databaseTmp $databaseCeneo | sort -u > $database0


    lines0=$(wc -l < $database0)

    if [ ! -e ./$database ]; then
	cp $database0 $database
    fi

    lines=$(wc -l < $database)
    i="0"

    while read line;
      do
	#address=$(echo $line | awk '{print $2}') 
	address=$(echo $line)
	wget -q -O $html $address
        
	isbn=$(grep -m 1 -E -o ".{0,0}978.{0,10}" $html)
	#isbn=$(echo $line | awk '{print $1}')
	date=$(grep -m 1 -E -o ".{0,0}now: new Date.{0,25}" $html | awk 'BEGIN{FS="("} {print $2}' | awk 'BEGIN{FS=","} {print $1, $2, $3, $4, $5, $6}')
	date2=$(grep -m 1 -E -o ".{0,0}now: new Date.{0,25}" $html | awk 'BEGIN{FS="("} {print $2}' | awk 'BEGIN{FS=","} {print $1 "," $2 "," $3 "," $4 "," $5 "," $6}')		
	price=$(grep -m 1 -E -o ".{0,0}minPrice\",\".{0,6}" $html | awk 'BEGIN{FS="\""} {print $3}')
	offers=$(grep -m 1 -E -o ".{0,0}offersNo\",\".{0,3}" $html | awk 'BEGIN{FS="\""} {print $3}')
	#echo $date $offers $price >> Data/$isbn.dat

	#mysql --defaults-extra-file=./mysql.cnf white_ravens -e "CREATE TABLE IF NOT EXISTS book$isbn (Year int, Month int, Day int, Hour int, Minute int, Second int, Offers int, MinPrice float);"
	#mysql --defaults-extra-file=./mysql.cnf white_ravens -e "SELECT * FROM book$isbn ORDER BY Year, Month, Day, Hour, Minute, Second ASC;"
	mysql --defaults-extra-file=./mysql.cnf white_ravens -e "INSERT INTO book$isbn VALUES ($date2,$offers,$price);"

	GetBookInfo

	if [ ! -e ./Data/$isbn.allegro ]; then
		title=$(grep -m 1 -E -o ".{0,0}<title>.{0,50}" $html | awk 'BEGIN{FS="-"} {print $1}' | awk 'BEGIN{FS=">"} {print $2}' | awk '{gsub(/ /,"+")} {print}' )
		author=$(grep -m 1 -E -o ".{0,0}Autor: .{0,50}" $html | awk 'BEGIN{FS="\""} {print $1}' | awk 'BEGIN{FS=":"} {print $2}' | awk '{gsub(/ /,"+")} {print}')
        	echo "http://allegro.pl/ksiazki-i-komiksy?id=7&order=m&string="$title$author > Data/$isbn.allegro
	fi

	wget -q -O $html -i Data/$isbn.allegro
	priceAllegro=$(grep -E -o ".{0,7} zł.{0,0}" $html | awk '{gsub(/>/,"")} {gsub(/"/,"")} {print}' | awk 'NR == 1 || $1 < min {min = $1}END{print min}'| awk '{gsub(/,/,".")} {print}')
	offersAllegro=$(grep -m 1 -E -o ".{0,0}\"resultsNum\": .{0,4}" $html | awk '{print $2}' | awk 'BEGIN{FS=","} {print $1}')
	echo $date $offersAllegro $priceAllegro >> Data/$isbn.alle

	awk '$1 ~ /2016/' Data/$isbn.dat > $temp
	mv $temp Data/$isbn.dat

	awk 'NF>=8' Data/$isbn.alle > $temp
	mv $temp Data/$isbn.alle

        #echo "scale=4; $i/$lines.0" | bc
	echo $line
	i=$(echo "$i+1" | bc) 

	grep -v "$line" $database > $temp
	mv $temp $database
      done < $database

    if [ $(wc -l < $database) == 0 ]; then
	rm $database
    fi
}

GatheringData
