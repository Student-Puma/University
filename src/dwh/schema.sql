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
  `fecha`                         DATE DEFAULT NULL,                    -- fecha completa
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
  `cliente_activo`            BOOLEAN DEFAULT FALSE,                            -- cliente con licencias activas

  PRIMARY KEY (`cliente_bigkey`),
  KEY `cliente_ID` (`cliente_ID`) USING BTREE,
  CONSTRAINT `chk_dim_cliente_genero`
    CHECK (`cliente_genero` IN ('HOMBRE', 'MUJER', 'OTRO'))
)ENGINE = InnoDB;

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
  `programa_proyecto_inicio`      DATE DEFAULT NULL,                                -- final del proyecto
  `programa_proyecto_final`       DATE DEFAULT NULL,                                -- final del proyecto
  `programa_proyecto_presupuesto` DECIMAL(9,2) DEFAULT NULL,                        -- presupuesto del proyecto
  -- fuente externa
  `programa_valoraciones`         TINYINT(1) DEFAULT NULL,                          -- valoración media en la Play Store
  -- calculados
  `programa_proyecto_jefe`        VARCHAR(150) DEFAULT NULL,                        -- jefe de proyecto
  `programa_proyecto_jefe_exp`    TINYINT(3) DEFAULT NULL,                          -- años de experiencia del jefe de proyecto

  PRIMARY KEY (`programa_bigkey`),
  KEY `programa_ID` (`programa_ID`) USING BTREE,
  KEY `programa_proyecto` (`programa_proyecto`) USING BTREE,
  KEY `programa_ver` (`programa_ver`) USING BTREE,
  CONSTRAINT `chk_dim_programa_valoraciones`
    CHECK(`programa_valoraciones` >= 0 AND `programa_valoraciones` <= 5)
)ENGINE = InnoDB;