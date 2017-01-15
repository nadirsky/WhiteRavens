import mysql.connector
import json
import requests
import string
from multiprocessing.dummy import Pool as ThreadPool


def Multithreading(threads):

	pool = ThreadPool(threads)
	pool.map(ThreadFunction, MakeList())
	pool.close()
	pool.join()


def ThreadFunction(isbn):

	try:
		get_library_data(isbn)
	except:
		print(ValueError)


def MakeList():

	cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
	cursor = cnx.cursor()
	query = "SELECT ISBN FROM books"
	cursor.execute(query)

	isbn_list = []
	for (ISBN,) in cursor:
		isbn_list.append(str(ISBN))

	cursor.close()
	cnx.close()

	return isbn_list


def ReadBooks():

	cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
	cursor = cnx.cursor()
	query = "SELECT ISBN FROM books_nl"
	cursor.execute(query)

	isbn_list = []
	for (ISBN,) in cursor:
		print(str(ISBN))

	cursor.close()
	cnx.close()


def get_library_data(isbn):

	url= u"http://data.bn.org.pl/api/bibs.json?isbnIssn=" + str(isbn)

	try:
		result = requests.get(url)
	except requests.exceptions.RequestException as e:  # This is the correct syntax
		print e

	data = json.loads(result.content)

	if len(data["bibs"]) > 0:
		title = string.strip(data["bibs"][0]["title"].split('/')[0])
		author = data["bibs"][0]["author"].split('(')[0]
		surname = string.strip(author.split(',')[0])
		name = string.strip((author.split(',')[1]).split('.')[0])
		publisher = (string.strip(data["bibs"][0]["publisher"].split(',')[0])).replace("Wydawnictwo ","")

		cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
		cursor = cnx.cursor()

		query = ("INSERT INTO books_nl (ISBN, title, name, surname, publishing) VALUES (\"" + str(isbn) + "\",\""+ str(title) + "\",\"" + str(name) + "\",\"" + str(surname) + "\",\"" + str(publisher) + "\");")
		cursor.execute(query)
		print(query)

		cursor.close()
		cnx.close()

	else:
		print(url)


if __name__ == "__main__":

	ReadBooks()
	#Multithreading(1) # server will refuse too many connections