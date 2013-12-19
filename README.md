# API-RENFE
Una simple API (Python) para los horarios de trenes de la renfe.

## API
### Nucleo
### Estacion
### Horario

## Web Interface
### Usage
Todo lo que se devuelve esta en formato JSON
`/nucleos` -> devuelve todos los nucleos en un diccionario {nombre, id}

`/estaciones?n=X` -> devuelve las estaciones del nucleo `X` con el formato {nombre, id}

[TODO] `/horario?o=X&d=Y` -> devuelve los horarios entre las estaciones X e Y

## TODO
* [ ] Poner bien los nombres de estaciones/ciudades en schema.sql (acentos, Ñs...)
* [ ] La clase Horario debe guardar la tabla en un diccionario/tabla para poder devolverlo
