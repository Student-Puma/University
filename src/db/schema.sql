-- -----------------------------------------------------
-- Schema
-- -----------------------------------------------------

DROP DATABASE IF EXISTS `tami`;
CREATE DATABASE IF NOT EXISTS `tami` DEFAULT CHARACTER SET utf8;
USE `tami`;

-- -----------------------------------------------------
-- Clientes
-- -----------------------------------------------------

/*
    @table: cliente
    @primary: ID
    @description: Usuario de los programas.
        Realizan compras de licencias, notifican incidencias
        y valoran los productos mediante opiniones. 
*/
CREATE TABLE `cliente` (
  `ID`						INT UNSIGNED NOT NULL AUTO_INCREMENT,   -- clave primaria
  `DNI`                     VARCHAR(9) NOT NULL,                    -- DNI del cliente
  `email`                   VARCHAR(60) NOT NULL,                   -- email de contacto
  `telefono`                VARCHAR(12) NOT NULL,                   -- teléfono de contacto
  `nombre`                  VARCHAR(45) NOT NULL,                   -- nombre del comprador
  `primer_apellido`         VARCHAR(30) NOT NULL,                   -- primer apellido
  `genero`                  CHAR(1) NOT NULL,                       -- género
  `fecha_nacimiento`        DATE NOT NULL,                          -- fecha de nacimiento
  `sector`                  VARCHAR(18) NOT NULL,                   -- sector en el que trabaja
  `empresa`                 VARCHAR(50) NULL,                       -- empresa para la que trabaja (NULL = particular)
  `ultima_actualizacion`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  CONSTRAINT `chk_clie_genero`
    CHECK (`genero` IN ('H','M','O')),
  CONSTRAINT `chk_clie_sector`
    CHECK (`sector` IN ('Estudiante', 'Sector IT', 'Sector Salud', 'Sector Finanzas', 'Sector Turismo', 'Sector Agricultura', 'Sector Transporte', 'Sector Educación', 'Sector Defensa', 'Desempleado', 'Otro'))
)ENGINE = InnoDB;


-- -----------------------------------------------------
-- Empleados
-- -----------------------------------------------------

/*
    @table: empleado
    @primary: ID
    @description: Empleados de la empresa.
        Desarrollan los programas o dirigen los equipos.
*/
CREATE TABLE `empleado` (
  `ID`                      INT UNSIGNED NOT NULL AUTO_INCREMENT,   -- clave primaria
  `DNI`                     VARCHAR(9) NOT NULL,                    -- DNI del empleado
  `NSS`                     VARCHAR(11) NOT NULL,                   -- número de la Seguridad Social
  `nombre`                  VARCHAR(45) NOT NULL,                   -- nombre(s)
  `primer_apellido`         VARCHAR(30) NOT NULL,                   -- primer apellido
  `segundo_apellido`        VARCHAR(30) NULL,                       -- segundo apellido (si tiene)
  `genero`                  CHAR(1) NOT NULL,                       -- género
  `fecha_nacimiento`        DATE NOT NULL,                          -- fecha de nacimiento
  `email`                   VARCHAR(60) NOT NULL,                   -- email corporativo
  `fecha_incorporacion`     DATE NOT NULL,                          -- fecha de incorporación a la empresa
  `puesto`                  VARCHAR(50) NOT NULL,                   -- puesto de trabajo
  `salario`                 INT UNSIGNED NOT NULL,                  -- salario
  `jefe`                    INT UNSIGNED NULL,                      -- responsable directo dentro de la empresa (NULL = directivo)
  `ultima_actualizacion`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  CONSTRAINT `chk_empl_genero`
    CHECK (`genero` IN ('H','M','O'))
)ENGINE = InnoDB;

-- -----------------------------------------------------
-- Proyectos
-- -----------------------------------------------------

/*
    @table: proyecto
    @primary: ID
    @description: Proyecto por el cual se desarrollan programas.
*/
CREATE TABLE `proyecto` (
  `ID`                      INT UNSIGNED NOT NULL AUTO_INCREMENT,   -- clave primaria
  `nombre`                  VARCHAR(45) NOT NULL UNIQUE,            -- nombre del proyecto
  `fecha_inicio`            DATETIME NOT NULL,                      -- fecha de inicio
  `deadline`                DATETIME NOT NULL,                      -- fecha de entrega
  `presupuesto`             DECIMAL(9,2) NOT NULL,                  -- presupuesto aprobado
  `jefe`                    INT UNSIGNED NOT NULL,                  -- jefe de proyecto
  `ultima_actualizacion`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  FOREIGN KEY (`responsable`)
    REFERENCES `empleado` (`ID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_proy_deadline`
    CHECK (`deadline` > `fecha_inicio`)
)ENGINE = InnoDB;

/*
    @table: programa
    @primary: ID
    @description: Programas generados a través de proyectos
*/
CREATE TABLE `programa` (
  `ID`                      INT UNSIGNED NOT NULL AUTO_INCREMENT,   -- clave primaria
  `nombre`                  VARCHAR(45) NOT NULL UNIQUE,            -- nombre del programa
  `proyecto`                INT UNSIGNED NOT NULL,                  -- proyecto del que salió
  `ultima_actualizacion`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  FOREIGN KEY (`proyecto`)
    REFERENCES `proyecto` (`ID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)ENGINE = InnoDB;

/*
    @table: vesion
    @primary: ID
    @description: Versiones de cada programa
*/
CREATE TABLE `version` (
  `ID`						INT UNSIGNED NOT NULL AUTO_INCREMENT,           -- clave primaria
  `programa`                INT UNSIGNED NOT NULL,                          -- programa al que pertenece
  `major`                   INT UNSIGNED NOT NULL,                          -- versionado major
  `minor`                   INT UNSIGNED NOT NULL,                          -- versionado minor
  `patch`                   INT UNSIGNED NOT NULL,                          -- versionado patch
  `os`                      VARCHAR(7) NOT NULL,                            -- sistema operativo soportado (Windows, Mac, Linux, Android, iOS, otro...)
  `arch`                    VARCHAR(6) NOT NULL,                            -- arquitectura soportada (64bit, 32bit, arm, otro...)
  `fecha_lanzamiento`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,    -- fecha de lanzamiento de la versión
  `ultima_actualizacion`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  FOREIGN KEY (`programa`)
    REFERENCES `programa` (`ID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `uq_version`
    UNIQUE (`programa`, `major`, `minor`, `patch`, `os`, `arch`),
  CONSTRAINT `chk_vers_os`
    CHECK (`os` IN ('Windows','Mac','Linux','Android','iOS','otro')),
  CONSTRAINT `chk_vers_arch`
    CHECK (`arch` IN ('amd64','i386','arm','otro'))
)ENGINE = InnoDB;

-- -----------------------------------------------------
-- Ventas
-- -----------------------------------------------------

/*
    @table: licencia
    @primary: ID
    @description: Licencias de programas generadas
*/
CREATE TABLE `licencia` (
  `ID`						INT UNSIGNED NOT NULL AUTO_INCREMENT,   -- clave primaria
  `key`                     VARCHAR(32) NOT NULL,                   -- clave de la licencia
  `programa`                INT UNSIGNED NOT NULL,                  -- programa al que pertenece (se vende por programas, no por versiones)
  `ultima_actualizacion`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  FOREIGN KEY (`programa`)
    REFERENCES `programa` (`ID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)ENGINE = InnoDB;

/*
    @table: licencia_ventas
    @primary: licencia.key
    @description: Ventas de licencias
*/
CREATE TABLE `licencia_venta` (
  `key`						INT UNSIGNED NOT NULL,  -- clave primaria: licencia vendida
  `propietario`             INT UNSIGNED NOT NULL,  -- cliente
  `fecha_expiracion`        DATETIME NOT NULL,      -- fecha de expiración
  `precio`                  DECIMAL(4,2) NOT NULL,  -- precio de venta
  `ultima_actualizacion`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`key`),
  FOREIGN KEY (`propietario`)
    REFERENCES `cliente` (`ID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)ENGINE = InnoDB;

-- -----------------------------------------------------
-- Reportes
-- -----------------------------------------------------

/*
    @table: feedback
    @primary: programa.ID & cliente.ID
    @description: Opiniones de los clientes respecto a los programas
*/
CREATE TABLE `feedback` (
  `programa`                INT UNSIGNED NOT NULL,  -- clave primaria: programa
  `cliente`                 INT UNSIGNED NOT NULL,  -- clave primaria: cliente
  `valoracion`              SMALLINT NOT NULL,      -- satisfacción con el programa
  `comentario`              VARCHAR(200) NULL,      -- comentario opcional
  `ultima_actualizacion`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`programa`, `cliente`),
  FOREIGN KEY (`programa`)
    REFERENCES `programa` (`ID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`cliente`)
    REFERENCES `cliente` (`ID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_feed_valoracion`
    CHECK (`valoracion` >= 1 AND `valoracion` <= 5)
)ENGINE = InnoDB;

/*
    @table: ticket
    @primary: ID
    @description: Problemas con las versiones de los programas
*/
CREATE TABLE `ticket` (
  `ID`                      INT UNSIGNED NOT NULL AUTO_INCREMENT,           -- clave primaria
  `cliente`                 INT UNSIGNED NOT NULL,                          -- cliente
  `version`					INT UNSIGNED NOT NULL,                          -- versión del programa afectado
  `estado`                  VARCHAR(11) NOT NULL DEFAULT 'abierto',         -- estado del ticket
  `titulo`                  VARCHAR(50) NOT NULL,                           -- título del problema
  `descripcion`             VARCHAR(500) NOT NULL,                          -- descripción del problema
  `fecha`                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,    -- fecha de apertura del ticket
  `ultima_actualizacion`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`ID`),
  FOREIGN KEY (`cliente`)
    REFERENCES `cliente` (`ID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`version`)
    REFERENCES `version` (`ID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_estado`
    CHECK (`estado` IN ('abierto','en revisión','cerrado'))
)ENGINE = InnoDB;