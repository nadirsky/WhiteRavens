#!/bin/bash


GatheringData()
{
    database0="Publishing/Publishing.dat"
    database="Publishing.dat"
    html="Tmp/html.dat"
    temp="Tmp/temp"
    cat Publishing/Mag.dat Publishing/Rebis.dat Publishing/Znak.dat Publishing/Zysk.dat Publishing/Publicat.dat Publishing/Literackie.dat Publishing/Olesiejuk.dat Publishing/Proszynski.dat Publishing/FabrykaSlow.dat Publishing/Solaris.dat Publishing/Vesper.dat > $database0

    lines0=$(wc -l < $database0)

    if [ ! -e ./$database ]; then
	cp $database0 $database
    fi

    lines=$(wc -l < $database)
    i="0"

    while read line;
      do
	adres=$(echo $line | awk '{print $2}') 
	wget -q -O $html $adres
        
	isbn=$(grep -m 1 -E -o ".{0,0}ISBN: .{0,13}" $html | awk '{print $2}')
	date=$(grep -m 1 -E -o ".{0,0}now: new Date.{0,25}" $html | awk 'BEGIN{FS="("} {print $2}' | awk 'BEGIN{FS=","} {print $1, $2, $3, $4, $5, $6}')	
	price=$(grep -m 1 -E -o ".{0,0}\"LowestPrice\".{0,6}" $html | awk 'BEGIN{FS=":"} {print $2}' | awk '{sub(",", ""); print}')
	offers=$(grep -m 1 -E -o ".{0,0}\"OffersCount\".{0,4}" $html | awk '{sub(":", " "); sub(",", " "); print $2}')
	echo $date $offers $price >> Data/$isbn.dat

	if [ ! -e ./Data/$isbn.info ]; then
		title=$(grep -m 1 -E -o ".{0,0}<title>.{0,50}" $html | awk 'BEGIN{FS="-"} {print $1}' | awk 'BEGIN{FS=">"} {print ";", $2, ";"}')
		author=$(grep -m 1 -E -o ".{0,0}Autor: .{0,50}" $html | awk 'BEGIN{FS="\""} {print $1}' | awk 'BEGIN{FS=":"} {print $2, ";"}')
		publishing=$(grep -m 1 -E -o ".{0,0}Wydawnictwo: .{0,50}" $html | awk 'BEGIN{FS="\""} {print $1}' | awk 'BEGIN{FS=":"} {print $2, ";"}')
		binding=$(grep -m 1 -E -o ".{0,0}, oprawa.{0,20}" html.dat | awk 'BEGIN{FS=","} {print $2, ";"}')
		premiere=$(grep -m 1 -E -o ".{0,0}Created.{0,10}" $html | awk 'BEGIN{FS=":"} {print $2}' | awk 'BEGIN{FS=","} {print $1}')
        	echo $isbn $adres $title $author $publishing $binding $premiere > Data/$isbn.info
	fi

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

        echo "scale=4; $i/$lines.0" | bc
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
