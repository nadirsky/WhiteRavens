import mysql.connector
import requests
import datetime
import feedparser
import string
from bs4 import BeautifulSoup, SoupStrainer
from multiprocessing.dummy import Pool as ThreadPool


def ThreadFunction(book):

	isbn = book[0]
	title = book[1]
	author = book[2]
	url = book[3]

	try:
		save_data_ceneo(get_data_ceneo(isbn, url))
	except:
		print(ValueError)
	#save_data_allegro(get_data_allegro(isbn, title, author))


def MakeList():

	cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
	cursor = cnx.cursor()
	query = "SELECT ISBN, Title, Author, Address FROM books"
	cursor.execute(query)

	book = []
	for (ISBN, Title, Author, Address) in cursor:
		book.append([ISBN, Title, Author, Address])

	cursor.close()
	cnx.close()

	return book


def Multithreading(threads):

	pool = ThreadPool(threads)
	pool.map(ThreadFunction, MakeList())
	pool.close()
	pool.join()


def quote(name):
	#q = "%26quot%3B"
	q = ""
	return q + name + q


def get_url(title, author):

	url_begin = "http://allegro.pl/rss.php/search?string="
	url_end = "&category=79153&selected_country=1&search_type=1&postcode_enabled=1"

	return url_begin + quote(title) + "+" + quote(author) + url_end


def convert_num(val):
	"""
	 - Remove all extra whitespace
	 - Replace comma with dot
	"""
	val = string.strip(val).replace(",", ".")
	return float(val)


def get_price(data):
	s = data.split("Kup Teraz: ")
	if len(s) > 1:
		return convert_num(s[1].split("z")[0])
	else:
		0


def get_data_allegro(isbn, title, author):
	title = title.replace(" ","+")
	author = author.replace(" ","+")

	d = feedparser.parse(get_url(title, author))

	offers = len(d.entries)
	if offers > 0:
		url, price = [], []
		for entry in d.entries:
			url.append(entry['link'])
			price.append(get_price(entry['summary_detail']['value']))

		print(get_url(title, author), title, author, isbn, offers, min(price), max(price))
		return isbn, offers, min(price), max(price)
	else:
		print(get_url(title, author), title, author, isbn, offers, 0, 0)
		return isbn, offers, 0, 0


def save_data_allegro(data):

	isbn, offers, min_price, max_price = data
	pass


def get_data_ceneo(isbn, url):
	result = requests.get(url)
	strainer = SoupStrainer('a')
	soup = BeautifulSoup(result.content, 'lxml', parse_only=strainer)

	summary = soup.find("a", {"class": "btn"})
	lowest_price = summary.get("data-lowestprice")
	offers = summary.get("data-offerscount")
	return isbn, offers, lowest_price


def save_data_ceneo(data):

	isbn, offers, lowest_price = data

	cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
	cursor = cnx.cursor()

	if str(offers) == "None":
		offers = 0
		lowest_price = 0

	query = (
		"INSERT INTO book" + isbn + " VALUES (" + GetDate() + "," + str(offers) + "," + str(lowest_price) + ");")
	cursor.execute(query)
	cnx.commit()
	print(query)

	cursor.close()
	cnx.close()


def GetDate():

	d = datetime.datetime.now()
	return str(d.year) + "," + str(d.month) + "," + str(d.day) + "," + str(d.hour) + "," + str(d.minute) + "," + str(
		d.second)


if __name__ == "__main__":

	Multithreading(32)
