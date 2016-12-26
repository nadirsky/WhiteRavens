import sys
import math
from multiprocessing import Pool
from multiprocessing.dummy import Pool as ThreadPool
import numpy as np
import os.path
from pylab import *
from scipy import stats, polyfit
import mysql.connector


def Time(t1, t2, t3, t4, t5, t6):

    X = (t2 + 9.) / 12.
    A = 4716. + t1 + int(X)
    Y = 275. * t2 / 9.
    V = 7. * A / 4.
    B = 1729279.5 + 367. * t1 + int(Y) - int(V) + t3
    Q = (A + 83.) / 100.
    C = int(Q)
    W = 3. * (C + 1.) / 4.
    E = int(W)
    return B + 38. - E + t4 / 24. + t5 / 24. / 60. + t6 / 24. / 3600. - 2457600.0


def Average3(A):

    if (len(A) < 2):
        B = A
    else:
        B = []
        for i in range(0, len(A)):
            if (i == 0):
                B.append((A[i] + A[i] + A[i + 1]) / 3.)
            elif (i == len(A) - 1):
                B.append((A[i - 1] + A[i] + A[i]) / 3.)
            else:
                B.append((A[i - 1] + A[i] + A[i + 1]) / 3.)
    return B


def ChangeZero(A):

    price = 0.
    B = []
    for i in range(0, len(A)):
        if (A[i] != 0):
            price = A[i]
        B.append(price)
    return B


def AveragePrice(A):

    B = 0.
    for i in range(0, len(A)):
        B += A[i]
    return B / len(A)


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

    infoLine = ""
    info = []
    cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
    cursor = cnx.cursor()
    query = ("SELECT * FROM books WHERE ISBN =" + isbn)
    cursor.execute(query)

    for (ISBN, Title, Author, Publishing, Binding, Premiere, Address) in cursor:
        infoLine = ISBN + "\t" + Publishing + "\t" + Binding + "\t" + Title + "\t" + Author + "\t" + Premiere + "\t" + Address + "\n"
        info.append(ISBN)
        info.append(Publishing)
        info.append(Binding)
        info.append(Title)
        info.append(Author)
        info.append(Premiere)
        info.append(Address)

    cursor.close()
    cnx.close()
    return infoLine, info


def Prediction(t, n, p, isbn, infoLine, info):

    nP = []
    tP = []
    averagePrice = AveragePrice(p)
    prediction = []
    predictionMean = 0
    predictionResult = 0
    aP = 0
    bP = 0
    if (len(n) > 5 and averagePrice > 20):
        for j in range(0, len(n)):
            nP.append(n[j])
            tP.append(t[j])
            if (len(nP) > 4):
                aP, bP = polyfit(tP, nP, 1)
                if (aP < 0 and -bP / aP - t[len(t) - 1] < 90 and -bP / aP - t[len(t) - 1] > -50):
                    prediction.append(-bP / aP)

        if (len(prediction) > 0):
            for k in range(0, len(prediction)):
                predictionMean += prediction[k]
            predictionMean /= len(prediction)

            if (predictionMean < prediction[len(prediction) - 1]):
                predictionResult = predictionMean
            else:
                predictionResult = prediction[len(prediction) - 1]

            if (predictionResult < t[len(t) - 1] + 50 and n[len(n) - 1] > 0 and n[
                    len(n) - 1] <= 6 and averagePrice > 20 and info[2] != "miekka" and info[2] != "broszurowa"):
                plikPred = open("../Tmp/prediction.dat2", 'a')
                plikPred.writelines(
                    str(aP * 100000)[:7] + "\t" + str(predictionResult - t[len(t) - 1])[:3] + "\t" + str(
                        n[len(n) - 1]) + "\t" + infoLine)
                plikPred.close()

    return prediction, predictionMean, predictionResult, aP, bP


def Plot(data):

    t = data[0]
    n = data[1]
    p = data[2]
    prediction = data[3]
    predictionMean = data[4]
    predictionResult = data[5]
    aP = data[6]
    bP = data[7]
    nAverage3 = data[8]
    infoLine = data[9]

    nr = polyval([aP, bP], t)
    if (predictionMean != 0 and predictionMean < t[len(t) - 1] + 50 and n[len(n) - 1] <= 6):
        fig, ax1 = plt.subplots()
        plt.rc('text', usetex=True)

        ax1.plot(t, p, '-', linewidth=3.0, color="b", label=r'price')
        ax1.set_ylabel(r'Price', color='b')
        ax1.set_ylim(0, 100)
        for tl in ax1.get_yticklabels():
            tl.set_color('b')

        ax2 = ax1.twinx()
        ax2.plot(t, nAverage3, '-', linewidth=1.0, color="g", label=r'number')
        ax2.plot(t, nr, '-', linewidth=2.0, color="g", label=r'numberLine')
        ax2.plot(prediction, [0] * len(prediction), 'o', linewidth=1.0, color="r", label=r'')
        ax2.plot(predictionMean, [0], 'o', linewidth=1.0, color="g", label=r'')
        ax2.plot(predictionResult, [0], 'o', linewidth=1.0, color="b", label=r'')
        ax2.set_ylabel(r'Number', color='g')
        ax2.set_ylim(0, 40)
        for tl in ax2.get_yticklabels():
            tl.set_color('g')

        ax1.set_xlabel(r'$\mathrm{time [JD - JD_{0}]}$')
        plt.savefig("Plot/" + infoLine[:13] + '.png')
        plt.close(fig)


def Sale(n, p, infoLine):

    if (p[len(p) - 1] < 0.8 * p[len(p) - 2] and n[len(n) - 1] != 0):
        plik = open("../Tmp/Sale.dat2", 'a')
        plik.writelines(str(p[len(p) - 1] / p[len(p) - 2])[:4] + "\t" + infoLine)
        plik.close()


def ThreadFunction(isbn):

    t, n, p = ReadData(isbn)

    nAverage3 = Average3(n)
    infoLine, info = InfoLine(isbn)

    prediction, predictionMean, predictionResult, aP, bP = Prediction(t, n, p, isbn, infoLine, info)

    Sale(n, p, infoLine)
    return t, n, p, prediction, predictionMean, predictionResult, aP, bP, nAverage3, infoLine, isbn


def GetBookList():

    ISBN = []
    cnx = mysql.connector.connect(user='nadirsky', password='a', database='white_ravens')
    cursor = cnx.cursor()
    cursor.execute("SHOW TABLES LIKE '%book978%'")

    for table in cursor:
        ISBN.append(table[0].replace("book", ""))

    cursor.close()
    cnx.close()

    return ISBN


if __name__ == "__main__":
    PlotData = []
    pool = ThreadPool(12)
    PlotData = pool.map(ThreadFunction, GetBookList())
    pool.close()
    pool.join()

    for i in range(len(PlotData) - 1):
        Plot(PlotData[i])
