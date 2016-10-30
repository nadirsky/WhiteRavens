import sys
import mysql.connector
from mysql.connector import errorcode

#inputfile = sys.argv[1]
#isbn = (inputfile.replace(".dat", "")).replace("Data/", "")


cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
cursor = cnx.cursor()
#query = ("SELECT * FROM book" + isbn)
query = ("SHOW TABLES LIKE \'%book978%\'")
cursor.execute(query)

print(cursor.result)
#for result in cursor:
#	print(result)

cursor.close()
cnx.close()
