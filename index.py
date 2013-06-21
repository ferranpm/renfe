import web
import urllib2
import sqlite3
import json

RENFE_URL = "http://renfe.mobi"
RENFE_GET = "/renfev2/resultado_cercanias.do?"
RENFE_GET = '/renfev2/jsp/cercanias/HorarioCercanias.jsp?'
urls = (
    '/(.*)', 'hello',
    )

app = web.application(urls, globals())

def get_int(dict, s):
  if s in dict:
    i = dict[s]
    if i.isdigit():
      return int(i)

def get_horaris(nucleo, ciudad, origen, destino):
  # params = 'o=%s&d=%s&horario=&ho=00' % (origen, destino)
  get = 'nucleo=%s&ciudad=%s' % (nucleo, ciudad)
  p = urllib2.urlopen(RENFE_URL + RENFE_GET + get, params)
  return p.read()

class hello:
  def GET(self, name):
    user_data = web.input()
    o = get_int(user_data, 'o')
    d = get_int(user_data, 'd')
    
    if o and d:
      conn = sqlite3.connect('database')
      c = conn.cursor()
      c.execute('SELECT c.ciudad, c.nucleo, o.estacion, d.estacion FROM ciudad c, estacion o, estacion d WHERE c.nucleo=o.nucleo AND c.nucleo=d.nucleo AND o.id=%s AND d.id=%s' % (o, d))
      data = c.fetchone()
      if data:
        ciudad = data[0]
        nucleo = data[1]
        origen = o
        destino = d
        print ciudad, nucleo, origen, destino
        return get_horaris(nucleo, ciudad, origen, destino)

if __name__ == '__main__':
  app.run()

# import urllib, urllib2, sqlite3
# 
# conn = sqlite3.connect('database')
# ciudad = 'barcelona'
# nucleo = 50
# orig = 77104
# dest = 77003
# 
# url = "http://renfe.mobi"
# uri = "/renfev2/resultado_cercanias.do?nucleo=%s&ciudad=%s" % (nucleo, ciudad)
# 
# params = urllib.urlencode({'o': orig, 'd': dest, 'horario': "", 'ho': "00"})
# params = 'o=77104&d=77003&horario=&ho=00'
# 
# a = urllib2.urlopen(url+uri, params)
# print a.read()
# select * from ciudad c, estacion o, estacion d where c.ciudad='barcelona' and c.nucleo=o.nucleo and c.nucleo=d.nucleo and o.id=79608 and d.id=50703;
