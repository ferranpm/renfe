from renfe import *

lNucleos = Nucleo.get_nucleos()
for i in range(len(lNucleos)):
    print i, lNucleos[i].nombre
index = int(raw_input("Op: "))

lEstaciones = Estacion.get_estaciones(lNucleos[index])
for i in range(len(lEstaciones)):
    print i, lEstaciones[i].nombre
orig = int(raw_input("Op1: "))
dest = int(raw_input("Op2: "))

horario = Horario(lEstaciones[orig], lEstaciones[dest])
