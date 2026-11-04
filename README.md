# Documentación de tecnologías — PSQL Web Emulator

## Objetivo
El proyecto es un emulador educativo local de PSQL. No ejecuta PostgreSQL real: interpreta un subconjunto de comandos y mantiene bases, tablas, datos, roles y privilegios en memoria.

## Estructura de archivos (v3 — archivo único)

A partir de esta versión, **todo el proyecto vive en un único archivo `index.html`**: la hoja de estilos y los cuatro módulos de JavaScript (estado, intérprete, ayuda, interacción) están embebidos con `<style>` y `<script>` en lugar de enlazados como archivos externos. Esto simplifica la entrega para el examen (un solo archivo para abrir/copiar) sin cambiar la lógica interna.

- `index.html`: estructura, estilos y los 4 bloques de script, en este orden:
  1. **Motor de datos** (antes `database.js`): objeto `DB`, `initialState()`, `hasPrivilege()`, `grantP()`, `revokeP()`.
  2. **Intérprete de comandos** (antes `commands.js`): `executeCommand()` y todas las funciones de cada sentencia.
  3. **Ayuda y teoría** (antes `help.js`): constantes `HELP` y `EXPLAIN`.
  4. **Interacción de la terminal** (antes `script.js`): conecta el DOM con el motor.
- `DOCUMENTACION_TECNOLOGIAS.md`: esta documentación (se mantiene separada, como archivo Markdown).

## Cambios v4 — Esquemas, formato estilo psql y ubicación de botones

### Manejo de esquemas (`public.tabla`)
El emulador ya asumía conceptualmente un único esquema `public` (los privilegios de `CREATE`/`USAGE` sobre esquema siempre se validaban contra `"public"`). Esta versión hace ese esquema explícito y consultable:

- Cada tabla creada con `CREATE TABLE` guarda ahora `schema:"public"`, `owner` (el rol que la creó) y `type:"table"`, además de sus columnas y filas.
- Se agregó la función `resolveTableRef(ref)`, que interpreta una referencia de tabla como `"public.compras"` o simplemente `"compras"` (por defecto, esquema `public`).
- `SELECT`, `INSERT`, `UPDATE` y `DELETE` ahora aceptan ambas formas (`FROM compras` o `FROM public.compras`). Si se referencia un esquema distinto de `public` (que es el único implementado), el emulador responde `ERROR: el esquema "X" no existe`, igual que haría PostgreSQL real con un esquema inexistente.
- Los privilegios se siguen validando por nombre de tabla (sin el prefijo de esquema), ya que solo existe `public`; esto no cambió.

> **Nota de alcance:** por ahora no existe `CREATE SCHEMA`, y `GRANT ... ON tabla ...` sigue sin aceptar el prefijo `public.` explícito. Son extensiones posibles si el examen las llega a pedir, pero no estaban en el alcance solicitado.

### Metacomandos con formato real de psql
- **`\l` / `\list`** → título `List of databases`, columnas `Name | Owner | Encoding` (Encoding fijo en `UTF8`).
- **`\dt`** → título `List of relations`, columnas `Schema | Name | Type | Owner`.
- **`\d tabla`** → título `Table "public.tabla"`, columnas `Column | Type | Nullable`. Si la columna se definió con `NOT NULL` (ej. `id INT NOT NULL`), el emulador separa el tipo (`INT`) de la marca `not null` para mostrarlos en columnas distintas.
- **`\du`** no cambió.

Para soportar estos títulos, la función `table()` (en el intérprete) ahora acepta un tercer parámetro opcional `title`, y `printTable()` (en la interacción de la terminal) lo imprime como una línea antes de la tabla HTML.

### `;` obligatorio en sentencias SQL
Se corrigió un bug: las expresiones regulares de `CREATE`, `DROP`, `GRANT`, `REVOKE`, `SET ROLE`, `RESET ROLE`, `INSERT`, `SELECT`, `UPDATE`, `DELETE`, `BACKUP` y `SELECT version()/pg_roles` tenían el `;` final como opcional (`;?`), por lo que un comando sin `;` se interpretaba igual como válido. Ahora el `;` es obligatorio en todas las sentencias SQL; si falta, el emulador devuelve `ERROR: sintaxis no reconocida`. Los metacomandos de psql (`\l`, `\dt`, `\d`, `\du`, `\c`, `\q`, `whoami`, `clear`) siguen sin requerir `;`, igual que en psql real.

### Botones junto al campo de comando
Los botones **Ejecutar**, **Ayuda**, **Explicaciones**, **Limpiar** y **Reiniciar** se movieron del encabezado superior a la misma fila del campo de texto (`input-row`), alineados a la derecha, en lugar de estar en la barra de título.



### HTML5
Estructura de la terminal, barra de estado, entrada de comandos y panel lateral de ayuda/explicaciones.

### CSS3
Interfaz oscura tipo consola: tipografía monoespaciada, terminal con scroll, colores de errores/resultados (`output-success`, `output-error`, `output-info`, `output-normal`), tablas y panel lateral. Sin framework, para mantener el proyecto fácil de explicar.

### JavaScript puro
Motor del emulador: procesa SQL y meta-comandos, modifica el estado, actualiza la terminal y controla los privilegios. Todo corre localmente, sin dependencias.

### Memoria RAM de JavaScript
El objeto `DB` representa el estado de la sesión (base actual, roles, privilegios, tablas, registros). No se usa `localStorage`, `sessionStorage`, IndexedDB ni una base real. F5/Ctrl+F5 vuelve a ejecutar `initialState()` y restaura el estado base (RF-15). El botón **Reiniciar** hace lo mismo sin recargar la página.

### `hasPrivilege()`
Función central de seguridad. Antes de una operación protegida consulta los privilegios del rol activo (`DB.sessionRole`) y de los roles de los que es miembro. Si no existe el permiso, devuelve un error con código `[42501]` (RF-07).

### Validación de dependencias al eliminar roles (nuevo)
`DROP ROLE` / `DROP USER` ahora verifican, antes de borrar:
1. Que ningún otro rol/usuario tenga ese rol concedido (si lo tiene, hay que hacer `REVOKE ... FROM ...;` primero).
2. Que el propio rol a eliminar no tenga a su vez roles asignados pendientes de revocar.
3. Que no se intente eliminar el rol activo de la sesión ni `postgres`.

Estos errores se marcan con el código `[2BP01]`, el mismo que usa PostgreSQL real para "objetos dependientes".

### `whoami` (nuevo)
Meta-comando que muestra el rol de login original y el rol de sesión activo (útil tras `SET ROLE`), junto con si es superusuario.

### `SET ROLE` / `RESET ROLE` (corregido)
`SET ROLE` ahora exige que el rol de login sea superusuario o tenga el rol destino concedido por membresía (`GRANT rol TO usuario`), sin importar si el rol destino es `LOGIN` o `NOLOGIN`. Antes solo se validaba para roles `NOLOGIN`, lo que permitía cambiar a cualquier usuario sin permiso real. `RESET ROLE` vuelve siempre al rol de login original.

### Intérprete de comandos
Reconoce mediante expresiones regulares:
- `CREATE DATABASE`
- `CREATE TABLE` (guarda `schema`, `owner` y `type` de cada tabla)
- `INSERT`, `SELECT`, `UPDATE`, `DELETE` (aceptan `tabla` o `public.tabla`)
- `CREATE ROLE`, `CREATE USER`
- `GRANT`, `REVOKE`, `DROP ROLE`/`DROP USER` (con validación de dependencias)
- `SET ROLE`, `RESET ROLE`, `whoami`
- `BACKUP DATABASE`
- `SELECT version()`, `pg_roles`
- `\l`, `\list`, `\connect`, `\dt`, `\d`, `\du`, `\q`

Todas las sentencias SQL (no los metacomandos con `\`) exigen `;` al final; si falta, se considera sintaxis no reconocida.

No pretende implementar el parser completo de PostgreSQL; es una simulación educativa.

## Desarrollo por fases

1. **Interfaz (RF-01):** HTML + CSS.
2. **Prompt dinámico (RF-02):** JavaScript lee `currentDatabase` y `sessionRole`.
3. **Ejecución (RF-03):** eventos `Enter` y botón **Ejecutar**.
4. **Bases (RF-04):** objeto `databases` + comandos de conexión/listado.
5. **Tablas/DML (RF-05):** objetos `tables` y funciones CRUD.
6. **Roles/usuarios (RF-06):** objeto `roles`, LOGIN/NOLOGIN, membresías y validación de dependencias en DROP.
7. **Privilegios (RF-07):** `hasPrivilege()`, GRANT/REVOKE y 42501.
8. **Cambio de rol (RF-08):** `SET ROLE`, `RESET ROLE` y `whoami`.
9. **Backup (RF-09):** generación textual de CREATE TABLE + INSERT.
10. **Sistema (RF-10):** `version()` y `pg_roles`.
11. **Ayuda (RF-11):** panel categorizado (`.help-category`) generado desde la constante `HELP`.
12. **Explicaciones (RF-12):** panel de teoría generado desde la constante `EXPLAIN`, mismo panel lateral que Ayuda, alternando contenido con el botón **Explicaciones**.
13. **Salida (RF-13):** `\q`, `quit`, `exit`, `salir`.
14. **Errores (RF-14):** clases CSS `output-error`, `output-success`, `output-info`.
15. **Sesión (RF-15):** estado en RAM, reinicio por recarga o por botón **Reiniciar**.

## Ejecución

Abrir `index.html` directamente en el navegador. No requiere WAMP ni PostgreSQL, ni ningún archivo adicional aparte de este documento.

## Secuencia recomendada para demostrar el examen

```sql
CREATE DATABASE compras;
\connect compras
CREATE TABLE productos (id INT NOT NULL, nombre VARCHAR, precio DECIMAL);
INSERT INTO productos VALUES (1, 'Mouse', '50');
SELECT * FROM productos;
SELECT * FROM public.productos;      -- misma tabla, referenciada con el esquema explícito
CREATE ROLE ventas NOLOGIN;
CREATE USER juan WITH PASSWORD '1234';
GRANT CONNECT ON DATABASE compras TO juan;
GRANT USAGE, CREATE ON SCHEMA public TO ventas;
GRANT SELECT, INSERT, UPDATE, DELETE ON productos TO ventas;
GRANT ventas TO juan;
SET ROLE ventas;
whoami
SELECT * FROM productos;
RESET ROLE;
whoami
BACKUP DATABASE compras;
SELECT * FROM pg_roles;
\du
\l                               -- List of databases: Name | Owner | Encoding
\dt                              -- List of relations: Schema | Name | Type | Owner
\d productos                     -- Table "public.productos": Column | Type | Nullable

-- Demostrar validación de dependencias:
DROP ROLE ventas;              -- debe fallar: juan depende de ventas
REVOKE ventas FROM juan;
DROP ROLE ventas;               -- ahora sí funciona

-- Demostrar que el ; es obligatorio:
CREATE DATABASE prueba          -- debe fallar: sintaxis no reconocida (falta ;)
```

## Limitaciones intencionales
No se implementan todas las características de PostgreSQL: parser completo, transacciones, índices, claves foráneas, funciones, triggers, autenticación real, concurrencia o persistencia. Tampoco existe `CREATE SCHEMA`: todo el proyecto trabaja sobre un único esquema `public` (las tablas y sus privilegios viven ahí), aunque las consultas ya aceptan referenciarlo explícitamente como `public.tabla`. El alcance está orientado a RF-01 → RF-15.

**Autor:** Ariel Lesmo
**Proyecto:** PSQL Web Emulator
**Apoyo:** Claude.ai
**Versión de este documento:** v4 (esquemas, formato psql en \l/\dt/\d, `;` obligatorio, botones junto al campo de comando)
