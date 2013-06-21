import urllib2
from xml.dom import minidom

RENFE_ESTACIONES = 'http://renfe.mobi/renfev2/hora_ga_cercanias.do?'

f = open('nucleo-ciudad')
lines = f.readlines()
for line in lines:
  nucleo, ciudad = line.split(' ')
  ciudad = ciudad.split('\n')[0]
  url = RENFE_ESTACIONES + "nucleo=%s&ciudad=%s" % (nucleo, ciudad)
  p = urllib2.urlopen(url)
  c = p.read()
  x = minidom.parseString(c)
  # print nucleo, ciudad
  selects = x.getElementsByTagName('select')
  for select in selects:
    if select.attributes['name'].nodeValue == 'o':
      for estacio in select.childNodes:
        print estacio.attributes['value'].nodeValue.encode('utf-8'), estacio.firstChild.nodeValue.encode('utf-8')
  # print ''


