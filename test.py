import urllib, urllib2, sqlite3

conn = sqlite3.connect('database')

url = 'http://horarios.renfe.com/cer/hjcer310.jsp'

params = urllib.urlencode({
  'f1': '',
  'i': 's',
  'cp': 'NO',
  'nucleo': 50, # nucleo
  'o': 79200, # estacion origen
  'd': 79500, # estacion destino
  'df': 20130619, # dia en formato yyyymmdd
  'ho': 00, # hora de origen
  'hd': 26, # hora de destino
  'TXTInfo': '',
  })

p = urllib2.urlopen(url, params)
content = p.read()

count = 0
index = 0
for c in content:
  if count < 40:
    index += 1
    if c == '\n':
      count+=1

content = content[index:-1]

from bs4 import BeautifulSoup

html = BeautifulSoup(content)
table = BeautifulSoup(str(html.table.td))
for tr in table.find_all('tr'):
  td = tr.find_all('td')
  linea = td[0].string
  ho = td[1].string
  hd = td[2].string
  tiempo = td[3].string
  print linea, ho, hd, tiempo
