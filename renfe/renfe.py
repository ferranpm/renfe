import sqlite3
import time
import urllib
from bs4 import BeautifulSoup

class Renfe(object):
  def __init__(self):
    self.conn = sqlite3.connect('database')

  def get_ciudades(self):
    cursor = self.conn.cursor()
    cursor.execute('SELECT nucleo, ciudad FROM ciudades ORDER BY ciudad ASC')
    return cursor.fetchall()

  def get_estaciones(self, nucleo):
    cursor = self.conn.cursor()
    cursor.execute('SELECT id, estacion FROM estaciones WHERE nucleo=%s ORDER BY estacion ASC' % nucleo)
    return cursor.fetchall()

  def get_nucleo(self, estacion):
    cursor = self.conn.cursor()
    cursor.execute('SELECT c.nucleo FROM ciudades c, estaciones e WHERE c.nucleo=e.nucleo AND e.id=%s' % estacion)
    return cursor.fetchone()[0]

  def get_page(self, nucleo, orig, dest, date=time.strftime("%Y%m%d"), ho=00, hd=26):
    url = 'http://horarios.renfe.com/cer/hjcer310.jsp'
    params = urllib.urlencode({
      'f1': '',
      'i': 's',
      'cp': 'NO',
      'nucleo': nucleo, # nucleo
      'o': orig, # estacion origen
      'd': dest, # estacion destino
      'df': date, # dia en formato yyyymmdd
      'ho': ho, # hora de origen
      'hd': hd, # hora de destino
      'TXTInfo': ''})
    p = urllib.urlopen(url, params)
    return p.read()

  def parse_table(self, table):
    list = []
    trs = self.get_trs(table)
    for tr in trs:
      tds = self.get_tds(tr)
      obj = []
      for td in tds:
        td = td.string
        if td:
          td = td.strip()
        obj.append(td)
      list.append(obj)
    return list

  def get_trs(self, table):
    trs = table.tr.td.find_all('tr') # devuelve un tr con muchos trs dentro
    return trs

  def get_tds(self, tr):
    tds = tr.find_all('td')
    return tds

  def parse_table_transbordo(self, list):
    pass
    # Borramos las entradasa que no interesan
    # list.pop(0)
    # list.pop(0)
    # list.pop(0)
  
  def parse_table_normal(self, list):
    list.pop(0)

  def hay_transbordo(self, list):
    return len(list[0]) > 5

  def parse_page(self, html):
    html = BeautifulSoup(html)
    table = BeautifulSoup(str(html.table))
    list = []
    list = self.parse_table(table)
    if self.hay_transbordo(list):
      self.parse_table_transbordo(list)
    else:
      self.parse_table_normal(list)
    return list

  def get_horarios(self, orig, dest):
    nucleo = self.get_nucleo(orig)
    oelcun = self.get_nucleo(dest)
    if nucleo == oelcun:
      page = self.get_page(nucleo, orig, dest)
      return self.parse_page(page)



##################################################
# TEST
##################################################

if __name__ == '__main__':
  r = Renfe()
  ciudades = r.get_ciudades()
  i = 0
  for ciudad in ciudades:
    # print i, ciudad
    i += 1
  # n = int(input('Select Ciudad: '))
  n = 1
  estaciones = r.get_estaciones(ciudades[n][0])
  i = 0
  for estacion in estaciones:
    # print i, estacion
    i += 1
  # n = int(input('Select Origen: '))
  n = 96 # sanfe
  origen = estaciones[n][0]
  # n = int(input('Select Destino: '))
  # n = 97 # sant joan
  n = 0 # aeroport
  destino = estaciones[n][0]
  horarios = r.get_horarios(origen, destino)
  if horarios:
    for horario in horarios:
      print horarios.index(horario), horario
      pass
  else:
    print 'No he conseguido los horarios'
