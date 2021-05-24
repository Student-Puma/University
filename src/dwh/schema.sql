-- -----------------------------------------------------
-- Schema
-- -----------------------------------------------------

DROP DATABASE IF EXISTS `dwh`;
CREATE DATABASE IF NOT EXISTS `dwh` DEFAULT CHARACTER SET utf8;
USE `dwh`;

-- -----------------------------------------------------
-- Clientes
-- -----------------------------------------------------

/*
    @table: dim_tiempo
    @primary: tiempo_bigkey
    @description: Dimensión temporal (rango de días al año)
*/
CREATE TABLE `dim_tiempo` (
  `tiempo_bigkey`                 INT UNSIGNED NOT NULL AUTO_INCREMENT, -- clave primaria del DWH
  `fecha`                         DATE DEFAULT NULL,                    -- fecha completa (ID)
  `anho`                          SMALLINT(4) DEFAULT NULL,             -- año
  `mes`                           TINYINT(2) DEFAULT NULL,              -- mes
  `dia`                           TINYINT(2) DEFAULT NULL,              -- dia
  `dia_semana`                    VARCHAR(9) DEFAULT NULL,              -- dia de la semana (lunes, martes, miércoles...)
  `trimestre`                     TINYINT(1) DEFAULT NULL,              -- trimestre
  `laboral`                       VARCHAR(7) DEFAULT NULL,              -- festivo / laboral

  PRIMARY KEY (`tiempo_bigkey`),
  UNIQUE KEY (`fecha`) USING BTREE,
  CONSTRAINT `chk_dim_time_laboral`
    CHECK (`laboral` IN ('laboral', 'festivo')),
  CONSTRAINT `chk_dim_time_dia_semana`
    CHECK (`dia_semana` IN ('lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo')),
  CONSTRAINT `chk_dim_time_mes`
    CHECK (`mes` > 0 AND `mes` < 13),
  CONSTRAINT `chk_dim_time_dia`
    CHECK (`dia` > 0 AND `dia` < 32),
  CONSTRAINT `chk_dim_time_trimestre`
    CHECK (`trimestre` > 0 AND `trimestre` < 5)
)ENGINE = InnoDB;

/*
    @table: dim_cliente
    @primary: cliente_bigkey
    @description: Dimensión cliente (consumidores)
*/
CREATE TABLE `dim_cliente` (
  `cliente_bigkey`            INT UNSIGNED NOT NULL AUTO_INCREMENT,             -- clave primaria del DWH
  `cliente_last_update`       DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',  -- última carga de datos
  `cliente_version`           SMALLINT(5) DEFAULT NULL,                         -- versionado
  `cliente_valid_from`        DATE DEFAULT NULL,                                -- versionado (inicio)
  `cliente_valid_to`          DATE DEFAULT NULL,                                -- versionado (final)

  `cliente_ID`                INT UNSIGNED DEFAULT NULL,                        -- DNI del cliente
  `cliente_nombre`            VARCHAR(200) DEFAULT NULL,                        -- nombre del comprador
  `cliente_genero`            VARCHAR(6) DEFAULT 'OTRO',                        -- género
  `cliente_fecha_nacimiento`  DATE DEFAULT NULL,                                -- fecha de nacimiento
  `cliente_empresa`           VARCHAR(150) DEFAULT NULL,                        -- empresa para la que trabaja (NULL = particular)
  -- fuente externa
  `cliente_empresa_sector`    VARCHAR(200) DEFAULT NULL,                        -- sector en el que trabaja
  `cliente_empresa_actividad` VARCHAR(200) DEFAULT NULL,                        -- actividad de la empresa en el que trabaja
  -- calculados
  `cliente_edad`              TINYINT(3) DEFAULT NULL,                          -- edad calculada del cliente
  `cliente_compras`           INTEGER DEFAULT 0,                                -- cantidad de licencias compradas
  `cliente_dinero`            DOUBLE DEFAULT 0,                                 -- cantidad de dinero gastado

  PRIMARY KEY (`cliente_bigkey`),
  KEY `cliente_ID` (`cliente_ID`) USING BTREE,
  CONSTRAINT `chk_dim_cliente_genero`
    CHECK (`cliente_genero` IN ('HOMBRE', 'MUJER', 'OTRO'))
)ENGINE = InnoDB;
CREATE INDEX idx_dim_cliente_lookup ON dim_cliente(cliente_ID);
CREATE INDEX idx_dim_cliente_tk ON dim_cliente(cliente_bigkey);

/*
    @table: dim_empleado
    @primary: empleado_bigkey
    @description: Dimensión empleado
*/
CREATE TABLE `dim_empleado` (
  `empleado_bigkey`               INT UNSIGNED NOT NULL AUTO_INCREMENT,             -- clave primaria del DWH
  `empleado_last_update`          DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',  -- última carga de datos
  `empleado_version`              SMALLINT(5) DEFAULT NULL,                         -- versionado
  `empleado_valid_from`           DATE DEFAULT NULL,                                -- versionado (inicio)
  `empleado_valid_to`             DATE DEFAULT NULL,                                -- versionado (final)

  `empleado_ID`                   INT UNSIGNED DEFAULT NULL,                        -- ID del empleado
  `empleado_nombre`               VARCHAR(200) DEFAULT NULL,                        -- nombre del empleado
  `empleado_genero`               VARCHAR(6) DEFAULT 'OTRO',                        -- género
  `empleado_fecha_nacimiento`     DATE DEFAULT NULL,                                -- fecha de nacimiento
  `empleado_puesto`               VARCHAR(50) DEFAULT NULL,                         -- puesto / equipo
  `empleado_salario`              INT UNSIGNED DEFAULT NULL,                        -- salario
  -- calculados
  `empleado_edad`                 TINYINT(3) DEFAULT NULL,                          -- edad

  PRIMARY KEY (`empleado_bigkey`),
  KEY `empleado_ID` (`empleado_ID`) USING BTREE,
  CONSTRAINT `chk_dim_empleado_genero`
    CHECK (`empleado_genero` IN ('HOMBRE', 'MUJER', 'OTRO'))
)ENGINE = InnoDB;
CREATE INDEX idx_dim_empleado_lookup ON dim_empleado(empleado_ID);
CREATE INDEX idx_dim_empleado_tk ON dim_empleado(empleado_bigkey);

/*
    @table: dim_programa
    @primary: programa_bigkey
    @description: Dimensión programa
*/
CREATE TABLE `dim_programa` (
  `programa_bigkey`               INT UNSIGNED NOT NULL AUTO_INCREMENT,             -- clave primaria del DWH
  `programa_last_update`          DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',  -- última carga de datos
  `programa_version`              SMALLINT(5) DEFAULT NULL,                         -- versionado
  `programa_valid_from`           DATE DEFAULT NULL,                                -- versionado (inicio)
  `programa_valid_to`             DATE DEFAULT NULL,                                -- versionado (final)

  `programa_ID`                   INT UNSIGNED DEFAULT NULL,                        -- ID del programa
  `programa_proyecto`             INT UNSIGNED DEFAULT NULL,                        -- ID del proyecto
  `programa_ver`                  INT UNSIGNED DEFAULT NULL,                        -- ID de la versión
  `programa_nombre`               VARCHAR(45) DEFAULT NULL,                         -- Nombre del programa
  `programa_nombre_proyecto`      VARCHAR(150) DEFAULT NULL,                        -- Nombre del proyecto
  `programa_versiones`            INTEGER DEFAULT 0,                                -- Número de versiones de programa
  `programa_proyecto_presupuesto` DECIMAL(9,2) DEFAULT NULL,                        -- presupuesto del proyecto
  -- fuente externa
  `programa_valoraciones`         TINYINT(1) DEFAULT NULL,                          -- valoración media en la Play Store
  -- calculados
  `programa_proyecto_tiempo`      INTEGER DEFAULT NULL,                             -- tiempo que llevó el desarrollo
  `programa_proyecto_jefe`        VARCHAR(150) DEFAULT NULL,                        -- jefe de proyecto
  `programa_proyecto_jefe_exp`    TINYINT(3) DEFAULT NULL,                          -- años de experiencia del jefe de proyecto

  PRIMARY KEY (`programa_bigkey`),
  KEY `programa_ID` (`programa_ID`) USING BTREE,
  KEY `programa_proyecto` (`programa_proyecto`) USING BTREE,
  KEY `programa_ver` (`programa_ver`) USING BTREE,
  CONSTRAINT `chk_dim_programa_valoraciones`
    CHECK(`programa_valoraciones` >= 0 AND `programa_valoraciones` <= 5)
)ENGINE = InnoDB;
CREATE INDEX idx_dim_programa_lookup ON dim_programa(programa_ID);
CREATE INDEX idx_dim_programa_proy_lookup ON dim_programa(programa_proyecto);
CREATE INDEX idx_dim_programa_tk ON dim_programa(programa_bigkey);

/*
    @table: fact_ventas
    @primary: ventas_bigkey
    @description: Tabla de hechos
*/
CREATE TABLE `fact_venta` (
  `venta_bigkey`              INT UNSIGNED NOT NULL AUTO_INCREMENT,             -- clave primaria del DWH
  `venta_last_update`         DATETIME NOT NULL DEFAULT '1970-01-01 00:00:00',  -- última carga de datos
  `venta_version`             SMALLINT(5) DEFAULT NULL,                         -- versionado
  `venta_valid_from`          DATE DEFAULT NULL,                                -- versionado (inicio)
  `venta_valid_to`            DATE DEFAULT NULL,                                -- versionado (final)

  `venta_ID`                  INT UNSIGNED DEFAULT NULL,                        -- ID de la venta
  `venta_tiempo`              DATETIME DEFAULT NULL,                                -- ID del tiempo
  `venta_cliente`             INT UNSIGNED DEFAULT NULL,                        -- ID del cliente
  `venta_programa`            INT UNSIGNED DEFAULT NULL,                        -- ID de la programa
  `venta_empleado`            INT UNSIGNED DEFAULT NULL,                        -- ID del empleado jefe de ese proyecto
  -- calculados
  `venta_importe`             DOUBLE DEFAULT NULL,                              -- importe percibido por la venta
  `venta_expiracion`          DATETIME DEFAULT NULL,                            -- fecha de expiración

  PRIMARY KEY (`venta_bigkey`),
  KEY `venta_ID` (`venta_ID`) USING BTREE,
  KEY `venta_tiempo` (`venta_tiempo`) USING BTREE,
  KEY `venta_cliente` (`venta_cliente`) USING BTREE,
  KEY `venta_programa` (`venta_programa`) USING BTREE,
  KEY `venta_empleado` (`venta_empleado`) USING BTREE
)ENGINE = InnoDB;
CREATE INDEX idx_dim_venta_lookup ON fact_venta(venta_ID);
CREATE INDEX idx_dim_venta_tk ON fact_venta(venta_bigkey);