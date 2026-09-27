# PRY2204 - Semana 7: Poblamiento y consultas en la base de datos con sentencias SQL

Holding Carpenter SPA — Sistema de Gestión de Personal. Modelamiento de Bases de Datos, Duoc UC.

## Contenido

`PRY2204_S7_Carpenter_SPA.sql` — script ejecutable secuencialmente en Oracle con el usuario `PRY2204_S7`.

### Caso 1 — Implementación del modelo
Creación de las 10 tablas del modelo relacional normalizado en orden de dependencia (de fuertes a débiles), con constraints PK, FK, UN y CK de nombre representativo.

- `REGION` con identificador `IDENTITY` que inicia en 7 e incrementa en 2.
- `IDIOMA` con identificador `IDENTITY` que inicia en 25 e incrementa en 3.
- Claves primarias compuestas en `COMUNA`, `TITULACION` y `DOMINIO`.
- Clave foránea compuesta de `COMPANIA` y `PERSONAL` hacia `COMUNA`.
- Autorreferencia de `PERSONAL` para el encargado.

### Caso 2 — Modificación del modelo
Restricciones agregadas con `ALTER TABLE`:

- Email opcional pero único.
- Dígito verificador del RUN restringido a 0-9 y K.
- Sueldo mínimo de $450.000.

### Caso 3 — Poblamiento del modelo
Uso de objetos `SEQUENCE` e identificadores `IDENTITY`:

- `SEQ_COMUNA`: inicia en 1101, incrementa en 6.
- `SEQ_COMPANIA`: inicia en 10, incrementa en 5.
- Poblamiento de `REGION`, `IDIOMA`, `COMUNA` y `COMPANIA` respetando el orden de integridad referencial.

### Caso 4 — Recuperación de datos
Dos informes con `SELECT`, operadores matemáticos, alias y cláusulas de ordenamiento:

1. **Simulación de Renta Promedio** — nombre, dirección concatenada, renta promedio y renta simulada con el porcentaje registrado. Ordenado por renta descendente y nombre ascendente.
2. **Nueva simulación** — porcentaje aumentado en 15% aplicado sobre la renta promedio. Ordenado por renta ascendente y nombre descendente.

## Ejecución

Ejecutar el script completo
