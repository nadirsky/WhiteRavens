import subprocess
import mysql.connector
from multiprocessing import Pool
from multiprocessing.dummy import Pool as ThreadPool

def ThreadFunction(bashCommand):
	subprocess.call(bashCommand, shell=True)

def MakeList():
	cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
	cursor = cnx.cursor()
	query = ("SELECT ISBN, Address FROM books")
	cursor.execute(query)

	bash = []
	for (ISBN, Address) in cursor:
		bashCommand = "./GatherData.sh " + ISBN + " " + Address
		bash.append(bashCommand)

	cursor.close()
	cnx.close()
	return bash

def Multithreading(threads):
	pool = ThreadPool(threads)
	pool.map(ThreadFunction, MakeList())
	pool.close() 
	pool.join() 

Multithreading(10)
