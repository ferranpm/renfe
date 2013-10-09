import os
import sqlite3
import time
import urllib
from bs4 import BeautifulSoup

DATABASE = os.path.dirname(os.path.abspath(__file__)) + '/database'

class Nucleo:
	def __init__(self, nucleo_id, nombre):
		self.nucleo_id = nucleo_id
		self.nombre = nombre

	def to_dict(self):
		return {
				'id': self.nucleo_id,
				'nombre': self.nombre
				}

	@staticmethod
	def get_by_id(nucleo_id):
		connection = sqlite3.connect(DATABASE)
		cursor = connection.cursor()
		cursor.execute("""
			SELECT nombre
			FROM nucleos
			WHERE id=%s;
			""" % str(self.nucleo_id))
		nombre = cursor.fetchone()
		connection.close()
		return Nucleo(nucleo_id, nombre)

	@staticmethod
	def get_nucleos():
		connection = sqlite3.connect(DATABASE)
		cursor = connection.cursor()
		cursor.execute("""
			SELECT id, nombre
			FROM nucleos
			ORDER BY nombre ASC;
			""")
		l = [Nucleo(nucleo[0], str(nucleo[1])) for nucleo in cursor.fetchall()]
		connection.close()
		return l

class Estacion:
	def __init__(self, estacion_id, nombre):
		self.nombre = nombre
		self.estacion_id = estacion_id

	def get_nucleo(self):
		connection = sqlite3.connect(DATABASE)
		cursor = connection.cursor()
		cursor.execute("""
			SELECT n.nombre, n.id
			FROM nucleos n, estaciones e
			WHERE e.id=%s AND e.nucleo_id=n.id;
			""" % str(self.estacion_id))
		nombre, nucleo_id = cursor.fetchone()
		connection.close()
		return Nucleo(nucleo_id, nombre)

	def to_dict(self):
		return {
				'id': self.estacion_id,
				'nombre': self.nombre
				}

	@staticmethod
	def get_by_id(id):
		connection = sqlite3.connect(DATABASE)
		cursor = connection.cursor()
		cursor.exe_cute("""
			SELECT nombre
			FROM estaciones
			WHERE id=%s;
			""" % str(nucleo))
		nombre = cursor.fetchone()
		connection.close()
		return Estacion(id, nombre)

	@staticmethod
	def get_estaciones(nucleo):
		connection = sqlite3.connect(DATABASE)
		cursor = connection.cursor()
		cursor.execute("""
			SELECT id, nombre
			FROM estaciones
			WHERE nucleo_id=%s
			ORDER BY nombre ASC;
			""" % str(nucleo.nucleo_id))
		l = [Estacion(estacion[0], estacion[1]) for estacion in cursor.fetchall()]
		connection.close()
		return l

class Horario(object):
	def __init__(self, origen, destino, ho=00, hd=26, date=time.strftime('%Y%m%d')):
		"""
		Genera la clase horario con el horario entre las *Estaciones* *origen* y *destino*
		entre las horas *ho* y *hd* en la fecha *date*.

		origen: Estacion de origen
		destino: Estacion de destino
		ho: hora de origen (00-26)
		ho: hora de destino (00-26) (> ho)
		date: fecha en formato yyyymmdd
		"""
		self.origen = origen
		self.destino = destino
		self.ho = ho
		self.hd = hd
		self.date = date

		page = self.__get_page()
		soup = BeautifulSoup(page)
		table = self.__get_table(soup)

		self.__set_es_transbordo(table)

		if self.es_transbordo():
			self.__parse_transbordo(table)
		else:
			self.__parse_no_transbordo(table)

	def es_transbordo(self):
		return self.transbordo

	def __get_page(self):
		"""
		Obtiene la pagina en la que esta la tabla de horarios en funcion de 
		los datos puestos en la constructora.
		"""
		url = 'http://horarios.renfe.com/cer/hjcer310.jsp'
		params = urllib.urlencode({
			'f1': '',
			'i': 's',
			'cp': 'NO',
			'nucleo': self.origen.get_nucleo().nucleo_id,		# nucleo
			'o': self.origen.estacion_id,		# estacion origen
			'd': self.destino.estacion_id,	# estacion destino
			'df': self.date, # dia en formato yyyymmdd
			'ho': self.ho, # hora de origen
			'hd': self.hd, # hora de destino
			'TXTInfo': ''})
		p = urllib.urlopen(url, params)
		return p.read()

	def __get_table(self, soup_page):
		"""
		Obtiene la tabla de horarios

		soup_page: La pagina como clase BeautifulSoup
		"""
		return soup_page.find_all('table')[0]
		
	def __set_es_transbordo(self, soup_table):
		"""
		Recibe la tabla de horarios de la pagina y devuelve cierto si hay transbordo.

		soup_table: La tabla como clase BeautifulSoup
		"""
		self.transbordo = len(soup_table.find_all('tr')[1].find_all()) > 5

	def __parse_transbordo(self, soup_table):
		for tr in soup_table.find_all('tr')[4:]:
			tds = tr.find_all('td')
			print('linea1: ' + tds[0].string) # linea 1
			print('horig1: ' + tds[1].string) # ho 1
			print('hdest1: ' + tds[2].string) # hd 1
			print('linea2: ' + tds[4].string) # linea 2
			print('horig2: ' + tds[3].string) # ho 2
			print('hdest2: ' + tds[5].string) # hd 2
			print('time  : ' + tds[6].string) # time
			print('')

	def __parse_no_transbordo(self, soup_table):
		for tr in soup_table.find_all('tr')[1:]:
			tds = tr.find_all('td')[:-1]
			print('linea: ' + tds[0].string) # linea
			print('horig: ' + tds[1].string) # ho
			print('hdest: ' + tds[2].string) # hd
			print('time : ' + tds[3].string) # time
			print('')
