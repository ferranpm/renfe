import urllib2
from xml.dom import minidom

RENFE_NUCLEOS = 'http://renfe.mobi/renfev2/ciudades_cercanias.do;jsessionid=202E47E77C012136306FE607145DA64D?ss=202E47E77C012136306FE607145DA64D'

p = urllib2.urlopen(RENFE_NUCLEOS)
c = p.read()
dom = minidom.parseString(c)

links = dom.getElementsByTagName('a')

for link in links:
  url = link.attributes['href'].nodeValue
  l = url.split('&')
  if len(l) >= 3:
    ciudad = l[1].split('ciudad=')[1]
    nucleo = l[2].split('nucleo=')[1]
    print nucleo, ciudad
