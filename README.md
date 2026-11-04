# PSQL Web Emulator

Emulador de PostgreSQL que corre completamente en el navegador, con una terminal tipo `psql`. El proyecto se llama **Jehidy** dentro de la aplicación. No necesita instalación, servidor ni dependencias externas: es un único archivo `index.html`.

Incluye una base de datos de ejemplo (LDD-LMD) con estados civiles, ciudades, personas, funcionarios, cargos, pedidos, artículos, depósitos y stock. Al abrirla por primera vez se crea sola.

## Uso

Abre `index.html` en el navegador, o publícalo con GitHub Pages (ver abajo). Escribe SQL en el editor y pulsa **Ejecutar** (`Ctrl+Enter`). Si seleccionas texto, solo se ejecuta la selección.

## Qué soporta

- **Comandos psql:** `\dt`, `\d tabla`, `\?`
- **DDL:** `CREATE TABLE`, `DROP TABLE [IF EXISTS] [CASCADE]`
- **DML:** `INSERT ... RETURNING`, `UPDATE`, `DELETE`, `SELECT` con `JOIN`, `LEFT JOIN`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`, `OFFSET`, `DISTINCT`
- **Transacciones:** `BEGIN`, `COMMIT`, `ROLLBACK`
- **Tipos:** `SERIAL`, `INTEGER`, `NUMERIC`, `VARCHAR`, `TEXT`, `DATE`, `TIMESTAMP`, `BOOLEAN`
- **Restricciones:** `PRIMARY KEY` (simple o compuesta), `UNIQUE`, `NOT NULL`, `DEFAULT`, `CHECK`, `REFERENCES` / `FOREIGN KEY` (con `CONSTRAINT nombre`)
- **Funciones:** `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `ROUND`, `UPPER`, `LOWER`, `LENGTH`, `ABS`, `COALESCE`, `NOW`, `VERSION`
- Errores con formato de PostgreSQL (clave duplicada, clave foránea, `NOT NULL`, `CHECK`).

## Archivos

- `index.html`: la aplicación completa (motor SQL + interfaz).
- `ldd-lmd.sql`: el script de la base de datos de ejemplo, para usarlo también en un PostgreSQL real.

## Publicar con GitHub Pages

1. Crea un repositorio llamado `psql-web-emulator` y sube estos archivos.
2. En **Settings → Pages**, elige **Deploy from a branch**, rama `main`, carpeta `/ (root)`.
3. El sitio quedará en `https://TU-USUARIO.github.io/psql-web-emulator/`.

## Limitaciones

Es una emulación escrita en JavaScript, no un PostgreSQL real. Cubre un subconjunto de SQL: no incluye subconsultas, `UNION`, índices, vistas, triggers ni funciones almacenadas. Los datos se guardan en el `localStorage` del navegador.
