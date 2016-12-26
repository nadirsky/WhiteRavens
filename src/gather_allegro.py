import feedparser
import string


def quote(name):

    return "%26quot%3B" + name + "%26quot%3B"


def url(title, author):

    url_begin = "http://allegro.pl/rss.php/search?string="
    url_end = "&category=79153&selected_country=1&search_type=1&postcode_enabled=1"

    return url_begin + quote(title) + quote(author) + url_end


def convert_num(val):
    """
     - Remove all extra whitespace
     - Replace comma with dot
    """
    val = string.strip(val).replace(",",".")
    return val


def get_price(data):
    return convert_num(data.split("Kup Teraz: ")[1].split("z")[0])

title = "Endymion"
author = "Simmons"


d = feedparser.parse(url(title,author))

offers = len(d.entries)
print len(d.entries)

for entry in d.entries:
    url = entry['link']
    price = get_price(entry['summary_detail']['value'])
    print url
    print price





"""
{'summary_detail':
     {'base': u'http://allegro.pl/rss.php/search?string=%26quot%3BEndymion%26quot%3B+%26quot%3BSimmons%26quot%3B&category=79153&selected_country=1&search_type=1&postcode_enabled=1',
      'type': u'text/html',
      'value': u'Sprzedaj\u0105cy: <a href="http://allegro.pl/show_user.php?uid=24859497">jan_gutenberg</a><br />\n'
               u'Cena Kup Teraz: 120,00 z\u0142<br />\n'
               u'Do ko\u0144ca: 9 dni (czw, 5 sty 2017, 12:25:26)<br />\n'
               u'<a href="http://allegro.pl/dan-simmons-endymion-i6658828261.html">Kup Teraz</a><br />\n'
               u'<a href="http://allegro.pl/rss.php/addToWatchList?item_id=6658828261">Dodaj do obserwowanych aukcji</a><br />\n'
               u'<img alt="" height="96" src="https://redir-img10.allegroimg.com/photos/128x96/66/58/82/82/6658828261" width="128" /><br />',
      'language': None},
 'published_parsed': time.struct_time(tm_year=2016, tm_mon=12, tm_mday=26, tm_hour=11, tm_min=25, tm_sec=26, tm_wday=0, tm_yday=361, tm_isdst=0),
 'links':
     [{'href': u'http://allegro.pl/dan-simmons-endymion-i6658828261.html', 'type': u'text/html', 'rel': u'alternate'}],
 'title': u'Dan Simmons - Endymion',
 'summary': u'Sprzedaj\u0105cy: <a href="http://allegro.pl/show_user.php?uid=24859497">jan_gutenberg</a><br />\n'
            u'Cena Kup Teraz: 120,00 z\u0142<br />\n'
            u'Do ko\u0144ca: 9 dni (czw, 5 sty 2017, 12:25:26)<br />\n'
            u'<a href="http://allegro.pl/dan-simmons-endymion-i6658828261.html">Kup Teraz</a><br />\n'
            u'<a href="http://allegro.pl/rss.php/addToWatchList?item_id=6658828261">Dodaj do obserwowanych aukcji</a><br />\n'
            u'<img alt="" height="96" src="https://redir-img10.allegroimg.com/photos/128x96/66/58/82/82/6658828261" width="128" /><br />',
 'guidislink': False,
 'title_detail':
     {'base': u'http://allegro.pl/rss.php/search?string=%26quot%3BEndymion%26quot%3B+%26quot%3BSimmons%26quot%3B&category=79153&selected_country=1&search_type=1&postcode_enabled=1',
      'type': u'text/plain',
      'value': u'Dan Simmons - Endymion',
      'language': None},
 'link': u'http://allegro.pl/dan-simmons-endymion-i6658828261.html',
 'published': u'Mon, 26 Dec 2016 12:25:26 +0100',
 'id': u'http://allegro.pl/dan-simmons-endymion-i6658828261.html'}
"""