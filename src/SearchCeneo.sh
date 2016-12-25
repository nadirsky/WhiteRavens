#!/bin/bash

CheckISBN()
{
	local is=$1
	local len=$(echo ${#is})
	local re='^[0-9]+$'
	if [[ $len == "13" && $1 =~ $re ]]; then
   		local odd=$(echo $1 | awk '{print substr($1,1,1) "+" substr($1,3,1) "+" substr($1,5,1) "+" substr($1,7,1) "+" substr($1,9,1) "+" substr($1,11,1)}' | bc)
		local even=$(echo $1 | awk '{print substr($1,2,1) "+" substr($1,4,1) "+" substr($1,6,1) "+" substr($1,8,1) "+" substr($1,10,1) "+" substr($1,12,1)}' | bc)
		local checkSum=$(echo "(10 - (($odd + 3*$even) % 10)) % 10" | bc)
		if [ $checkSum == $(echo $1 | awk '{print substr($1,13,1)}') ]; then
			echo "1"
		else
			echo "0"
		fi
	else
		echo "0"
	fi	
}

GetBookInfo()
{
	title=$(grep -m 1 -E -o ".{0,0}<title>.{0,50}" $html | awk 'BEGIN{FS="-"} {print tolower($1)}' | awk 'BEGIN{FS=">"} {print $2}' | iconv -f utf-8 -t ascii//translit | sed 's/[!@#\$%^&*()'\'']//g')
	author=$(grep -m 1 -E -o ".{0,0}SublineTags\">.{0,50}" $html | awk 'BEGIN{FS=">"} {print tolower($2)}' | awk 'BEGIN{FS=","} {print $1}' | iconv -f utf-8 -t ascii//translit | sed 's/[!@#\$%^&*()'\'']//g')
	publishing=$(grep -m 1 -E -o ".{0,0}wydawnictwo: .{0,50}" $html | awk 'BEGIN{FS=": "} {print tolower($2)}' | awk 'BEGIN{FS="<"} {print $1}' | iconv -f utf-8 -t ascii//translit |sed 's/[!@#\$%^&*()'\'']//g')
	binding=$(grep -m 1 -E -o ".{0,0}oprawa.{0,20}" $html | awk 'BEGIN{FS=","} {print tolower($1)}'| awk 'BEGIN{FS=" "} {print $2}' | iconv -f utf-8 -t ascii//translit | sed 's/[!@#\$%^&*()'\'']//g'|  awk '{print tolower($0)}')
	premiere=$(grep -m 1 -E -o ".{0,0}rok wydania.{0,11}" $html | awk 'BEGIN{FS=","} {print $1}' | awk 'BEGIN{FS=" "} {print $3}' | iconv -f utf-8 -t ascii//translit | sed 's/[!@#\$%^&*()'\'']//g')
	echo $isbn $title $author $publishing $binding $premiere $address

	#mysql --defaults-extra-file=./mysql.cnf white_ravens -e "CREATE TABLE IF NOT EXISTS books(ISBN varchar(13) NOT NULL,Title tinytext,Author tinytext,Publishing tinytext,Binding tinytext,Premiere tinytext,Address tinytext,PRIMARY KEY (ISBN));"
	mysql --defaults-extra-file=./mysql.cnf white_ravens -e "INSERT IGNORE INTO books VALUES ($isbn, '$title', '$author', '$publishing', '$binding', '$premiere', '$address');"
}

GatherBooksInfo()
{
	html="Tmp/html.dat"

	lines=$(wc -l < $ceneoNew)
	i="0"

	while read address;
	do
		wget -q -O $html $address
		
		isbn=$(grep -m 1 -E -o ".{0,0}978.{0,10}" $html)
		if [ $(CheckISBN $isbn) == "1" ]; then
			GetBookInfo
		fi

		echo "scale=4; $i/$lines.0" | bc
		i=$(echo "$i+1" | bc) 
	done < $ceneoNew
}


SearchInSection()
{
	maxPrice=52
	step=3

	for i in {0..52..3}
	do
		j=$(echo "$i+$step" | bc)
		for k in {0..99}
		do
			echo $i $k
			wget -q -O $html "http://www.ceneo.pl/$1;m$i;n$j;0020-30-0-0-$k;0112-0.htm"
			grep -E -o ".{0,0}  data-pid=.{0,15}" $html | awk 'BEGIN{FS="\""} {print "http://www.ceneo.pl/"$2}' >> $ceneo		
		done
	done
	
	for k in {0..99}
	do
		echo $k
		wget -q -O $html "http://www.ceneo.pl/$1;m$maxPrice;0020-30-0-0-$k;0112-0.htm"
		grep -E -o ".{0,0}  data-pid=.{0,15}" $html | awk 'BEGIN{FS="\""} {print "http://www.ceneo.pl/"$2}' >> $ceneo		
	done
}

SearchCeneo()
{
	html="Tmp/html2.dat"
	ceneo="Tmp/ceneo.dat"
	ceneo0="Ceneo/Ceneo.dat"
	ceneoNew="Tmp/ceneoNew.dat"

	rm $ceneo
	SearchInSection	"Fantastyka_i_fantasy"
	SearchInSection "Literatura_sensacyjna_i_grozy"
	SearchInSection "Powiesci_i_opowiadania"

	awk 'FNR==NR {a[$0]++; next} !a[$0]' $ceneo0 $ceneo > $ceneoNew
	cat $ceneo $ceneo0 | sort -u > $ceneo0

	GatherBooksInfo
}

SearchCeneo
