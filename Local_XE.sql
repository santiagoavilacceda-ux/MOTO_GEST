-- ============================================================
-- BASE DE DATOS: HISTORY_MOTORS_DB
-- Migración de SQL Server a Oracle PL/SQL
-- ============================================================

-- NOTA: En Oracle no se usa CREATE DATABASE en el script.
-- Se trabaja dentro de un esquema (usuario). Si deseas un
-- esquema dedicado, créalo así (como DBA):
--
-- CREATE USER history_motors IDENTIFIED BY tu_password;
-- GRANT CONNECT, RESOURCE, CREATE TABLE, CREATE SEQUENCE TO history_motors;
-- ============================================================


-- ============================================================
-- TABLA: EMPLEADO
-- ============================================================
CREATE TABLE EMPLEADO (
    id_empleado         NUMBER          NOT NULL,
    Cedula_Empleado     NUMBER          NOT NULL,
    Nombre_Empleado     VARCHAR2(50)    NOT NULL,
    Correo_Empleado     VARCHAR2(50)    NOT NULL,
    Rol_Empleado        VARCHAR2(50)    NOT NULL,
    Contrasena_Empleado VARCHAR2(50)    NOT NULL,
    Fecha_Ingreso       DATE            NOT NULL,
    CONSTRAINT pk_empleado          PRIMARY KEY (id_empleado),
    CONSTRAINT uq_nombre_empleado   UNIQUE (Nombre_Empleado),
    CONSTRAINT uq_correo_empleado   UNIQUE (Correo_Empleado),
    CONSTRAINT uq_rol_empleado      UNIQUE (Rol_Empleado),
    CONSTRAINT uq_contra_empleado   UNIQUE (Contrasena_Empleado)
);

CREATE SEQUENCE seq_empleado START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_empleado_bi
BEFORE INSERT ON EMPLEADO
FOR EACH ROW
BEGIN
    IF :NEW.id_empleado IS NULL THEN
        :NEW.id_empleado := seq_empleado.NEXTVAL;
    END IF;
END;
/


-- ============================================================
-- TABLA: POLITICA_GARANTIA
-- ============================================================
CREATE TABLE POLITICA_GARANTIA (
    Id              NUMBER          NOT NULL,
    Tipo_De_Garantia VARCHAR2(20)   NOT NULL,
    dias_vigencia   NUMBER          NOT NULL,
    descripcion     VARCHAR2(255)   NOT NULL,
    activo          NUMBER(1)       DEFAULT 1 NOT NULL,
    CONSTRAINT pk_politica      PRIMARY KEY (Id),
    CONSTRAINT ck_tipo          CHECK (Tipo_De_Garantia IN ('SERVICIO','REPUESTO','MOTOCICLETA')),
    CONSTRAINT ck_dias          CHECK (dias_vigencia > 0),
    CONSTRAINT ck_activo_pol    CHECK (activo IN (0,1))
);

CREATE SEQUENCE seq_politica_garantia START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_politica_garantia_bi
BEFORE INSERT ON POLITICA_GARANTIA
FOR EACH ROW
BEGIN
    IF :NEW.Id IS NULL THEN
        :NEW.Id := seq_politica_garantia.NEXTVAL;
    END IF;
END;
/


-- ============================================================
-- TABLA: CLIENTE
-- ============================================================
CREATE TABLE CLIENTE (
    Id_cliente              NUMBER          NOT NULL,
    Nombre_cliente          VARCHAR2(100)   NOT NULL,
    Identificacion_cliente  VARCHAR2(20)    NOT NULL,
    Telefono_cliente        VARCHAR2(15)    NOT NULL,
    Correo_cliente          VARCHAR2(100),
    Direccion_cliente       VARCHAR2(200),
    Fecha_registro          DATE            NOT NULL,
    Activo                  NUMBER(1)       DEFAULT 1 NOT NULL,
    CONSTRAINT pk_cliente       PRIMARY KEY (Id_cliente),
    CONSTRAINT uq_ident_cliente UNIQUE (Identificacion_cliente),
    CONSTRAINT ck_activo_cli    CHECK (activo IN (0,1))
);

CREATE SEQUENCE seq_cliente START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_cliente_bi
BEFORE INSERT ON CLIENTE
FOR EACH ROW
BEGIN
    IF :NEW.Id_cliente IS NULL THEN
        :NEW.Id_cliente := seq_cliente.NEXTVAL;
    END IF;
END;
/


-- ============================================================
-- TABLA: ORDEN_SERVICIO
-- ============================================================
CREATE TABLE ORDEN_SERVICIO (
    id_orden        NUMBER          NOT NULL,
    fecha_creacion  TIMESTAMP       DEFAULT SYSDATE NOT NULL,
    fecha_cierre    TIMESTAMP,
    estado          VARCHAR2(20)    DEFAULT 'PENDIENTE' NOT NULL,
    diagnostico     CLOB            NOT NULL,
    CONSTRAINT pk_orden     PRIMARY KEY (id_orden),
    CONSTRAINT chk_estado   CHECK (estado IN ('PENDIENTE','EN_PROCESO','CERRADA','ANULADA'))
);

CREATE SEQUENCE seq_orden_servicio START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_orden_servicio_bi
BEFORE INSERT ON ORDEN_SERVICIO
FOR EACH ROW
BEGIN
    IF :NEW.id_orden IS NULL THEN
        :NEW.id_orden := seq_orden_servicio.NEXTVAL;
    END IF;
END;
/


-- ============================================================
-- TABLA: MOTOCICLETA
-- ============================================================
CREATE TABLE MOTOCICLETA (
    id_moto     NUMBER          NOT NULL,
    placa       VARCHAR2(10)    NOT NULL,
    marca       VARCHAR2(50)    NOT NULL,
    modelo      VARCHAR2(50)    NOT NULL,
    anio        NUMBER(4)       NOT NULL,
    cilindraje  NUMBER          NOT NULL,
    color       VARCHAR2(30),
    id_cliente  NUMBER          NOT NULL,
    CONSTRAINT pk_motocicleta   PRIMARY KEY (id_moto),
    CONSTRAINT uq_placa         UNIQUE (placa),
    CONSTRAINT fk_moto_cliente  FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(Id_cliente),
    CONSTRAINT ck_anio          CHECK (anio >= 1900),
    CONSTRAINT ck_cilindraje    CHECK (cilindraje > 0)
);

CREATE SEQUENCE seq_motocicleta START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_motocicleta_bi
BEFORE INSERT ON MOTOCICLETA
FOR EACH ROW
BEGIN
    IF :NEW.id_moto IS NULL THEN
        :NEW.id_moto := seq_motocicleta.NEXTVAL;
    END IF;
END;
/


-- ============================================================
-- TABLA: REPUESTO
-- ============================================================
CREATE TABLE REPUESTO (
    id_repuesto     NUMBER          NOT NULL,
    nombre          VARCHAR2(100)   NOT NULL,
    cantidad        NUMBER          DEFAULT 1 NOT NULL,
    precio_unitario NUMBER(10,2)    NOT NULL,
    CONSTRAINT pk_repuesto PRIMARY KEY (id_repuesto)
);

CREATE SEQUENCE seq_repuesto START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_repuesto_bi
BEFORE INSERT ON REPUESTO
FOR EACH ROW
BEGIN
    IF :NEW.id_repuesto IS NULL THEN
        :NEW.id_repuesto := seq_repuesto.NEXTVAL;
    END IF;
END;
/


-- ============================================================
-- TABLA: GARANTIA
-- ============================================================
CREATE TABLE GARANTIA (
    id_garantia         NUMBER          NOT NULL,
    fecha_inicio        DATE            NOT NULL,
    fecha_vencimiento   DATE            NOT NULL,
    estado              VARCHAR2(20)    DEFAULT 'VIGENTE' NOT NULL,
    tipo_garantia       VARCHAR2(20)    NOT NULL,
    id_orden            NUMBER          NOT NULL,
    id_politica         NUMBER          NOT NULL,
    fecha_registro      TIMESTAMP       DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_garantia      PRIMARY KEY (id_garantia),
    CONSTRAINT fk_gar_orden     FOREIGN KEY (id_orden)
        REFERENCES ORDEN_SERVICIO(id_orden),
    CONSTRAINT fk_gar_politica  FOREIGN KEY (id_politica)
        REFERENCES POLITICA_GARANTIA(Id),
    CONSTRAINT ck_estado_gar    CHECK (estado IN ('VIGENTE','VENCIDA','SIN_REGISTRO')),
    CONSTRAINT ck_tipo_gar      CHECK (tipo_garantia IN ('SERVICIO','REPUESTO','MOTOCICLETA')),
    CONSTRAINT ck_fechas        CHECK (fecha_vencimiento > fecha_inicio)
);

CREATE SEQUENCE seq_garantia START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_garantia_bi
BEFORE INSERT ON GARANTIA
FOR EACH ROW
BEGIN
    IF :NEW.id_garantia IS NULL THEN
        :NEW.id_garantia := seq_garantia.NEXTVAL;
    END IF;
END;
/


-- ============================================================
-- TABLA: GARANTIA_REPUESTO (tabla pivote, sin secuencia)
-- ============================================================
CREATE TABLE GARANTIA_REPUESTO (
    id_garantia NUMBER NOT NULL,
    id_repuesto NUMBER NOT NULL,
    CONSTRAINT pk_gar_rep   PRIMARY KEY (id_garantia, id_repuesto),
    CONSTRAINT fk_grp_gar   FOREIGN KEY (id_garantia)
        REFERENCES GARANTIA(id_garantia),
    CONSTRAINT fk_grp_rep   FOREIGN KEY (id_repuesto)
        REFERENCES REPUESTO(id_repuesto)
);


-- ============================================================
-- TABLA: SOLICITUD_GARANTIA
-- ============================================================
CREATE TABLE SOLICITUD_GARANTIA (
    id_solicitud        NUMBER          NOT NULL,
    fecha_solicitud     TIMESTAMP       DEFAULT SYSDATE NOT NULL,
    descripcion         CLOB            NOT NULL,
    estado              VARCHAR2(20)    DEFAULT 'PENDIENTE' NOT NULL,
    fecha_resolucion    TIMESTAMP,
    observacion_res     CLOB,
    id_garantia         NUMBER          NOT NULL,
    id_empleado         NUMBER          NOT NULL,
    CONSTRAINT pk_solicitud     PRIMARY KEY (id_solicitud),
    CONSTRAINT fk_sol_gar       FOREIGN KEY (id_garantia)
        REFERENCES GARANTIA(id_garantia),
    CONSTRAINT fk_sol_emp       FOREIGN KEY (id_empleado)
        REFERENCES EMPLEADO(id_empleado),
    CONSTRAINT chk_estado_sol   CHECK (estado IN ('PENDIENTE','APROBADA','RECHAZADA'))
);

CREATE SEQUENCE seq_solicitud_garantia START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_solicitud_garantia_bi
BEFORE INSERT ON SOLICITUD_GARANTIA
FOR EACH ROW
BEGIN
    IF :NEW.id_solicitud IS NULL THEN
        :NEW.id_solicitud := seq_solicitud_garantia.NEXTVAL;
    END IF;
END;
/


-- ============================================================
-- TABLA: REGISTRO_AUDITORIA
-- ============================================================
CREATE TABLE REGISTRO_AUDITORIA (
    id_auditoria    NUMBER          NOT NULL,
    entidad         VARCHAR2(50)    NOT NULL,
    id_registro     NUMBER          NOT NULL,
    accion          VARCHAR2(20)    NOT NULL,
    fecha           TIMESTAMP       DEFAULT SYSDATE NOT NULL,
    valor_anterior  CLOB,
    valor_nuevo     CLOB,
    CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria),
    CONSTRAINT chk_accion   CHECK (accion IN ('CREAR','ACTUALIZAR','ELIMINAR'))
);

CREATE SEQUENCE seq_registro_auditoria START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_registro_auditoria_bi
BEFORE INSERT ON REGISTRO_AUDITORIA
FOR EACH ROW
BEGIN
    IF :NEW.id_auditoria IS NULL THEN
        :NEW.id_auditoria := seq_registro_auditoria.NEXTVAL;
    END IF;
END;
/
