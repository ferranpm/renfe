import json
import os
import sqlite3
import time
import urllib
from bs4 import BeautifulSoup

DATABASE = os.path.dirname(os.path.abspath(__file__)) + '/database.db'

class Ciudad:
  def __init__(self, nucleo, nombre):
    self.nucleo = nucleo
    self.nombre = nombre

  def to_dict(self):
    return {
        'nucleo': self.nucleo,
        'nombre': self.nombre
        }

  @staticmethod
  def get_ciudades():
    connection = sqlite3.connect(DATABASE)
    cursor = connection.cursor()
    cursor.execute('SELECT nucleo, nombre FROM ciudades ORDER BY nombre ASC;')
    list = []
    for ciudad in cursor.fetchall():
      list.append(Ciudad(ciudad[0], str(ciudad[1])))
    connection.commit()
    connection.close()
    return list

class Estacion:
  def __init__(self, id, nombre, nucleo):
    self.nombre = nombre
    self.id = id
    self.nucleo = nucleo

  def to_dict(self):
    return {
        'id': self.id,
        'nombre': self.nombre
        }

  @staticmethod
  def get_estacion_by_nombre(nombre):
    connection = sqlite3.connect(DATABASE)
    cursor = connection.cursor()
    cursor.execute('SELECT id, nucleo, nombre FROM estaciones WHERE nombre="%s" COLLATE NOCASE' % str(nombre))
    e = cursor.fetchone()
    estacion = Estacion(e[0], e[2], e[1])
    connection.commit()
    connection.close()
    return estacion

  @staticmethod
  def get_estaciones(nucleo):
    connection = sqlite3.connect(DATABASE)
    cursor = connection.cursor()
    cursor.execute('SELECT id, nombre FROM estaciones WHERE nucleo=%s ORDER BY nombre ASC' % str(nucleo))
    list = []
    for estacion in cursor.fetchall():
      list.append(Estacion(estacion[0], estacion[1], nucleo))
    connection.commit()
    connection.close()
    return list
    
class Transbordo:
  def __init__(self, estacion, hl, hs):
    self.estacion = estacion
    self.hl = hl
    self.hs = hs

  def to_dict(self):
    return {
        'estacion': self.estacion.to_dict(),
        'hl': self.hl,
        'hs': self.hs
        }

class Trayecto:
  def __init__(self, linea, ho, hd, tiempo, transbordos=[]):
    self.linea = linea
    self.ho = ho
    self.hd = hd
    self.tiempo = tiempo
    self.transbordos = transbordos

  def anadir_transbordo(self, transbordo):
    self.transbordos.append(transbordo)

  def to_dict(self):
    return {
        'linea': self.linea,
        'ho': self.ho,
        'hd': self.hd,
        'tiempo': self.tiempo,
        'transbordos': [t.to_dict() for t in self.transbordos ]
        }

class Horario:
  def __init__(self, origen, destino, ho=00, hd=26, date=time.strftime("%Y%m%d")):
    self.origen = origen
    self.destino = destino
    self.ho = ho
    self.hd = hd
    self.date = date
    self.table = self.get_horario()

  def get_page(self):
    url = 'http://horarios.renfe.com/cer/hjcer310.jsp'
    params = urllib.urlencode({
      'f1': '',
      'i': 's',
      'cp': 'NO',
      'nucleo': self.origen.nucleo, # nucleo
      'o': self.origen.id, # estacion origen
      'd': self.destino.id, # estacion destino
      'df': self.date, # dia en formato yyyymmdd
      'ho': self.ho, # hora de origen
      'hd': self.hd, # hora de destino
      'TXTInfo': ''})
    p = urllib.urlopen(url, params)
    return p.read()

  def get_trs(self, table):
    trs = table.tr.td.find_all('tr') # devuelve un tr con muchos trs dentro
    return trs

  def get_tds(self, tr):
    tds = tr.find_all('td')
    return tds

  def hay_transbordo(self, list):
    return len(list[0]) > 5

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

  def parse_table_normal(self, list):
    list.pop(0)
    l = []
    for row in list:
      t = Trayecto(str(row[0]), str(row[1]), str(row[2]), str(row[3]))
      l.append(t)
    return l

  def parse_table_transbordo(self, list):
    parada_transbordo = Estacion.get_estacion_by_nombre(list[1][0])
    # Borramos las entradasa que no interesan
    list.pop(0)
    list.pop(0)
    list.pop(0)
    lista = []
    # para cada fila, miramos si es un transbordo, sino, ponemos el trayecto
    for row in list:
      # si es transbordo
      if row[0] == u'' and row[1] == u'' and row[2] == u'':
        print('in')
        transbordo = Transbordo(parada_transbordo, row[3], row[5])
        lista[-1].anadir_transbordo(transbordo)
      else:
        transbordo = Transbordo(parada_transbordo, row[2], row[3])
        trayecto = Trayecto(str(row[0]), str(row[1]), str(row[5]), str(row[6])) # TODO quitar el tiempo de los trayectos (depende de transbordo, also)
        trayecto.anadir_transbordo(transbordo)
        lista.append(trayecto)
      print(row)
      print([x.to_dict() for x in lista])
      print('')
      print('')
    return lista
  
  def parse_page(self, html):
    html = BeautifulSoup(html)
    table = BeautifulSoup(str(html.table))
    list = []
    list = self.parse_table(table)
    if self.hay_transbordo(list):
      list = self.parse_table_transbordo(list)
    else:
      list = self.parse_table_normal(list)
    return list

  def get_horario(self):
    nucleo = self.origen.nucleo
    oelcun = self.destino.nucleo
    if nucleo == oelcun:
      page = self.get_page()
      return self.parse_page(page)

  def to_dict(self):
    return {
        'origen': self.origen.to_dict(),
        'destino': self.destino.to_dict(),
        'horarios': [l.to_dict() for l in self.table]
        }
