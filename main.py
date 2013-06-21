# import webapp2
import urllib2
import sqlite3

class MainPage(webapp2.RequestHandler):
  def get(self):
    o = self.request.get('o')
    d = self.request.get('d')
    conn = sqlite.connect('database')
    self.response.out.write('')

application = webapp2.WSGIApplication([
  ('/', MainPage),
  ], debug=True)


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
