-- LDD Y LMD: creación de estructura y manipulación de datos
CREATE TABLE estados_civiles (
  id_ec     SERIAL PRIMARY KEY,
  ec_descri VARCHAR(100) NOT NULL
);
CREATE TABLE cargos (
  id_car     SERIAL PRIMARY KEY,
  car_descri VARCHAR(100) NOT NULL
);
CREATE TABLE ciudades (
  id_ciu     SERIAL PRIMARY KEY,
  ciu_descri VARCHAR(100) NOT NULL
);
CREATE TABLE articulos (
  id_art      SERIAL PRIMARY KEY,
  arti_descri VARCHAR(100) NOT NULL,
  precio_uni  INTEGER NOT NULL,
  art_tipo    VARCHAR(30)
);
CREATE TABLE depositos (
  id_dep     SERIAL PRIMARY KEY,
  dep_descri VARCHAR(100) NOT NULL
);
CREATE TABLE personas (
  id_per       SERIAL PRIMARY KEY,
  per_nombre   VARCHAR(50) NOT NULL,
  per_apellido VARCHAR(50) NOT NULL,
  id_ciu       INTEGER,
  id_ec        INTEGER,
  CONSTRAINT fk_personas_ciudades FOREIGN KEY (id_ciu) REFERENCES ciudades(id_ciu),
  CONSTRAINT fk_personas_estados_civiles FOREIGN KEY (id_ec) REFERENCES estados_civiles(id_ec)
);
CREATE TABLE funcionarios (
  id_fun     SERIAL PRIMARY KEY,
  id_per     INTEGER NOT NULL,
  id_car     INTEGER NOT NULL,
  fun_estado VARCHAR(20) NOT NULL,
  CONSTRAINT fk_funcionarios_personas FOREIGN KEY (id_per) REFERENCES personas(id_per),
  CONSTRAINT fk_funcionarios_cargos FOREIGN KEY (id_car) REFERENCES cargos(id_car)
);
CREATE TABLE pedido (
  ped_nro    SERIAL PRIMARY KEY,
  ped_estado VARCHAR(20) NOT NULL,
  ped_fecha  DATE NOT NULL,
  id_fun     INTEGER NOT NULL,
  CONSTRAINT fk_pedido_funcionarios FOREIGN KEY (id_fun) REFERENCES funcionarios(id_fun)
);
CREATE TABLE pedido_detalle (
  ped_nro   INTEGER NOT NULL,
  id_art    INTEGER NOT NULL,
  ped_canti INTEGER NOT NULL,
  PRIMARY KEY (ped_nro, id_art),
  CONSTRAINT fk_pedido_detalle_pedido FOREIGN KEY (ped_nro) REFERENCES pedido(ped_nro),
  CONSTRAINT fk_pedido_detalle_articulos FOREIGN KEY (id_art) REFERENCES articulos(id_art)
);
CREATE TABLE stock (
  id_art INTEGER NOT NULL,
  id_dep INTEGER NOT NULL,
  actual INTEGER NOT NULL,
  minimo INTEGER NOT NULL,
  maximo INTEGER NOT NULL,
  PRIMARY KEY (id_art, id_dep),
  CONSTRAINT fk_stock_articulos FOREIGN KEY (id_art) REFERENCES articulos(id_art),
  CONSTRAINT fk_stock_depositos FOREIGN KEY (id_dep) REFERENCES depositos(id_dep)
);

-- Inserción de registros
INSERT INTO estados_civiles (ec_descri) VALUES
  ('SOLTERO/A'),
  ('CASADO/A');
INSERT INTO cargos (car_descri) VALUES
  ('Gerente'),
  ('Supervisor');
INSERT INTO ciudades (ciu_descri) VALUES
  ('Asunción'),
  ('Ciudad del Este');
INSERT INTO articulos (arti_descri, precio_uni, art_tipo) VALUES
  ('Notebook Lenovo 15"', 4500000.00, 'Electrónica'),
  ('Mouse inalámbrico', 85000.00, 'Periférico'),
  ('Teclado mecánico', 120000.00, 'Periférico');
INSERT INTO depositos (dep_descri) VALUES
  ('Depósito Central'),
  ('Depósito Este');
INSERT INTO personas (per_nombre, per_apellido, id_ciu, id_ec) VALUES
  ('Juan', 'Pérez', 1, 2),
  ('María', 'González', 1, 1);
INSERT INTO funcionarios (id_per, id_car, fun_estado) VALUES
  (1, 1, 'Activo'),
  (2, 1, 'Activo');
INSERT INTO pedido (ped_estado, ped_fecha, id_fun) VALUES
  ('Pendiente', '2026-01-15', 1),
  ('Entregado', '2026-01-20', 2);
INSERT INTO pedido_detalle (ped_nro, id_art, ped_canti) VALUES
  (1, 1, 2),
  (1, 2, 5),
  (2, 3, 1);
INSERT INTO stock (id_art, id_dep, actual, minimo, maximo) VALUES
  (1, 1, 15, 5, 30),
  (1, 2, 8, 3, 20),
  (2, 1, 50, 10, 100);
