isbn=$1
address=$2
#html=$3

#wget -q -O $html $address
html=$(wget -qO- $address)

#sed 's/[!@#\$%^&*()'\'']//g'

date=$(echo "$html" | grep -m 1 -E ".{0,0}now: new Date.{0,25}" | awk 'BEGIN{FS="("} {print $2}' | awk 'BEGIN{FS=","} {print $1 "," $2 "," $3 "," $4 "," $5 "," $6}')		
price=$(echo "$html" | grep -m 1 -E ".{0,0}minPrice\",\".{0,6}" | awk 'BEGIN{FS="\""} {print $4}')
offers=$(echo "$html" | grep -m 1 -E ".{0,0}offers\",\"Value\":\".{0,3}" | awk 'BEGIN{FS="\""} {print $10}' | awk 'BEGIN{FS="\""} {print $1}')

mysql --defaults-extra-file=./mysql.cnf white_ravens -e "INSERT INTO book$isbn VALUES ($date,$offers,$price);"

echo "$isbn $date $offers $price"

#rm $html

