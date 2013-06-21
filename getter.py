import urllib, urllib2, sqlite3

conn = sqlite3.connect('database')
ciudad = 'barcelona'
nucleo = 50
orig = 77104
dest = 77003

orig = 78805
dest = 72301

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

a = urllib2.urlopen(url, params)
print a.read()
