/* ============================================================
   PRY2204 - SEMANA 7
   Holding Carpenter SPA - Sistema de Gestión de Personal
   Poblamiento y consultas con sentencias SQL
   ============================================================ */

/* ------------------------------------------------------------
   BORRADO DE OBJETOS
   Permite reejecutar el script completo sin errores
   ------------------------------------------------------------ */
BEGIN
    FOR t IN (SELECT table_name FROM user_tables
              WHERE table_name IN ('DOMINIO','TITULACION','PERSONAL','COMPANIA',
                                   'COMUNA','REGION','IDIOMA','TITULO',
                                   'GENERO','ESTADO_CIVIL')) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
    FOR s IN (SELECT sequence_name FROM user_sequences
              WHERE sequence_name IN ('SEQ_COMUNA','SEQ_COMPANIA')) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

/* ============================================================
   CASO 1: CREACIÓN DE TABLAS (de fuertes a débiles)
   ============================================================ */

/* ------------------------------------------------------------
   REGION - identificador identity que inicia en 7 e incrementa en 2
   ------------------------------------------------------------ */
CREATE TABLE region (
    id_region     NUMBER(2) GENERATED ALWAYS AS IDENTITY
                  (START WITH 7 INCREMENT BY 2),
    nombre_region VARCHAR2(25) NOT NULL
);
ALTER TABLE region ADD CONSTRAINT region_pk PRIMARY KEY (id_region);

/* ------------------------------------------------------------
   IDIOMA - identificador identity que inicia en 25 e incrementa en 3
   ------------------------------------------------------------ */
CREATE TABLE idioma (
    id_idioma     NUMBER(3) GENERATED ALWAYS AS IDENTITY
                  (START WITH 25 INCREMENT BY 3),
    nombre_idioma VARCHAR2(30) NOT NULL
);
ALTER TABLE idioma ADD CONSTRAINT idioma_pk PRIMARY KEY (id_idioma);

/* ------------------------------------------------------------
   TABLAS DE CATÁLOGO
   ------------------------------------------------------------ */
CREATE TABLE genero (
    id_genero          VARCHAR2(3)  NOT NULL,
    descripcion_genero VARCHAR2(25) NOT NULL
);
ALTER TABLE genero ADD CONSTRAINT genero_pk PRIMARY KEY (id_genero);

CREATE TABLE estado_civil (
    id_estado_civil       VARCHAR2(2)  NOT NULL,
    descripcion_est_civil VARCHAR2(25) NOT NULL
);
ALTER TABLE estado_civil ADD CONSTRAINT estado_civil_pk PRIMARY KEY (id_estado_civil);

CREATE TABLE titulo (
    id_titulo          VARCHAR2(3)  NOT NULL,
    descripcion_titulo VARCHAR2(60) NOT NULL
);
ALTER TABLE titulo ADD CONSTRAINT titulo_pk PRIMARY KEY (id_titulo);

/* ------------------------------------------------------------
   COMUNA - clave primaria compuesta con la región
   ------------------------------------------------------------ */
CREATE TABLE comuna (
    id_comuna      NUMBER(5)    NOT NULL,
    comuna_nombre  VARCHAR2(25) NOT NULL,
    cod_region     NUMBER(2)    NOT NULL
);
ALTER TABLE comuna ADD CONSTRAINT comuna_pk PRIMARY KEY (id_comuna, cod_region);
ALTER TABLE comuna ADD CONSTRAINT comuna_fk_region
    FOREIGN KEY (cod_region) REFERENCES region (id_region);

/* ------------------------------------------------------------
   COMPANIA - nombre único; hereda la clave compuesta de COMUNA
   ------------------------------------------------------------ */
CREATE TABLE compania (
    id_empresa      NUMBER(2)    NOT NULL,
    nombre_empresa  VARCHAR2(25) NOT NULL,
    calle           VARCHAR2(50) NOT NULL,
    numeracion      NUMBER(5)    NOT NULL,
    renta_promedio  NUMBER(10)   NOT NULL,
    pct_aumento     NUMBER(4,3),
    cod_comuna      NUMBER(5)    NOT NULL,
    cod_region      NUMBER(2)    NOT NULL
);
ALTER TABLE compania ADD CONSTRAINT compania_pk PRIMARY KEY (id_empresa);
ALTER TABLE compania ADD CONSTRAINT compania_un_nombre UNIQUE (nombre_empresa);
ALTER TABLE compania ADD CONSTRAINT compania_fk_comuna
    FOREIGN KEY (cod_comuna, cod_region) REFERENCES comuna (id_comuna, cod_region);

/* ------------------------------------------------------------
   PERSONAL - tabla central del modelo
   Nota: el sueldo se define NUMBER(8) para admitir el mínimo
   legal de 450.000 exigido en el Caso 2.
   ------------------------------------------------------------ */
CREATE TABLE personal (
    rut_persona       NUMBER(8)     NOT NULL,
    dv_persona        CHAR(1)       NOT NULL,
    primer_nombre     VARCHAR2(25)  NOT NULL,
    segundo_nombre    VARCHAR2(25),
    primer_apellido   VARCHAR2(25)  NOT NULL,
    segundo_apellido  VARCHAR2(25)  NOT NULL,
    fecha_contratacion DATE         NOT NULL,
    fecha_nacimiento  DATE          NOT NULL,
    email             VARCHAR2(100),
    calle             VARCHAR2(50)  NOT NULL,
    numeracion        NUMBER(5)     NOT NULL,
    sueldo            NUMBER(8)     NOT NULL,
    cod_comuna        NUMBER(5)     NOT NULL,
    cod_region        NUMBER(2)     NOT NULL,
    cod_genero        VARCHAR2(3),
    cod_estado_civil  VARCHAR2(2),
    cod_empresa       NUMBER(2)     NOT NULL,
    encargado_rut     NUMBER(8)
);
ALTER TABLE personal ADD CONSTRAINT personal_pk PRIMARY KEY (rut_persona);
ALTER TABLE personal ADD CONSTRAINT personal_fk_compania
    FOREIGN KEY (cod_empresa) REFERENCES compania (id_empresa);
ALTER TABLE personal ADD CONSTRAINT personal_fk_comuna
    FOREIGN KEY (cod_comuna, cod_region) REFERENCES comuna (id_comuna, cod_region);
ALTER TABLE personal ADD CONSTRAINT personal_fk_estado_civil
    FOREIGN KEY (cod_estado_civil) REFERENCES estado_civil (id_estado_civil);
ALTER TABLE personal ADD CONSTRAINT personal_fk_genero
    FOREIGN KEY (cod_genero) REFERENCES genero (id_genero);
ALTER TABLE personal ADD CONSTRAINT personal_personal_fk
    FOREIGN KEY (encargado_rut) REFERENCES personal (rut_persona);

/* ------------------------------------------------------------
   TITULACION - tabla intermedia PERSONAL / TITULO
   ------------------------------------------------------------ */
CREATE TABLE titulacion (
    cod_titulo       VARCHAR2(3) NOT NULL,
    persona_rut      NUMBER(8)   NOT NULL,
    fecha_titulacion DATE        NOT NULL
);
ALTER TABLE titulacion ADD CONSTRAINT titulacion_pk PRIMARY KEY (cod_titulo, persona_rut);
ALTER TABLE titulacion ADD CONSTRAINT titulacion_fk_personal
    FOREIGN KEY (persona_rut) REFERENCES personal (rut_persona);
ALTER TABLE titulacion ADD CONSTRAINT titulacion_fk_titulo
    FOREIGN KEY (cod_titulo) REFERENCES titulo (id_titulo);

/* ------------------------------------------------------------
   DOMINIO - tabla intermedia PERSONAL / IDIOMA
   ------------------------------------------------------------ */
CREATE TABLE dominio (
    id_idioma   NUMBER(3)    NOT NULL,
    persona_rut NUMBER(8)    NOT NULL,
    nivel       VARCHAR2(25) NOT NULL
);
ALTER TABLE dominio ADD CONSTRAINT dominio_pk PRIMARY KEY (id_idioma, persona_rut);
ALTER TABLE dominio ADD CONSTRAINT dominio_fk_idioma
    FOREIGN KEY (id_idioma) REFERENCES idioma (id_idioma);
ALTER TABLE dominio ADD CONSTRAINT dominio_fk_personal
    FOREIGN KEY (persona_rut) REFERENCES personal (rut_persona);

/* ============================================================
   CASO 2: MODIFICACIONES CON ALTER TABLE
   ============================================================ */

-- El email es opcional, pero no puede repetirse
ALTER TABLE personal ADD CONSTRAINT personal_un_email UNIQUE (email);

-- El dígito verificador solo admite los valores 0 al 9 y la letra K
ALTER TABLE personal ADD CONSTRAINT personal_ck_dv
    CHECK (dv_persona IN ('0','1','2','3','4','5','6','7','8','9','K'));

-- El sueldo mínimo del personal es de 450.000 pesos
ALTER TABLE personal ADD CONSTRAINT personal_ck_sueldo
    CHECK (sueldo >= 450000);

/* ============================================================
   CASO 3: POBLAMIENTO DEL MODELO
   ============================================================ */

/* ------------------------------------------------------------
   SECUENCIAS
   COMUNA: inicia en 1101 e incrementa en 6
   COMPANIA: inicia en 10 e incrementa en 5
   ------------------------------------------------------------ */
CREATE SEQUENCE seq_comuna START WITH 1101 INCREMENT BY 6 NOCACHE NOCYCLE;

CREATE SEQUENCE seq_compania START WITH 10 INCREMENT BY 5 NOCACHE NOCYCLE;

/* ------------------------------------------------------------
   REGION - el id se genera con identity (7, 9, 11)
   ------------------------------------------------------------ */
INSERT INTO region (nombre_region) VALUES ('ARICA Y PARINACOTA');
INSERT INTO region (nombre_region) VALUES ('METROPOLITANA');
INSERT INTO region (nombre_region) VALUES ('LA ARAUCANIA');

/* ------------------------------------------------------------
   IDIOMA - el id se genera con identity (25, 28, 31, 34, 37)
   ------------------------------------------------------------ */
INSERT INTO idioma (nombre_idioma) VALUES ('Ingles');
INSERT INTO idioma (nombre_idioma) VALUES ('Chino');
INSERT INTO idioma (nombre_idioma) VALUES ('Aleman');
INSERT INTO idioma (nombre_idioma) VALUES ('Espanol');
INSERT INTO idioma (nombre_idioma) VALUES ('Frances');

/* ------------------------------------------------------------
   COMUNA - el id se genera con la secuencia (1101, 1107, 1113)
   ------------------------------------------------------------ */
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region)
    VALUES (seq_comuna.NEXTVAL, 'Arica', 7);
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region)
    VALUES (seq_comuna.NEXTVAL, 'Santiago', 9);
INSERT INTO comuna (id_comuna, comuna_nombre, cod_region)
    VALUES (seq_comuna.NEXTVAL, 'Temuco', 11);

/* ------------------------------------------------------------
   COMPANIA - el id se genera con la secuencia (10, 15, 20 ... 55)
   ------------------------------------------------------------ */
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'CCyRojas', 'Amapolas', 506, 1857000, 0.5, 1101, 7);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'SenTTy', 'Los Alamos', 3490, 897000, 0.025, 1101, 7);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'Praxia LTDA', 'Las Camelias', 11098, 2157000, 0.035, 1107, 9);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'TIC spa', 'FLORES S.A.', 4357, 857000, NULL, 1107, 9);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'SANTANA LTDA', 'AVDA VIC. MACKENA', 106, 757000, 0.015, 1101, 7);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'FLORES Y ASOCIADOS', 'PEDRO LATORRE', 557, 589000, 0.015, 1107, 9);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'J.A. HOFFMAN', 'LATINA D.32', 509, 1857000, 0.025, 1113, 11);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'CAGLIARI D.', 'ALAMEDA', 206, 1857000, NULL, 1107, 9);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'Rojas HNOS LTDA', 'SUCRE', 106, 957000, 0.005, 1113, 11);
INSERT INTO compania (id_empresa, nombre_empresa, calle, numeracion,
                      renta_promedio, pct_aumento, cod_comuna, cod_region)
    VALUES (seq_compania.NEXTVAL, 'FRIENDS P. S.A', 'SUECIA', 506, 857000, 0.015, 1113, 11);

COMMIT;

/* ============================================================
   CASO 4: RECUPERACIÓN DE DATOS
   ============================================================ */

/* ------------------------------------------------------------
   INFORME 1: Simulación de Renta Promedio
   Renta promedio más el porcentaje de aumento registrado.
   Ordenado por renta de mayor a menor; los empates se resuelven
   alfabéticamente por nombre de empresa.
   ------------------------------------------------------------ */
SELECT nombre_empresa                                   AS "Nombre Empresa",
       calle || ' ' || numeracion                        AS "Dirección",
       renta_promedio                                    AS "Renta Promedio",
       renta_promedio + (renta_promedio * pct_aumento)   AS "Simulación de Renta"
FROM   compania
ORDER  BY renta_promedio DESC, nombre_empresa ASC;

/* ------------------------------------------------------------
   INFORME 2: Nueva simulación con 15% adicional
   Al porcentaje registrado se le suma un 15% y se aplica
   sobre la renta promedio actual.
   Ordenado por renta actual ascendente y luego por nombre
   de empresa descendente.
   ------------------------------------------------------------ */
SELECT id_empresa                                        AS "CODIGO",
       nombre_empresa                                    AS "EMPRESA",
       renta_promedio                                    AS "PROM RENTA ACTUAL",
       pct_aumento + 0.15                                AS "PCT AUMENTADO EN 15%",
       renta_promedio * (pct_aumento + 0.15)             AS "RENTA AUMENTADA"
FROM   compania
ORDER  BY renta_promedio ASC, nombre_empresa DESC;