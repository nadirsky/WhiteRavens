import sys
import math
import threading
from multiprocessing import Pool
from multiprocessing.dummy import Pool as ThreadPool
#import datetime 
import numpy as np
import os.path
from pylab import *
from scipy import stats,polyfit

import mysql.connector
#from mysql.connector import errorcode



def Time(t1,t2,t3,t4,t5,t6):
	X = (t2 + 9.) / 12.
	A = 4716. + t1 + int(X)
	Y = 275. * t2 / 9.
	V = 7. * A / 4.
	B = 1729279.5 + 367.*t1 + int(Y) - int(V) + t3
	Q = (A + 83.) / 100.
	C = int(Q)
	W = 3. * (C + 1.) / 4.
	E = int(W)
	return B + 38. - E + t4/24. + t5/24./60. + t6/24./3600. - 2457600.0

def Average3(A):
	if(len(A)<2):
		B = A
	else:
		B = []
		for i in range(0, len(A)):
			if(i == 0): 
				B.append((A[i]+A[i]+A[i+1])/3.)
			elif(i == len(A)-1):
				B.append((A[i-1]+A[i]+A[i])/3.)
			else:
				B.append((A[i-1]+A[i]+A[i+1])/3.)
	return B

def ChangeZero(A):
	price = 0.
	B = []
	for i in range(0, len(A)):
		if(A[i] != 0):
			price = A[i]
		B.append(price)
	return B

def ReadData(isbn):
	cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
	cursor = cnx.cursor()
	query = ("SELECT * FROM book" + isbn)
	cursor.execute(query)

	t = []
	n = []
	p = []
	p0 = []

	for (Year, Month, Day, Hour, Minute, Second, Offers, MinPrice) in cursor:
		t.append(Time(Year, Month, Day, Hour, Minute, Second))
		n.append(Offers)
		p0.append(MinPrice)

	cursor.close()
	cnx.close()

	p = ChangeZero(p0)

	return t, n, p

def InfoLine(isbn):
	cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
	cursor = cnx.cursor()
	query = ("SELECT * FROM books WHERE ISBN =" + isbn)
	cursor.execute(query)

	for (ISBN, Title, Author, Binding, Publishing, Premiere, Address) in cursor:
		infoLine = ISBN + "\t" + Title + "\t" + Author + "\t" + Publishing + "\t" + Binding + "\t" + Premiere + "\t" + Address + "\n"

	cursor.close()
	cnx.close()
	return infoLine

def AccuracyOfPrediction():
	nCheck = []
	tCheck = []
	quantity = []
	precision = []
	for i in range(0, len(n)):
		if(n[i] == 0 and len(n)>3):
			i0 = i
			for j in range(0, i0):
				nCheck.append(n[j])
				tCheck.append(t[j])
				if(len(nCheck)>2):
					aCheck,bCheck = polyfit(tCheck,nCheck,1)
					if(aCheck < -1.e-3):
						quantity.append(len(nCheck))
						precision.append(-bCheck/aCheck - t[i0])
			if(len(quantity) > 1):
				plt.clf()
				plt.subplot(111)
				ax = gca()
				ax.plot(quantity,precision,'-',linewidth=1.0,color="b",label=r'Precision')
				plt.title(inputfile)
				plt.rc('text', usetex=True)
				plt.xlabel(r'$\mathrm{Quantity}$')
				plt.ylabel(r'$\mathrm{Precision}$')
				plt.savefig("PredictionCheck/" + (inputfile.replace(".dat", "")).replace("Data/", "")+'PredictionCheck.png')
			break

def Prediction(t, n, p, isbn, infoLine):
	nP = []
	tP = []
	prediction = []
	predictionMean = 0
	predictionResult = 0
	aP = 0 
	bP = 0
	if(len(n) > 5 and p[len(p)-1] > 15):
		for j in range(0, len(n)):
			nP.append(n[j])
			tP.append(t[j])
			if(len(nP) > 4):
				aP,bP = polyfit(tP,nP,1)			
				if(aP < 0 and -bP/aP - t[len(t)-1] < 90 and -bP/aP - t[len(t)-1] > -50):
					prediction.append(-bP/aP)

		if(len(prediction) > 0):
			for k in range(0, len(prediction)):
				predictionMean += prediction[k]
			predictionMean /= len(prediction)

			if(predictionMean < prediction[len(prediction)-1]):
				predictionResult = predictionMean
			else:
				predictionResult = prediction[len(prediction)-1]

			if(predictionResult < t[len(t)-1] + 60 and n[len(n)-1] > 0 and n[len(n)-1] <= 6 and p[len(p)-1] > 15):
			

				checkedPath = "Checked/" + isbn
				try:
					checked = open(checkedPath, 'r')
					checkedValue = checked.readline()
					if(int(checkedValue) == 1):			
						plikPred = open("Tmp/prediction.dat2", 'a')
						plikPred.writelines(str(predictionResult-t[len(t)-1]) + " " + str(n[len(n)-1]) + " " +  infoLine)
						plikPred.close()
					elif(int(checkedValue) == 0):
						plikPred = open("Tmp/predictionTrash.dat2", 'a')
						plikPred.writelines(str(predictionResult-t[len(t)-1]) + " " + str(n[len(n)-1]) + " " + infoLine)
						plikPred.close()
				except:
					plikPred = open("Tmp/predictionToCheck.dat2", 'a')
					plikPred.writelines(str(predictionResult-t[len(t)-1]) + " " + str(n[len(n)-1]) + " " + infoLine)
					plikPred.close()
	return prediction, predictionMean, predictionResult, aP, bP

def Plot(t, n, p, prediction, predictionMean, predictionResult, aP, bP, nAverage3, infoLine, isbn):
	nr=polyval([aP,bP],t)
	if(predictionMean != 0 and predictionMean < t[len(t)-1] + 60 and n[len(n)-1] <= 10):
		#plt.clf()
		fig, ax1 = plt.subplots()
		plt.rc('text', usetex=True)

		ax1.plot(t,p,'-',linewidth=3.0,color="b",label=r'price')
		#ax1.plot(tA,pA,'.',linewidth=3.0,color="b",label=r'price')
		ax1.set_ylabel(r'Price', color='b')
		ax1.set_ylim(0,100)
		for tl in ax1.get_yticklabels():
	    		tl.set_color('b')
	
		ax2 = ax1.twinx()
		#ax2.plot(t,n,'.',linewidth=1.0,color="g",label=r'number')
		ax2.plot(t,nAverage3,'-',linewidth=1.0,color="g",label=r'number')
		#ax2.plot(tA,nA,'--',linewidth=1.0,color="g",label=r'number')
		ax2.plot(t,nr,'-',linewidth=2.0,color="g",label=r'numberLine')
		ax2.plot(prediction,[0]*len(prediction),'o',linewidth=1.0,color="r",label=r'')
		ax2.plot(predictionMean,[0],'o',linewidth=1.0,color="g",label=r'')
		ax2.plot(predictionResult,[0],'o',linewidth=1.0,color="b",label=r'')
		ax2.set_ylabel(r'Number', color='g')
		ax2.set_ylim(0,40)
		for tl in ax2.get_yticklabels():
	    		tl.set_color('g')

		plt.title(isbn)	
		ax1.set_xlabel(r'$\mathrm{time [JD - JD_{0}]}$')
		plt.savefig("Plot/" + isbn + '.png')
		plt.close(fig)

def Sale(n, p, infoLine): 
	if(p[len(p)-1]<0.8*p[len(p)-2] and n[len(n)-1] != 0):
		plik = open("Tmp/Sale.dat2", 'a')
		plik.writelines(str(p[len(p)-1]/p[len(p)-2]) + " " + infoLine)
		plik.close()

def ThreadFunction(isbn):
	print(isbn)
	t, n, p = ReadData(isbn)

	nAverage3 = Average3(n)
	infoLine = InfoLine(isbn)

	prediction, predictionMean, predictionResult, aP, bP = Prediction(t, n, p, isbn, infoLine)
	
	Plot(t, n, p, prediction, predictionMean, predictionResult, aP, bP, nAverage3, infoLine, isbn)
	Sale(n, p, infoLine)


f = open(sys.argv[1], 'r')
ISBN = []
for line in f:
	ISBN.append(line.replace("book", "")[:13])

pool = ThreadPool(8)
pool.map(ThreadFunction, ISBN)
pool.close() 
pool.join() 



