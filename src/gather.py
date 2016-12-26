import mysql.connector
import requests
import datetime
from bs4 import BeautifulSoup
from multiprocessing.dummy import Pool as ThreadPool


def ThreadFunction(book):

    isbn = book[0]
    url = book[1]
    result = requests.get(url)

    soup = BeautifulSoup(result.content)

    summary = soup.find_all("a", {"class": "btn"})[0]
    lowest_price = summary.get("data-lowestprice")
    offers = summary.get("data-offerscount")
    SaveData(isbn, offers, lowest_price)


def MakeList():

    cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
    cursor = cnx.cursor()
    query = ("SELECT ISBN, Address FROM books")
    cursor.execute(query)

    book = []
    for (ISBN, Address) in cursor:
        book.append([ISBN, Address])

    cursor.close()
    cnx.close()

    return book


def Multithreading(threads):

    pool = ThreadPool(threads)
    pool.map(ThreadFunction, MakeList())
    pool.close()
    pool.join()


def SaveData(isbn, offers, lowest_price):

    cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
    cursor = cnx.cursor()

    if str(offers) == "None":
        offers = 0
        lowest_price = 0

    query = (
        "INSERT INTO book" + isbn + " VALUES (" + GetDate() + "," + str(offers) + "," + str(lowest_price) + ");")
    cursor.execute(query)
    print(query)

    cursor.close()
    cnx.close()


def GetDate():

    d = datetime.datetime.now()
    return str(d.year) + "," + str(d.month) + "," + str(d.day) + "," + str(d.hour) + "," + str(d.minute) + "," + str(
        d.second)


if __name__ == "__main__":

    Multithreading(8)