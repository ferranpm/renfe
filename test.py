from renfe import *
import os

if __name__ == '__main__':
  l = Estacion.get_estaciones(50)
  # o = l[96] # para probar con un trayecto simple
  o = l[0] # para probar con un transbordo
  d = l[97]
  h = Horario(o, d)
  print(h.to_dict())
