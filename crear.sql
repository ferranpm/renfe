CREATE TABLE ciudades (
  nucleo INTEGER NOT NULL,
  ciudad VARCHAR(30) NOT NULL,
  PRIMARY KEY (nucleo)
);

CREATE TABLE estaciones (
  id INTEGER NOT NULL,
  nucleo INTEGER NOT NULL,
  estacion VARCHAR(50) NOT NULL,
  FOREIGN KEY (nucleo) REFERENCES ciudad(nucleo),
  PRIMARY KEY (id)
);

