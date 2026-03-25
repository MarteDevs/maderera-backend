-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: db_maderera_erp
-- ------------------------------------------------------
-- Server version	9.1.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auditoria`
--

DROP TABLE IF EXISTS `auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria` (
  `id_auditoria` int NOT NULL AUTO_INCREMENT,
  `tabla` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_registro` int NOT NULL,
  `accion` enum('INSERT','UPDATE','DELETE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `valores_antes` text COLLATE utf8mb4_unicode_ci COMMENT 'JSON con valores antes del cambio',
  `valores_despues` text COLLATE utf8mb4_unicode_ci COMMENT 'JSON con valores después del cambio',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IPv4 o IPv6',
  PRIMARY KEY (`id_auditoria`),
  KEY `idx_aud_tabla_fecha` (`tabla`,`fecha` DESC),
  KEY `idx_aud_usuario` (`usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registro completo de cambios críticos';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria`
--

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clasificaciones`
--

DROP TABLE IF EXISTS `clasificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clasificaciones` (
  `id_clasificacion` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '1ª calidad, 2ª, Recuperación, Mixto, etc.',
  `descripcion` text COLLATE utf8mb4_unicode_ci COMMENT 'Descripción detallada de la clasificación',
  `activo` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL COMMENT 'Soft delete',
  PRIMARY KEY (`id_clasificacion`),
  UNIQUE KEY `uk_nombre_clasif` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clasificaciones`
--

LOCK TABLES `clasificaciones` WRITE;
/*!40000 ALTER TABLE `clasificaciones` DISABLE KEYS */;
INSERT INTO `clasificaciones` VALUES (1,'1ª Calidad','Poste premium: recto, sin grietas profundas, nudos pequeños y sanos, diámetro uniforme, ideal para sostenimiento principal en galerías y cruces críticos. Generalmente eucalipto o pino tratado CCA.',1,NULL),(2,'2ª Calidad','Buena calidad: permite nudos medianos, ligeras curvaturas o defectos superficiales no estructurales. Apto para sostenimientos secundarios, refuerzos y zonas de menor carga.',1,NULL),(3,'3ª Calidad / Recuperación','Postes con defectos visibles (nudos grandes, rajaduras moderadas, algo de conicidad irregular). Usado en zonas de bajo riesgo, refuerzos temporales o como \"mixto\" en lotes.',1,NULL),(4,'Mixto / Variado','Lote heterogéneo con mezcla de 1ª, 2ª y recuperación. Común en compras al por mayor sin selección estricta. Requiere inspección adicional al recibir.',1,NULL),(5,'Rechazado / No Apto','Postes con defectos graves (torcedura excesiva, pudrición incipiente, grietas profundas, diámetro insuficiente). No se usan en minería; devolución o uso alternativo (leña, etc.).',1,NULL),(6,'Tratado CCA Premium','Poste impregnado con sales CCA (Cobre-Cromo-Arsénico) de alta calidad. Mayor durabilidad (10+ años), resistente a hongos e insectos. Preferido en minas húmedas.',1,NULL),(7,'Sin Tratar / Natural','Poste en estado natural, sin impregnación. Vida útil más corta (3-6 años según condiciones). Más económico, pero requiere rotación frecuente.',1,NULL),(8,'Madera General','Clasificación default',1,NULL);
/*!40000 ALTER TABLE `clasificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `despacho_detalles`
--

DROP TABLE IF EXISTS `despacho_detalles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `despacho_detalles` (
  `id_despacho_detalle` int NOT NULL AUTO_INCREMENT,
  `id_despacho` int NOT NULL,
  `id_producto` int NOT NULL,
  `id_medida` int NOT NULL,
  `cantidad_despachada` int NOT NULL,
  `observacion` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_despacho_detalle`),
  KEY `fk_ddet_med` (`id_medida`),
  KEY `idx_ddet_despacho` (`id_despacho`),
  KEY `idx_ddet_producto` (`id_producto`),
  CONSTRAINT `fk_ddet_dsp` FOREIGN KEY (`id_despacho`) REFERENCES `despachos` (`id_despacho`) ON DELETE CASCADE,
  CONSTRAINT `fk_ddet_med` FOREIGN KEY (`id_medida`) REFERENCES `medidas` (`id_medida`),
  CONSTRAINT `fk_ddet_prod` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `despacho_detalles_chk_1` CHECK ((`cantidad_despachada` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `despacho_detalles`
--

LOCK TABLES `despacho_detalles` WRITE;
/*!40000 ALTER TABLE `despacho_detalles` DISABLE KEYS */;
INSERT INTO `despacho_detalles` VALUES (1,1,13,10,19,'','2026-02-10 14:31:37','2026-02-10 14:31:37','admin',NULL),(2,2,25,22,50,'','2026-02-10 14:35:48','2026-02-10 14:35:48','admin',NULL),(3,2,12,9,19,'','2026-02-10 14:35:48','2026-02-10 14:35:48','admin',NULL),(4,3,12,9,15,'','2026-02-10 23:45:40','2026-02-10 23:45:40','admin',NULL),(5,4,13,10,50,'','2026-02-19 20:24:37','2026-02-19 20:24:37','admin',NULL),(6,4,4,2,50,'','2026-02-19 20:24:37','2026-02-19 20:24:37','admin',NULL),(7,5,10,7,150,'','2026-02-19 20:29:34','2026-02-19 20:29:34','admin',NULL),(8,6,10,7,100,'','2026-03-24 02:21:45','2026-03-24 02:21:45','admin',NULL);
/*!40000 ALTER TABLE `despacho_detalles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `despachos`
--

DROP TABLE IF EXISTS `despachos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `despachos` (
  `id_despacho` int NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Ej: DSP-2025-0001',
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `fecha_salida` datetime DEFAULT NULL COMMENT 'Cuando cambia a EN_TRANSITO',
  `fecha_entrega` datetime DEFAULT NULL COMMENT 'Cuando cambia a ENTREGADO',
  `id_mina` int NOT NULL,
  `id_supervisor` int DEFAULT NULL COMMENT 'Supervisor que recibe en mina',
  `id_viaje` int DEFAULT NULL COMMENT 'Viaje que trajo esta madera (opcional para trazabilidad)',
  `estado` enum('PREPARANDO','EN_TRANSITO','ENTREGADO','ANULADO') COLLATE utf8mb4_unicode_ci DEFAULT 'PREPARANDO',
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  `motivo_anulacion` text COLLATE utf8mb4_unicode_ci COMMENT 'Obligatorio si estado=ANULADO',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero_vale` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_despacho`),
  UNIQUE KEY `codigo` (`codigo`),
  KEY `fk_dsp_sup` (`id_supervisor`),
  KEY `idx_dsp_fecha` (`fecha_creacion` DESC),
  KEY `idx_dsp_mina` (`id_mina`),
  KEY `idx_dsp_estado` (`estado`),
  KEY `idx_dsp_viaje` (`id_viaje`),
  CONSTRAINT `fk_dsp_mina` FOREIGN KEY (`id_mina`) REFERENCES `minas` (`id_mina`),
  CONSTRAINT `fk_dsp_sup` FOREIGN KEY (`id_supervisor`) REFERENCES `supervisores` (`id_supervisor`),
  CONSTRAINT `fk_dsp_viaje` FOREIGN KEY (`id_viaje`) REFERENCES `viajes` (`id_viaje`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `despachos`
--

LOCK TABLES `despachos` WRITE;
/*!40000 ALTER TABLE `despachos` DISABLE KEYS */;
INSERT INTO `despachos` VALUES (1,'DSP-2026-0001','2026-02-10 14:31:37','2026-02-11 16:54:17','2026-02-11 16:54:19',5,12,NULL,'ENTREGADO','',NULL,'2026-02-10 14:31:37','2026-02-11 11:54:19','admin','admin',NULL),(2,'DSP-2026-0002','2026-02-10 14:35:48','2026-02-10 14:41:20','2026-02-10 14:41:48',9,4,NULL,'ENTREGADO','',NULL,'2026-02-10 14:35:48','2026-02-10 09:41:48','admin','admin',NULL),(3,'DSP-2026-0003','2026-02-10 23:45:39','2026-02-11 16:54:00','2026-02-11 16:54:03',4,12,NULL,'ENTREGADO','',NULL,'2026-02-10 23:45:39','2026-02-11 11:54:03','admin','admin',NULL),(4,'DSP-2026-0004','2026-02-18 00:00:00',NULL,NULL,2,11,NULL,'PREPARANDO','',NULL,'2026-02-19 20:24:37','2026-02-19 20:24:37','admin',NULL,'122312'),(5,'DSP-2026-0005','2026-02-19 00:00:00','2026-02-19 20:29:40','2026-02-19 20:45:29',12,5,NULL,'ENTREGADO','',NULL,'2026-02-19 20:29:34','2026-02-19 15:45:29','admin','admin','1234567'),(6,'DSP-2026-0006','2026-03-24 00:00:00','2026-03-24 02:22:06','2026-03-24 02:22:14',2,9,NULL,'ENTREGADO','data',NULL,'2026-03-24 02:21:45','2026-03-23 21:22:14','admin','admin','001-155');
/*!40000 ALTER TABLE `despachos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medidas`
--

DROP TABLE IF EXISTS `medidas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medidas` (
  `id_medida` int NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Ej: "2.20 m x 7-9 cm Ø"',
  `largo_mts` decimal(6,3) DEFAULT NULL,
  `diametro_min_cm` decimal(5,2) DEFAULT NULL,
  `diametro_max_cm` decimal(5,2) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_medida`),
  UNIQUE KEY `uk_descripcion_med` (`descripcion`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medidas`
--

LOCK TABLES `medidas` WRITE;
/*!40000 ALTER TABLE `medidas` DISABLE KEYS */;
INSERT INTO `medidas` VALUES (1,'2.40 MTS',NULL,NULL,NULL,NULL),(2,'3.00 MTS',NULL,NULL,NULL,NULL),(3,'8 Pulg x 1.50 MTS',NULL,NULL,NULL,NULL),(4,'1.50 MTS x 8',NULL,NULL,NULL,NULL),(5,'1.80 MTS x 6',NULL,NULL,NULL,NULL),(6,'1.80 MTS x 7',NULL,NULL,NULL,NULL),(7,'1.80 MTS x 8',NULL,NULL,NULL,NULL),(8,'2.00 MTS x 6',NULL,NULL,NULL,NULL),(9,'2.00 MTS x 7',NULL,NULL,NULL,NULL),(10,'2.00 MTS x 8',NULL,NULL,NULL,NULL),(11,'2.20 MTS x 6',NULL,NULL,NULL,NULL),(12,'2.20 MTS x 7',NULL,NULL,NULL,NULL),(13,'2.20 MTS x 8',NULL,NULL,NULL,NULL),(14,'2.40 MTS x 5',NULL,NULL,NULL,NULL),(15,'2.40 MTS x 6',NULL,NULL,NULL,NULL),(16,'2.40 MTS x 7',NULL,NULL,NULL,NULL),(17,'2.40 MTS x 8',NULL,NULL,NULL,NULL),(18,'2.40 MTS x 9',NULL,NULL,NULL,NULL),(19,'3.00 MTS x 6',NULL,NULL,NULL,NULL),(20,'3.00 MTS x 7',NULL,NULL,NULL,NULL),(21,'3.00 MTS x 8',NULL,NULL,NULL,NULL),(22,'3.00 MTS x 9',NULL,NULL,NULL,NULL),(23,'4.00 MTS x 7',NULL,NULL,NULL,NULL),(24,'4.00 MTS x 8',NULL,NULL,NULL,NULL),(25,'4.00 MTS x 9',NULL,NULL,NULL,NULL),(26,'4x6',NULL,NULL,NULL,NULL),(27,'3 MTS x 20CM x 1',NULL,NULL,NULL,NULL),(28,'3 MTS x 20CM x 2',NULL,NULL,NULL,NULL),(29,'6 MTS x 6',NULL,NULL,NULL,NULL),(30,'6.50 MTS',NULL,NULL,NULL,NULL),(31,'4.00 MTS',NULL,NULL,NULL,NULL),(32,'Metro Cubico',1.000,10.00,20.00,NULL),(33,'10\"X3.5\"2MTS',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `medidas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `minas`
--

DROP TABLE IF EXISTS `minas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `minas` (
  `id_mina` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `razon_social` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ruc` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ubicacion` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contacto` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_mina`),
  UNIQUE KEY `uk_nombre_mina` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `minas`
--

LOCK TABLES `minas` WRITE;
/*!40000 ALTER TABLE `minas` DISABLE KEYS */;
INSERT INTO `minas` VALUES (1,'MANGALPA','VANIA','10443779146',NULL,NULL,NULL),(2,'ESPERANZA','MARVIN','10442184301',NULL,NULL,NULL),(3,'MANZANAS','TMSI','20539950551',NULL,NULL,NULL),(4,'FRANCES','ROBERT','10443688302',NULL,NULL,NULL),(5,'GUADALUPE','LUZDINA','10442841646',NULL,NULL,NULL),(6,'ORMASAN','MARYLIN','10465613080',NULL,NULL,NULL),(7,'SOLEDAD','VICTOR','10403673159',NULL,NULL,NULL),(8,'IRACACUCHO 2','ROY','10703165775',NULL,NULL,NULL),(9,'IRACACUCHO 1','CUARZO','20606112492',NULL,NULL,NULL),(10,'SHIHUAPATA','RUFINO ALONSO','10804704901',NULL,NULL,NULL),(11,'PORFIA 2','VANIA','10443779146',NULL,NULL,NULL),(12,'CANTERA CHAGUAL','VICTOR','10403673159',NULL,NULL,NULL),(13,'Mina Test 2','Test 2','12345678911','PATAZ','72124568',NULL);
/*!40000 ALTER TABLE `minas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimientos_stock`
--

DROP TABLE IF EXISTS `movimientos_stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimientos_stock` (
  `id_movimiento` int NOT NULL AUTO_INCREMENT,
  `id_producto` int NOT NULL,
  `tipo` enum('ENTRADA','SALIDA','AJUSTE_POS','AJUSTE_NEG','DEVOLUCION','AJUSTE_MANUAL') COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` int NOT NULL,
  `id_viaje` int DEFAULT NULL,
  `id_despacho` int DEFAULT NULL,
  `id_requerimiento` int DEFAULT NULL,
  `id_detalle_req` int DEFAULT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `usuario_registro` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Quién registró (para auditoría rápida)',
  `observacion` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_movimiento`),
  KEY `idx_mov_prod_fecha` (`id_producto`,`fecha` DESC),
  KEY `idx_mov_viaje` (`id_viaje`),
  KEY `idx_mov_tipo` (`tipo`),
  KEY `fk_mov_det` (`id_detalle_req`),
  KEY `fk_mov_req` (`id_requerimiento`),
  KEY `idx_mov_despacho` (`id_despacho`),
  CONSTRAINT `fk_mov_det` FOREIGN KEY (`id_detalle_req`) REFERENCES `requerimiento_detalles` (`id_detalle`),
  CONSTRAINT `fk_mov_dsp` FOREIGN KEY (`id_despacho`) REFERENCES `despachos` (`id_despacho`) ON DELETE SET NULL,
  CONSTRAINT `fk_mov_prod` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `fk_mov_req` FOREIGN KEY (`id_requerimiento`) REFERENCES `requerimientos` (`id_requerimiento`) ON DELETE SET NULL,
  CONSTRAINT `fk_mov_via` FOREIGN KEY (`id_viaje`) REFERENCES `viajes` (`id_viaje`),
  CONSTRAINT `movimientos_stock_chk_1` CHECK ((`cantidad` <> 0))
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimientos_stock`
--

LOCK TABLES `movimientos_stock` WRITE;
/*!40000 ALTER TABLE `movimientos_stock` DISABLE KEYS */;
INSERT INTO `movimientos_stock` VALUES (1,12,'ENTRADA',50,3,NULL,2,3,'2026-02-07 00:20:49','admin','Recepción Viaje #3 - ','2026-02-07 00:20:49','2026-02-07 00:20:49','admin',NULL),(2,25,'ENTRADA',15,3,NULL,2,4,'2026-02-07 00:20:49','admin','Recepción Viaje #3 - ','2026-02-07 00:20:49','2026-02-07 00:20:49','admin',NULL),(3,12,'ENTRADA',50,4,NULL,2,3,'2026-02-07 00:36:20','admin','Recepción Viaje #4 - ','2026-02-07 00:36:20','2026-02-07 00:36:20','admin',NULL),(4,25,'ENTRADA',35,4,NULL,2,4,'2026-02-07 00:36:20','admin','Recepción Viaje #4 - ','2026-02-07 00:36:20','2026-02-07 00:36:20','admin',NULL),(5,12,'ENTRADA',15,5,NULL,5,8,'2026-02-07 00:41:00','admin','Recepción Viaje #5 - ','2026-02-07 00:41:00','2026-02-07 00:41:00','admin',NULL),(6,13,'ENTRADA',15,6,NULL,5,9,'2026-02-07 00:46:03','admin','Recepción Viaje #6 - ','2026-02-07 00:46:03','2026-02-07 00:46:03','admin',NULL),(7,13,'ENTRADA',4,7,NULL,5,9,'2026-02-07 00:46:15','admin','Recepción Viaje #7 - ','2026-02-07 00:46:15','2026-02-07 00:46:15','admin',NULL),(8,10,'ENTRADA',18,8,NULL,8,14,'2026-02-09 14:57:07','admin','Recepción Viaje #8 - ','2026-02-09 14:57:07','2026-02-09 14:57:07','admin',NULL),(9,12,'ENTRADA',1,9,NULL,8,15,'2026-02-09 15:02:12','admin','Recepción Viaje #9 - ','2026-02-09 15:02:12','2026-02-09 15:02:12','admin',NULL),(10,25,'SALIDA',-50,NULL,2,NULL,NULL,'2026-02-10 14:41:20','admin','Despacho DSP-2026-0002 - Salida a mina','2026-02-10 14:41:20','2026-02-10 14:41:20','admin',NULL),(11,12,'SALIDA',-19,NULL,2,NULL,NULL,'2026-02-10 14:41:20','admin','Despacho DSP-2026-0002 - Salida a mina','2026-02-10 14:41:20','2026-02-10 14:41:20','admin',NULL),(12,12,'SALIDA',-15,NULL,3,NULL,NULL,'2026-02-11 16:54:00','admin','Despacho DSP-2026-0003 - Salida a mina','2026-02-11 16:54:00','2026-02-11 16:54:00','admin',NULL),(13,13,'SALIDA',-19,NULL,1,NULL,NULL,'2026-02-11 16:54:17','admin','Despacho DSP-2026-0001 - Salida a mina','2026-02-11 16:54:17','2026-02-11 16:54:17','admin',NULL),(14,3,'ENTRADA',15,10,NULL,15,26,'2026-02-16 00:11:43','admin','Recepción Viaje #10 - ','2026-02-16 00:11:43','2026-02-16 00:11:43','admin',NULL),(15,3,'ENTRADA',16,10,NULL,15,27,'2026-02-16 00:11:43','admin','Recepción Viaje #10 - ','2026-02-16 00:11:43','2026-02-16 00:11:43','admin',NULL),(16,13,'ENTRADA',100,11,NULL,14,24,'2026-02-16 20:57:44','admin','Recepción Viaje #11 - ','2026-02-16 20:57:44','2026-02-16 20:57:44','admin',NULL),(17,4,'ENTRADA',100,11,NULL,14,25,'2026-02-16 20:57:44','admin','Recepción Viaje #11 - ','2026-02-16 20:57:44','2026-02-16 20:57:44','admin',NULL),(18,26,'ENTRADA',1,12,NULL,13,23,'2026-02-16 20:59:28','admin','Recepción Viaje #12 - ','2026-02-16 20:59:28','2026-02-16 20:59:28','admin',NULL),(19,10,'ENTRADA',150,13,NULL,12,22,'2026-02-16 21:04:18','admin','Recepción Viaje #13 - ','2026-02-16 21:04:18','2026-02-16 21:04:18','admin',NULL),(20,10,'ENTRADA',5,14,NULL,12,22,'2026-02-16 21:04:59','admin','Recepción Viaje #14 - ','2026-02-16 21:04:59','2026-02-16 21:04:59','admin',NULL),(21,10,'ENTRADA',50,15,NULL,12,22,'2026-02-16 21:16:25','admin','Recepción Viaje #15 - ','2026-02-16 21:16:25','2026-02-16 21:16:25','admin',NULL),(22,10,'ENTRADA',50,16,NULL,12,22,'2026-02-16 21:17:22','admin','Recepción Viaje #16 - ','2026-02-16 21:17:22','2026-02-16 21:17:22','admin',NULL),(23,12,'ENTRADA',150,17,NULL,11,21,'2026-02-19 20:01:11','admin','Recepción Viaje #17 - ','2026-02-19 20:01:11','2026-02-19 20:01:11','admin',NULL),(24,10,'ENTRADA',100,18,NULL,3,5,'2026-02-19 20:08:46','admin','Recepción Viaje #18 - ','2026-02-19 20:08:46','2026-02-19 20:08:46','admin',NULL),(25,10,'SALIDA',-150,NULL,5,NULL,NULL,'2026-02-19 20:29:40','admin','Despacho DSP-2026-0005 - Salida a mina','2026-02-19 20:29:40','2026-02-19 20:29:40','admin',NULL),(26,17,'ENTRADA',150,19,NULL,10,18,'2026-02-19 20:48:04','admin','Recepción Viaje #19 - ','2026-02-19 20:48:04','2026-02-19 20:48:04','admin',NULL),(27,16,'ENTRADA',100,19,NULL,10,19,'2026-02-19 20:48:04','admin','Recepción Viaje #19 - ','2026-02-19 20:48:04','2026-02-19 20:48:04','admin',NULL),(28,10,'ENTRADA',1,19,NULL,10,20,'2026-02-19 20:48:04','admin','Recepción Viaje #19 - ','2026-02-19 20:48:04','2026-02-19 20:48:04','admin',NULL),(29,6,'ENTRADA',50,21,NULL,17,NULL,'2026-03-24 02:13:27','admin','Ingreso por viaje 100-112','2026-03-24 02:13:27','2026-03-23 21:36:05','admin',NULL),(30,27,'ENTRADA',25,21,NULL,17,NULL,'2026-03-24 02:13:27','admin','Ingreso por viaje 100-112','2026-03-24 02:13:27','2026-03-23 21:36:05','admin',NULL),(31,10,'SALIDA',-100,NULL,6,NULL,NULL,'2026-03-24 02:22:06','admin','Despacho DSP-2026-0006 - Salida a mina','2026-03-24 02:22:06','2026-03-24 02:22:06','admin',NULL),(32,6,'ENTRADA',50,22,NULL,17,NULL,'2026-03-24 02:34:22','admin','Ingreso por viaje S/N','2026-03-24 02:34:22','2026-03-23 21:36:05','admin',NULL),(33,27,'ENTRADA',25,22,NULL,17,NULL,'2026-03-24 02:34:22','admin','Ingreso por viaje S/N','2026-03-24 02:34:22','2026-03-23 21:36:05','admin',NULL),(34,3,'ENTRADA',10,23,NULL,16,NULL,'2026-03-24 02:37:23','admin','Ingreso por viaje 121232','2026-03-24 02:37:23','2026-03-24 02:37:23','admin',NULL);
/*!40000 ALTER TABLE `movimientos_stock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_history`
--

DROP TABLE IF EXISTS `password_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_history` (
  `id_history` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_cambio` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_history`),
  KEY `idx_hist_user` (`id_usuario`,`fecha_cambio` DESC),
  CONSTRAINT `fk_passhist_user` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_history`
--

LOCK TABLES `password_history` WRITE;
/*!40000 ALTER TABLE `password_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `precio_historico`
--

DROP TABLE IF EXISTS `precio_historico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `precio_historico` (
  `id_historico` int NOT NULL AUTO_INCREMENT,
  `id_catalogo` int NOT NULL,
  `precio_anterior` decimal(10,2) NOT NULL,
  `precio_nuevo` decimal(10,2) NOT NULL,
  `fecha_cambio` datetime DEFAULT CURRENT_TIMESTAMP,
  `usuario_cambio` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_historico`),
  KEY `idx_hist_fecha` (`id_catalogo`,`fecha_cambio` DESC),
  CONSTRAINT `fk_hist_cat` FOREIGN KEY (`id_catalogo`) REFERENCES `producto_proveedores` (`id_catalogo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Auditoría de cambios de precios';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `precio_historico`
--

LOCK TABLES `precio_historico` WRITE;
/*!40000 ALTER TABLE `precio_historico` DISABLE KEYS */;
/*!40000 ALTER TABLE `precio_historico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto_proveedores`
--

DROP TABLE IF EXISTS `producto_proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto_proveedores` (
  `id_catalogo` int NOT NULL AUTO_INCREMENT,
  `id_proveedor` int NOT NULL,
  `id_producto` int NOT NULL,
  `precio_compra_sugerido` decimal(10,2) NOT NULL,
  `fecha_actualizacion` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `activo` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_catalogo`),
  UNIQUE KEY `uk_prod_prov_unique` (`id_proveedor`,`id_producto`),
  KEY `fk_cat_prod` (`id_producto`),
  KEY `idx_cat_proveedor` (`id_proveedor`,`activo`),
  CONSTRAINT `fk_cat_prod` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `fk_cat_prov` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`),
  CONSTRAINT `producto_proveedores_chk_1` CHECK ((`precio_compra_sugerido` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto_proveedores`
--

LOCK TABLES `producto_proveedores` WRITE;
/*!40000 ALTER TABLE `producto_proveedores` DISABLE KEYS */;
INSERT INTO `producto_proveedores` VALUES (18,1,29,27.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(19,1,30,29.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(24,1,22,39.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(25,1,23,55.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(26,1,24,55.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(27,1,25,55.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(29,1,26,67.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(30,1,27,67.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(31,1,28,67.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(32,1,32,57.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(33,1,31,50.00,'2026-02-05 12:45:47',1,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(64,8,36,50.00,'2026-02-05 19:32:39',1,'2026-02-05 19:32:39','2026-02-05 19:32:39',NULL,NULL,NULL),(66,1,2,14.00,'2026-02-09 13:08:35',1,'2026-02-09 13:08:35','2026-02-09 13:08:35',NULL,NULL,NULL),(67,1,3,35.00,'2026-02-09 13:08:41',1,'2026-02-09 13:08:41','2026-02-09 13:08:41',NULL,NULL,NULL),(68,1,4,60.00,'2026-02-09 13:23:44',1,'2026-02-09 13:23:44','2026-02-09 13:23:44',NULL,NULL,NULL),(69,1,5,17.00,'2026-02-09 13:23:54',1,'2026-02-09 13:23:54','2026-02-09 13:23:54',NULL,NULL,NULL),(70,1,6,19.00,'2026-02-09 13:24:02',1,'2026-02-09 13:24:02','2026-02-09 13:24:02',NULL,NULL,NULL),(71,1,33,21.00,'2026-02-09 13:24:28',1,'2026-02-09 13:24:28','2026-02-09 13:24:28',NULL,NULL,NULL),(72,1,34,17.00,'2026-02-09 13:27:41',1,'2026-02-09 13:27:41','2026-02-09 13:27:41',NULL,NULL,NULL),(73,1,35,1.00,'2026-02-09 13:27:48',1,'2026-02-09 13:27:48','2026-02-09 13:27:48',NULL,NULL,NULL),(74,1,7,25.00,'2026-02-09 13:28:00',1,'2026-02-09 13:28:00','2026-02-09 13:28:00',NULL,NULL,NULL),(75,1,8,24.00,'2026-02-09 13:28:04',1,'2026-02-09 13:28:04','2026-02-09 13:28:04',NULL,NULL,NULL),(76,1,9,23.00,'2026-02-09 13:28:08',1,'2026-02-09 13:28:08','2026-02-09 13:28:08',NULL,NULL,NULL),(77,1,10,23.00,'2026-02-09 13:28:13',1,'2026-02-09 13:28:13','2026-02-09 13:28:13',NULL,NULL,NULL),(78,1,11,28.00,'2026-02-09 13:28:17',1,'2026-02-09 13:28:17','2026-02-09 13:28:17',NULL,NULL,NULL),(79,1,12,33.00,'2026-02-09 13:28:21',1,'2026-02-09 13:28:21','2026-02-09 13:28:21',NULL,NULL,NULL),(80,1,14,30.00,'2026-02-09 13:28:26',1,'2026-02-09 13:28:26','2026-02-09 13:28:26',NULL,NULL,NULL),(81,1,13,33.00,'2026-02-09 13:28:31',1,'2026-02-09 13:28:31','2026-02-09 13:28:31',NULL,NULL,NULL),(82,1,15,35.00,'2026-02-09 13:28:38',1,'2026-02-09 13:28:38','2026-02-09 13:28:38',NULL,NULL,NULL),(83,1,16,35.00,'2026-02-09 13:28:43',1,'2026-02-09 13:28:43','2026-02-09 13:28:43',NULL,NULL,NULL),(84,1,17,23.00,'2026-02-09 13:51:25',1,'2026-02-09 13:51:25','2026-02-09 13:51:25',NULL,NULL,NULL),(85,1,18,24.00,'2026-02-09 13:51:30',1,'2026-02-09 13:51:30','2026-02-09 13:51:30',NULL,NULL,NULL),(86,1,19,38.00,'2026-02-09 13:51:34',1,'2026-02-09 13:51:34','2026-02-09 13:51:34',NULL,NULL,NULL),(87,1,20,38.00,'2026-02-09 13:51:42',1,'2026-02-09 13:51:42','2026-02-09 13:51:42',NULL,NULL,NULL),(88,1,21,51.00,'2026-02-09 19:46:37',1,'2026-02-09 19:46:37','2026-02-09 19:46:37',NULL,NULL,NULL);
/*!40000 ALTER TABLE `producto_proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_medida` int NOT NULL,
  `id_clasificacion` int DEFAULT NULL,
  `precio_venta_base` decimal(10,2) DEFAULT '0.00',
  `stock_actual` int DEFAULT '0' COMMENT 'Cache – modificar solo vía triggers',
  `observaciones` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_producto`),
  KEY `fk_prod_medida` (`id_medida`),
  KEY `fk_prod_clasificacion` (`id_clasificacion`),
  KEY `idx_prod_nombre` (`nombre`),
  KEY `idx_prod_stock` (`stock_actual`),
  CONSTRAINT `fk_prod_clasificacion` FOREIGN KEY (`id_clasificacion`) REFERENCES `clasificaciones` (`id_clasificacion`),
  CONSTRAINT `fk_prod_medida` FOREIGN KEY (`id_medida`) REFERENCES `medidas` (`id_medida`),
  CONSTRAINT `chk_stock_positivo` CHECK ((`stock_actual` >= 0)),
  CONSTRAINT `productos_chk_1` CHECK ((`precio_venta_base` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'CANTONERAS Updated',1,8,100.00,0,'cantoneras','2026-02-05 12:45:47','2026-02-10 14:14:41',NULL,'admin','2026-02-10 14:14:41'),(2,'CANTONERAS',2,8,18.00,0,'','2026-02-05 12:45:47','2026-02-09 13:08:35',NULL,'admin',NULL),(3,'DURMIENTE',3,8,40.00,41,'','2026-02-05 12:45:47','2026-03-23 21:37:23',NULL,'admin',NULL),(4,'ESCALERA',2,8,72.00,100,'','2026-02-05 12:45:47','2026-02-16 15:57:43',NULL,'admin',NULL),(5,'MARCHABANTES',1,8,19.00,0,'','2026-02-05 12:45:47','2026-02-09 13:23:54',NULL,'admin',NULL),(6,'MARCHABANTES',2,8,22.00,100,'','2026-02-05 12:45:47','2026-03-23 21:36:05',NULL,'admin',NULL),(7,'POSTES',4,8,27.00,0,'','2026-02-05 12:45:47','2026-02-09 13:28:00',NULL,'admin',NULL),(8,'POSTES',6,8,26.00,0,'','2026-02-05 12:45:47','2026-02-09 13:28:04',NULL,'admin',NULL),(9,'POSTES',5,8,26.00,0,'','2026-02-05 12:45:47','2026-02-09 13:28:08',NULL,'admin',NULL),(10,'POSTES',7,8,26.00,124,'','2026-02-05 12:45:47','2026-03-23 21:22:06',NULL,'admin',NULL),(11,'POSTES',8,8,0.00,0,'','2026-02-05 12:45:47','2026-02-09 13:28:17',NULL,'admin',NULL),(12,'POSTES',9,8,38.00,232,'','2026-02-05 12:45:47','2026-02-19 15:01:11',NULL,'admin',NULL),(13,'POSTES',10,8,38.00,100,'','2026-02-05 12:45:47','2026-02-16 15:57:43',NULL,'admin',NULL),(14,'POSTES',11,8,0.00,0,'','2026-02-05 12:45:47','2026-02-09 13:28:26',NULL,'admin',NULL),(15,'POSTES',12,8,41.00,0,'','2026-02-05 12:45:47','2026-02-09 13:28:38',NULL,'admin',NULL),(16,'POSTES',13,8,41.00,100,'','2026-02-05 12:45:47','2026-02-19 15:48:03',NULL,'admin',NULL),(17,'POSTES',14,8,34.00,150,'','2026-02-05 12:45:47','2026-02-19 15:48:03',NULL,'admin',NULL),(18,'POSTES',15,8,34.00,0,'','2026-02-05 12:45:47','2026-02-09 13:51:30',NULL,'admin',NULL),(19,'POSTES',16,8,42.00,0,'','2026-02-05 12:45:47','2026-02-09 13:51:34',NULL,'admin',NULL),(20,'POSTES',17,8,42.00,0,'','2026-02-05 12:45:47','2026-02-09 13:51:42',NULL,'admin',NULL),(21,'POSTES',18,8,50.00,0,'','2026-02-05 12:45:47','2026-02-09 19:46:37',NULL,'admin',NULL),(22,'POSTES',19,NULL,44.00,0,NULL,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(23,'POSTES',20,NULL,60.00,0,NULL,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(24,'POSTES',21,NULL,60.00,0,NULL,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(25,'POSTES',22,NULL,60.00,0,NULL,'2026-02-05 12:45:47','2026-02-10 09:41:20',NULL,NULL,NULL),(26,'POSTES',23,NULL,72.00,1,NULL,'2026-02-05 12:45:47','2026-02-16 15:59:28',NULL,NULL,NULL),(27,'POSTES',24,NULL,72.00,50,NULL,'2026-02-05 12:45:47','2026-03-23 21:36:05',NULL,NULL,NULL),(28,'POSTES',25,NULL,72.00,0,NULL,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(29,'TABLAS',27,NULL,30.00,0,NULL,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(30,'TABLAS',28,NULL,32.00,0,NULL,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(31,'VIGAS DE MADERA',29,NULL,55.00,0,NULL,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(32,'POSTES',26,NULL,62.00,0,NULL,'2026-02-05 12:45:47','2026-02-05 12:45:47',NULL,NULL,NULL),(33,'PARANTES',30,8,22.00,0,'','2026-02-05 12:45:47','2026-02-09 13:24:28',NULL,'admin',NULL),(34,'PARANTES',31,8,18.00,0,'','2026-02-05 12:45:47','2026-02-09 13:27:41',NULL,'admin',NULL),(35,'PARANTES DELGADOS',2,8,10.00,0,'','2026-02-05 12:45:47','2026-02-09 13:27:48',NULL,'admin',NULL),(36,'Eucalipto Test',32,8,0.00,0,NULL,'2026-02-05 19:32:39','2026-02-10 14:15:00',NULL,'admin','2026-02-10 14:15:00'),(37,'POSTES',33,NULL,0.00,0,'','2026-02-12 23:21:11','2026-02-12 23:21:11','admin','admin',NULL),(38,'TABLON  ',33,8,0.00,0,'','2026-02-12 23:22:33','2026-02-12 23:22:33','admin','admin',NULL),(39,'TABLONES',33,8,0.00,0,'','2026-02-12 23:26:09','2026-02-12 23:26:09','admin','admin',NULL);
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedores` (
  `id_proveedor` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `razon_social` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Agregado para consistencia',
  `ruc` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contacto` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_proveedor`),
  UNIQUE KEY `uk_nombre_prov` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
INSERT INTO `proveedores` VALUES (1,'CARBAJAL',NULL,NULL,NULL,NULL,NULL),(2,'MOTIL',NULL,NULL,NULL,NULL,NULL),(3,'AL PATAZ',NULL,NULL,NULL,NULL,NULL),(4,'BAILON',NULL,NULL,NULL,NULL,NULL),(5,'MEZA',NULL,NULL,NULL,NULL,NULL),(6,'LLAJARUNA',NULL,NULL,NULL,NULL,NULL),(7,'DEPOSITO',NULL,NULL,NULL,NULL,NULL),(8,'Proveedor Test',NULL,'20123456789',NULL,NULL,'2026-02-07 03:23:39'),(9,'MARCO','MARCO','12345678911','MARCO','956431103',NULL);
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `requerimiento_detalles`
--

DROP TABLE IF EXISTS `requerimiento_detalles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `requerimiento_detalles` (
  `id_detalle` int NOT NULL AUTO_INCREMENT,
  `id_requerimiento` int NOT NULL,
  `id_producto` int NOT NULL,
  `cantidad_solicitada` int NOT NULL,
  `cantidad_entregada` int DEFAULT '0',
  `unidad_medida` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'UND',
  `precio_proveedor` decimal(10,2) NOT NULL,
  `precio_mina` decimal(10,2) NOT NULL COMMENT 'Validado por trigger: debe ser >= precio_proveedor',
  `observacion` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `idx_det_producto` (`id_producto`),
  KEY `idx_det_req` (`id_requerimiento`),
  CONSTRAINT `fk_det_prod` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `fk_det_req` FOREIGN KEY (`id_requerimiento`) REFERENCES `requerimientos` (`id_requerimiento`) ON DELETE CASCADE,
  CONSTRAINT `requerimiento_detalles_chk_1` CHECK ((`cantidad_solicitada` > 0)),
  CONSTRAINT `requerimiento_detalles_chk_2` CHECK ((`cantidad_entregada` >= 0)),
  CONSTRAINT `requerimiento_detalles_chk_3` CHECK ((`precio_proveedor` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `requerimiento_detalles`
--

LOCK TABLES `requerimiento_detalles` WRITE;
/*!40000 ALTER TABLE `requerimiento_detalles` DISABLE KEYS */;
INSERT INTO `requerimiento_detalles` VALUES (1,1,9,1,1,'UND',23.00,26.00,'ninguna','2026-02-06 22:05:45','2026-02-06 17:26:13','1',NULL),(2,1,12,1,1,'UND',33.00,38.00,'ninguna','2026-02-06 22:05:45','2026-02-06 19:12:15','1',NULL),(3,2,12,100,100,'UND',33.00,38.00,'','2026-02-07 00:19:43','2026-02-06 19:36:19','1',NULL),(4,2,25,50,50,'UND',55.00,60.00,'','2026-02-07 00:19:43','2026-02-06 19:36:19','1',NULL),(5,3,10,100,100,'UND',23.00,26.00,'','2026-02-07 00:39:05','2026-02-19 15:08:46','1',NULL),(8,5,12,15,15,'UND',33.00,38.00,'','2026-02-07 00:40:10','2026-02-06 19:41:00','1',NULL),(9,5,13,19,19,'UND',33.00,38.00,'','2026-02-07 00:40:10','2026-02-06 19:46:14','1',NULL),(10,6,1,150,0,'UND',16.00,18.00,'','2026-02-07 03:33:00','2026-02-07 03:33:00','1',NULL),(11,6,12,150,0,'UND',33.00,38.00,'','2026-02-07 03:33:00','2026-02-07 03:33:00','1',NULL),(12,7,15,50,0,'UND',35.00,41.00,'','2026-02-09 13:29:19','2026-02-09 13:29:19','1',NULL),(13,7,33,18,0,'UND',21.00,22.00,'','2026-02-09 13:29:19','2026-02-09 13:29:19','1',NULL),(14,8,10,18,18,'UND',23.00,26.00,'','2026-02-09 13:43:32','2026-02-09 09:57:06','1',NULL),(15,8,12,1,1,'UND',33.00,38.00,'','2026-02-09 13:43:32','2026-02-09 10:02:12','1',NULL),(16,9,32,50,0,'UND',57.00,62.00,'','2026-02-09 19:46:00','2026-02-09 19:46:00','1',NULL),(17,9,9,50,0,'UND',23.00,26.00,'','2026-02-09 19:46:00','2026-02-09 19:46:00','1',NULL),(18,10,17,150,150,'UND',23.00,34.00,'','2026-02-12 21:43:07','2026-02-19 15:48:03','1',NULL),(19,10,16,150,100,'UND',35.00,41.00,'','2026-02-12 21:43:07','2026-02-19 15:48:03','1',NULL),(20,10,10,1,1,'UND',23.00,26.00,'','2026-02-12 21:43:07','2026-02-19 15:48:03','1',NULL),(21,11,12,150,150,'UND',33.00,38.00,'','2026-02-12 21:44:07','2026-02-19 15:01:11','1',NULL),(22,12,10,255,255,'UND',23.00,26.00,'','2026-02-12 21:45:00','2026-02-16 16:17:21','1',NULL),(23,13,26,1,1,'UND',67.00,72.00,'','2026-02-12 21:46:02','2026-02-16 15:59:28','1',NULL),(24,14,13,100,100,'UND',33.00,38.00,'','2026-02-12 22:51:22','2026-02-16 15:57:43','1',NULL),(25,14,4,100,100,'UND',60.00,72.00,'','2026-02-12 22:51:22','2026-02-16 15:57:43','1',NULL),(26,15,3,15,15,'UND',0.00,40.00,'','2026-02-15 21:46:01','2026-02-15 19:11:43','1',NULL),(27,15,3,16,16,'UND',0.00,40.00,'','2026-02-15 21:46:01','2026-02-15 19:11:43','1',NULL),(28,16,3,100,100,'UND',35.00,40.00,'','2026-02-23 22:37:42','2026-02-23 17:41:49','1',NULL),(29,16,3,50,50,'UND',35.00,40.00,'','2026-02-23 22:37:42','2026-03-23 21:37:23','1',NULL),(30,17,6,100,100,'UND',0.00,22.00,'','2026-03-24 02:12:43','2026-03-23 21:34:22','1',NULL),(31,17,27,50,50,'UND',0.00,72.00,'','2026-03-24 02:12:43','2026-03-23 21:34:22','1',NULL);
/*!40000 ALTER TABLE `requerimiento_detalles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `requerimientos`
--

DROP TABLE IF EXISTS `requerimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `requerimientos` (
  `id_requerimiento` int NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Ej: REQ-2025-0001',
  `fecha_emision` datetime DEFAULT CURRENT_TIMESTAMP,
  `fecha_prometida` date DEFAULT NULL,
  `id_proveedor` int NOT NULL,
  `id_mina` int NOT NULL,
  `id_supervisor` int NOT NULL,
  `estado` enum('PENDIENTE','PARCIAL','COMPLETADO','ANULADO','RECHAZADO') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDIENTE',
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  `motivo_anulacion` text COLLATE utf8mb4_unicode_ci COMMENT 'Obligatorio si estado=ANULADO',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_requerimiento`),
  UNIQUE KEY `codigo` (`codigo`),
  KEY `fk_req_sup` (`id_supervisor`),
  KEY `idx_req_estado` (`estado`),
  KEY `idx_req_fecha` (`fecha_emision` DESC),
  KEY `idx_req_proveedor` (`id_proveedor`),
  KEY `idx_req_mina` (`id_mina`),
  KEY `idx_req_estado_fecha` (`estado`,`fecha_emision` DESC),
  CONSTRAINT `fk_req_mina` FOREIGN KEY (`id_mina`) REFERENCES `minas` (`id_mina`),
  CONSTRAINT `fk_req_prov` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`),
  CONSTRAINT `fk_req_sup` FOREIGN KEY (`id_supervisor`) REFERENCES `supervisores` (`id_supervisor`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `requerimientos`
--

LOCK TABLES `requerimientos` WRITE;
/*!40000 ALTER TABLE `requerimientos` DISABLE KEYS */;
INSERT INTO `requerimientos` VALUES (1,'REQ-2026-0001','2026-02-06 22:05:45','2026-02-06',1,12,12,'PENDIENTE','ninguna',NULL,'2026-02-06 22:05:45','2026-02-06 22:05:45','1',NULL,NULL),(2,'REQ-2026-0002','2026-02-07 00:19:43','2026-02-25',1,1,5,'COMPLETADO','',NULL,'2026-02-07 00:19:43','2026-02-06 19:36:19','1',NULL,NULL),(3,'REQ-2026-0003','2026-02-07 00:39:05','2026-03-26',1,4,5,'COMPLETADO','',NULL,'2026-02-07 00:39:05','2026-02-19 15:08:46','1',NULL,NULL),(5,'REQ-2026-0004','2026-02-07 00:40:10','2026-02-18',1,5,4,'COMPLETADO','',NULL,'2026-02-07 00:40:10','2026-02-06 19:46:14','1',NULL,NULL),(6,'REQ-2026-0005','2026-02-07 03:33:00','2026-02-26',1,5,16,'PENDIENTE','',NULL,'2026-02-07 03:33:00','2026-02-07 03:33:00','1',NULL,NULL),(7,'REQ-2026-0006','2026-02-09 13:29:19','2026-02-27',1,4,12,'PENDIENTE','',NULL,'2026-02-09 13:29:19','2026-02-09 13:29:19','1',NULL,NULL),(8,'REQ-2026-0007','2026-02-09 13:43:32','2026-02-19',1,4,7,'COMPLETADO','',NULL,'2026-02-09 13:43:32','2026-02-09 10:02:12','1',NULL,NULL),(9,'REQ-2026-0008','2026-02-09 19:46:00','2026-02-19',1,9,12,'PENDIENTE','',NULL,'2026-02-09 19:46:00','2026-02-09 19:46:00','1',NULL,NULL),(10,'REQ-2026-0009','2026-02-24 00:00:00','2026-03-04',1,2,12,'PARCIAL','',NULL,'2026-02-12 21:43:07','2026-02-19 15:48:03','1',NULL,NULL),(11,'REQ-2026-0010','2026-02-12 00:00:00','2026-02-20',1,2,5,'COMPLETADO','',NULL,'2026-02-12 21:44:07','2026-02-19 15:01:11','1',NULL,NULL),(12,'REQ-2026-0011','2026-02-01 00:00:00','2026-02-09',1,7,5,'COMPLETADO','',NULL,'2026-02-12 21:45:00','2026-02-16 16:17:21','1',NULL,NULL),(13,'REQ-2026-0012','2026-02-13 00:00:00','2026-02-21',1,2,12,'COMPLETADO','',NULL,'2026-02-12 21:46:02','2026-02-16 15:59:28','1',NULL,NULL),(14,'REQ-2026-0013','2026-02-12 00:00:00','2026-02-20',1,2,12,'COMPLETADO','',NULL,'2026-02-12 22:51:22','2026-02-16 15:57:43','1',NULL,NULL),(15,'REQ-2026-0014','2026-01-15 00:00:00','2026-01-23',3,2,12,'COMPLETADO','',NULL,'2026-02-15 21:46:01','2026-02-15 19:11:43','1',NULL,NULL),(16,'REQ-2026-0015','2026-02-23 00:00:00','2026-03-03',1,2,12,'COMPLETADO','prueba',NULL,'2026-02-23 22:37:42','2026-03-23 21:37:23','1',NULL,NULL),(17,'REQ-2026-0016','2026-03-24 00:00:00','2026-04-01',3,12,11,'COMPLETADO','',NULL,'2026-03-24 02:12:43','2026-03-23 21:34:22','1',NULL,NULL);
/*!40000 ALTER TABLE `requerimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supervisores`
--

DROP TABLE IF EXISTS `supervisores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supervisores` (
  `id_supervisor` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id_supervisor`),
  UNIQUE KEY `uk_nombre_sup` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supervisores`
--

LOCK TABLES `supervisores` WRITE;
/*!40000 ALTER TABLE `supervisores` DISABLE KEYS */;
INSERT INTO `supervisores` VALUES (1,'TORRES',NULL,NULL,NULL),(2,'TOBIAS',NULL,NULL,NULL),(3,'WILSON',NULL,NULL,NULL),(4,'ESGAR',NULL,NULL,NULL),(5,'EDGAR',NULL,NULL,NULL),(6,'JORGE',NULL,NULL,NULL),(7,'JAIME',NULL,NULL,NULL),(8,'JAVIER',NULL,NULL,NULL),(9,'JOEL',NULL,NULL,NULL),(10,'MARIO',NULL,NULL,NULL),(11,'ARMAS','','',NULL),(12,'DANTE',NULL,NULL,NULL),(13,'GEINER',NULL,NULL,NULL),(14,'SANDOVAL',NULL,NULL,NULL),(15,'Supervisor Test',NULL,'sup@test.com','2026-02-07 03:25:27'),(16,'MARCO','72489654','marco@gmai.com',NULL);
/*!40000 ALTER TABLE `supervisores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Bcrypt con 12 rounds',
  `nombre_completo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` enum('ADMIN','LOGISTICA','SUPERVISOR','MINA') COLLATE utf8mb4_unicode_ci DEFAULT 'SUPERVISOR',
  `activo` tinyint(1) DEFAULT '1',
  `id_supervisor` int DEFAULT NULL,
  `ultimo_login` datetime DEFAULT NULL,
  `intentos_fallidos` int DEFAULT '0',
  `bloqueado_hasta` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `username` (`username`),
  KEY `fk_usu_sup` (`id_supervisor`),
  KEY `idx_usuario_activo` (`activo`),
  CONSTRAINT `fk_usu_sup` FOREIGN KEY (`id_supervisor`) REFERENCES `supervisores` (`id_supervisor`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'admin','$2b$10$iL4BJ4R89xzwj8H12otHpul8vkS51Y/t/oisOHATq.on8Gbfpi/tO','Administrador del Sistema','ADMIN',1,NULL,'2026-03-25 01:57:59',0,NULL,'2026-02-05 12:45:37','2026-03-24 20:57:59'),(2,'JORGE','$2b$10$DUIyxCN1UAeVbGgaLJM4s.VDyDFXftEBBm3mHHZL6NGaJxjRUyUOq','JORGE POLO TANDAYPAN','SUPERVISOR',1,6,'2026-02-07 17:12:33',0,NULL,'2026-02-07 17:12:21','2026-02-10 09:46:49'),(3,'MARCO','$2b$10$jdv4cALHB0l4qxw3l1rUKOW3S/jXvbDtNCJAtRdbTvkwNsjLxGXO2','MARCO POLO ','SUPERVISOR',1,NULL,NULL,0,NULL,'2026-02-09 13:05:42','2026-02-09 13:05:42');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_kardex_completo`
--

DROP TABLE IF EXISTS `v_kardex_completo`;
/*!50001 DROP VIEW IF EXISTS `v_kardex_completo`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_kardex_completo` AS SELECT 
 1 AS `id_movimiento`,
 1 AS `fecha`,
 1 AS `producto`,
 1 AS `medida`,
 1 AS `tipo`,
 1 AS `cantidad`,
 1 AS `observacion`,
 1 AS `usuario_registro`,
 1 AS `codigo_viaje`,
 1 AS `codigo_requerimiento`,
 1 AS `codigo_despacho`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_precios_proveedores`
--

DROP TABLE IF EXISTS `v_precios_proveedores`;
/*!50001 DROP VIEW IF EXISTS `v_precios_proveedores`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_precios_proveedores` AS SELECT 
 1 AS `id_catalogo`,
 1 AS `proveedor`,
 1 AS `producto`,
 1 AS `medida`,
 1 AS `precio_compra_sugerido`,
 1 AS `fecha_actualizacion`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_requerimientos_progreso`
--

DROP TABLE IF EXISTS `v_requerimientos_progreso`;
/*!50001 DROP VIEW IF EXISTS `v_requerimientos_progreso`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_requerimientos_progreso` AS SELECT 
 1 AS `id_requerimiento`,
 1 AS `codigo`,
 1 AS `fecha_emision`,
 1 AS `estado`,
 1 AS `proveedor`,
 1 AS `mina`,
 1 AS `supervisor`,
 1 AS `total_solicitado`,
 1 AS `total_entregado`,
 1 AS `porcentaje_cumplimiento`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_stock_disponible`
--

DROP TABLE IF EXISTS `v_stock_disponible`;
/*!50001 DROP VIEW IF EXISTS `v_stock_disponible`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_stock_disponible` AS SELECT 
 1 AS `id_producto`,
 1 AS `id_medida`,
 1 AS `producto`,
 1 AS `medida`,
 1 AS `clasificacion`,
 1 AS `id_clasificacion`,
 1 AS `stock_actual`,
 1 AS `precio_venta_base`,
 1 AS `precio_compra_sugerido`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `viaje_detalles`
--

DROP TABLE IF EXISTS `viaje_detalles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `viaje_detalles` (
  `id_viaje_detalle` int NOT NULL AUTO_INCREMENT,
  `id_viaje` int NOT NULL,
  `id_detalle_requerimiento` int DEFAULT NULL,
  `cantidad_recibida` int NOT NULL,
  `estado_entrega` enum('OK','RECHAZADO','PARCIAL','MUESTRA','DAÑADO') COLLATE utf8mb4_unicode_ci DEFAULT 'OK',
  `observacion` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `es_extra` tinyint(1) NOT NULL DEFAULT '0',
  `id_medida` int DEFAULT NULL,
  `id_producto` int DEFAULT NULL,
  PRIMARY KEY (`id_viaje_detalle`),
  KEY `fk_vdet_det` (`id_detalle_requerimiento`),
  KEY `idx_vdet_viaje` (`id_viaje`),
  KEY `idx_vdet_producto` (`id_producto`),
  KEY `fk_vdet_med` (`id_medida`),
  CONSTRAINT `fk_vdet_det` FOREIGN KEY (`id_detalle_requerimiento`) REFERENCES `requerimiento_detalles` (`id_detalle`),
  CONSTRAINT `fk_vdet_med` FOREIGN KEY (`id_medida`) REFERENCES `medidas` (`id_medida`),
  CONSTRAINT `fk_vdet_prod` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`),
  CONSTRAINT `fk_vdet_via` FOREIGN KEY (`id_viaje`) REFERENCES `viajes` (`id_viaje`) ON DELETE CASCADE,
  CONSTRAINT `viaje_detalles_chk_1` CHECK ((`cantidad_recibida` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `viaje_detalles`
--

LOCK TABLES `viaje_detalles` WRITE;
/*!40000 ALTER TABLE `viaje_detalles` DISABLE KEYS */;
INSERT INTO `viaje_detalles` VALUES (1,1,1,1,'OK','juan','2026-02-06 22:26:13','2026-02-06 22:26:13','admin',NULL,0,NULL,NULL),(2,2,2,1,'OK','','2026-02-07 00:12:15','2026-02-07 00:12:15','admin',NULL,0,NULL,NULL),(3,3,3,50,'OK','','2026-02-07 00:20:49','2026-02-07 00:20:49','admin',NULL,0,NULL,NULL),(4,3,4,15,'OK','','2026-02-07 00:20:49','2026-02-07 00:20:49','admin',NULL,0,NULL,NULL),(5,4,3,50,'OK','','2026-02-07 00:36:20','2026-02-07 00:36:20','admin',NULL,0,NULL,NULL),(6,4,4,35,'OK','','2026-02-07 00:36:20','2026-02-07 00:36:20','admin',NULL,0,NULL,NULL),(7,5,8,15,'OK','','2026-02-07 00:41:00','2026-02-07 00:41:00','admin',NULL,0,NULL,NULL),(8,6,9,15,'OK','','2026-02-07 00:46:03','2026-02-07 00:46:03','admin',NULL,0,NULL,NULL),(9,7,9,4,'OK','','2026-02-07 00:46:15','2026-02-07 00:46:15','admin',NULL,0,NULL,NULL),(10,8,14,18,'OK','','2026-02-09 14:57:07','2026-02-09 14:57:07','admin',NULL,0,NULL,NULL),(11,9,15,1,'OK','','2026-02-09 15:02:12','2026-02-09 15:02:12','admin',NULL,0,NULL,NULL),(12,10,26,15,'OK','','2026-02-16 00:11:43','2026-02-16 00:11:43','admin',NULL,0,NULL,NULL),(13,10,27,16,'OK','','2026-02-16 00:11:43','2026-02-16 00:11:43','admin',NULL,0,NULL,NULL),(14,11,24,100,'OK','','2026-02-16 20:57:44','2026-02-16 20:57:44','admin',NULL,0,NULL,NULL),(15,11,25,100,'OK','','2026-02-16 20:57:44','2026-02-16 20:57:44','admin',NULL,0,NULL,NULL),(16,12,23,1,'OK','','2026-02-16 20:59:28','2026-02-16 20:59:28','admin',NULL,0,NULL,NULL),(17,13,22,150,'OK','','2026-02-16 21:04:18','2026-02-16 21:04:18','admin',NULL,0,NULL,NULL),(18,14,22,5,'OK','','2026-02-16 21:04:59','2026-02-16 21:04:59','admin',NULL,0,NULL,NULL),(19,15,22,50,'OK','','2026-02-16 21:16:25','2026-02-16 21:16:25','admin',NULL,0,NULL,NULL),(20,16,22,50,'OK','','2026-02-16 21:17:22','2026-02-16 21:17:22','admin',NULL,0,NULL,NULL),(21,17,21,150,'OK','','2026-02-19 20:01:11','2026-02-19 20:01:11','admin',NULL,0,NULL,NULL),(22,18,5,100,'OK','','2026-02-19 20:08:46','2026-02-19 20:08:46','admin',NULL,0,NULL,NULL),(23,19,18,150,'OK','','2026-02-19 20:48:04','2026-02-19 20:48:04','admin',NULL,0,NULL,NULL),(24,19,19,100,'OK','','2026-02-19 20:48:04','2026-02-19 20:48:04','admin',NULL,0,NULL,NULL),(25,19,20,1,'OK','','2026-02-19 20:48:04','2026-02-19 20:48:04','admin',NULL,0,NULL,NULL),(26,20,28,100,'OK','','2026-02-23 22:41:50','2026-02-23 22:41:50','admin',NULL,0,NULL,NULL),(27,20,29,40,'OK','','2026-02-23 22:41:50','2026-02-23 22:41:50','admin',NULL,0,NULL,NULL),(28,20,NULL,150,'OK','','2026-02-23 22:41:50','2026-02-23 22:41:50','admin',NULL,1,6,3),(29,21,30,50,'OK','','2026-03-24 02:13:27','2026-03-24 02:13:27','admin',NULL,0,NULL,NULL),(30,21,31,25,'OK','','2026-03-24 02:13:27','2026-03-24 02:13:27','admin',NULL,0,NULL,NULL),(31,22,30,50,'OK','','2026-03-24 02:34:22','2026-03-24 02:34:22','admin',NULL,0,NULL,NULL),(32,22,31,25,'OK','','2026-03-24 02:34:22','2026-03-24 02:34:22','admin',NULL,0,NULL,NULL),(33,23,29,10,'OK','','2026-03-24 02:37:23','2026-03-24 02:37:23','admin',NULL,0,NULL,NULL);
/*!40000 ALTER TABLE `viaje_detalles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `viajes`
--

DROP TABLE IF EXISTS `viajes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `viajes` (
  `id_viaje` int NOT NULL AUTO_INCREMENT,
  `id_requerimiento` int NOT NULL,
  `numero_viaje` int NOT NULL,
  `fecha_salida` datetime DEFAULT NULL,
  `fecha_ingreso` datetime DEFAULT CURRENT_TIMESTAMP,
  `placa_vehiculo` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `conductor` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero_vale` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `etiqueta_viaje` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_viaje`),
  UNIQUE KEY `uk_viaje_req_num` (`id_requerimiento`,`numero_viaje`),
  KEY `idx_viaje_fecha` (`fecha_ingreso` DESC),
  CONSTRAINT `fk_via_req` FOREIGN KEY (`id_requerimiento`) REFERENCES `requerimientos` (`id_requerimiento`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `viajes`
--

LOCK TABLES `viajes` WRITE;
/*!40000 ALTER TABLE `viajes` DISABLE KEYS */;
INSERT INTO `viajes` VALUES (1,1,1,NULL,'2026-02-06 17:26:13','abc-123','juan',NULL,'2026-02-06 17:26:13','2026-02-06 17:26:13','admin',NULL,NULL,NULL),(2,1,2,NULL,'2026-02-06 19:12:15','ABC','JUAN',NULL,'2026-02-06 19:12:15','2026-02-06 19:12:15','admin',NULL,NULL,NULL),(3,2,1,NULL,'2026-02-06 19:20:48','ABC-123','LUIS',NULL,'2026-02-06 19:20:48','2026-02-06 19:20:48','admin',NULL,NULL,NULL),(4,2,2,NULL,'2026-02-06 19:36:19','ABC-155','JUAN2',NULL,'2026-02-06 19:36:19','2026-02-06 19:36:19','admin',NULL,NULL,NULL),(5,5,1,NULL,'2026-02-06 19:41:00','ABC-123','JUAN',NULL,'2026-02-06 19:41:00','2026-02-06 19:41:00','admin',NULL,NULL,NULL),(6,5,2,NULL,'2026-02-06 19:46:02','ABC','JUAN',NULL,'2026-02-06 19:46:02','2026-02-06 19:46:02','admin',NULL,NULL,NULL),(7,5,3,NULL,'2026-02-06 19:46:14','ABC','JUAN',NULL,'2026-02-06 19:46:14','2026-02-06 19:46:14','admin',NULL,NULL,NULL),(8,8,1,NULL,'2026-02-09 09:57:06','123-AB','JUAN',NULL,'2026-02-09 09:57:06','2026-02-09 09:57:06','admin',NULL,NULL,NULL),(9,8,2,NULL,'2026-02-09 10:02:12','123','JUAN',NULL,'2026-02-09 10:02:12','2026-02-09 10:02:12','admin',NULL,NULL,NULL),(10,15,1,NULL,'2026-02-15 19:11:43','ABC','LUIS',NULL,'2026-02-15 19:11:43','2026-02-15 19:11:43','admin',NULL,NULL,NULL),(11,14,1,NULL,'2026-02-16 15:57:43','PRUEBA','JUAN',NULL,'2026-02-16 15:57:43','2026-02-16 15:57:43','admin',NULL,NULL,NULL),(12,13,1,NULL,'2026-02-16 15:59:28','LUIS-123','LUIS CARDENAS',NULL,'2026-02-16 15:59:28','2026-02-16 15:59:28','admin',NULL,NULL,NULL),(13,12,1,NULL,'2026-03-19 02:03:00','LUISSS','CAMPOS',NULL,'2026-02-16 16:04:17','2026-02-16 16:04:17','admin',NULL,NULL,NULL),(14,12,2,NULL,'2026-03-26 02:04:00','luis','sdsa',NULL,'2026-02-16 16:04:58','2026-02-16 16:04:58','admin',NULL,NULL,NULL),(15,12,3,NULL,'2026-03-18 02:16:00','JUAN-SD1','JUAN ',NULL,'2026-02-16 16:16:25','2026-02-16 16:16:25','admin',NULL,NULL,NULL),(16,12,4,NULL,'2026-03-20 02:17:00','MARTE','MARTE',NULL,'2026-02-16 16:17:21','2026-02-16 16:17:21','admin',NULL,NULL,NULL),(17,11,1,NULL,'2026-02-20 01:00:00','abc-123','juan',NULL,'2026-02-19 15:01:11','2026-02-19 15:01:11','admin',NULL,'10012',NULL),(18,3,1,NULL,'2026-02-20 01:08:00','ABC-123','LUISMARTE',NULL,'2026-02-19 15:08:46','2026-02-19 15:08:46','admin',NULL,'151515',NULL),(19,10,1,NULL,'2026-02-20 01:47:00','ABC-123','PREUBAS',NULL,'2026-02-19 15:48:03','2026-02-19 15:48:03','admin',NULL,'123456','2-VIAJE'),(20,16,1,NULL,'2026-02-24 03:37:00','12321','JUNA',NULL,'2026-02-23 17:41:49','2026-02-23 17:41:49','admin',NULL,'123123','1-VIAJE'),(21,17,1,NULL,'2026-03-24 07:12:00',NULL,NULL,NULL,'2026-03-23 21:13:26','2026-03-23 21:13:26','admin',NULL,'100-112','1-VIAJE'),(22,17,2,NULL,'2026-03-24 07:34:00',NULL,NULL,NULL,'2026-03-23 21:34:22','2026-03-23 21:34:22','admin',NULL,NULL,NULL),(23,16,2,NULL,'2026-03-24 07:36:00',NULL,NULL,NULL,'2026-03-23 21:37:23','2026-03-23 21:37:23','admin',NULL,'121232','1-VIAJE');
/*!40000 ALTER TABLE `viajes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `v_kardex_completo`
--

/*!50001 DROP VIEW IF EXISTS `v_kardex_completo`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_kardex_completo` AS select `ms`.`id_movimiento` AS `id_movimiento`,`ms`.`fecha` AS `fecha`,`p`.`nombre` AS `producto`,`m`.`descripcion` AS `medida`,`ms`.`tipo` AS `tipo`,`ms`.`cantidad` AS `cantidad`,`ms`.`observacion` AS `observacion`,`ms`.`usuario_registro` AS `usuario_registro`,concat(`req`.`codigo`,'-V',`v`.`numero_viaje`) AS `codigo_viaje`,`req`.`codigo` AS `codigo_requerimiento`,`d`.`codigo` AS `codigo_despacho` from (((((`movimientos_stock` `ms` join `productos` `p` on((`ms`.`id_producto` = `p`.`id_producto`))) join `medidas` `m` on((`p`.`id_medida` = `m`.`id_medida`))) left join `viajes` `v` on((`ms`.`id_viaje` = `v`.`id_viaje`))) left join `requerimientos` `req` on((`ms`.`id_requerimiento` = `req`.`id_requerimiento`))) left join `despachos` `d` on((`ms`.`id_despacho` = `d`.`id_despacho`))) order by `ms`.`fecha` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_precios_proveedores`
--

/*!50001 DROP VIEW IF EXISTS `v_precios_proveedores`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_precios_proveedores` AS select `pp`.`id_catalogo` AS `id_catalogo`,`prov`.`nombre` AS `proveedor`,`prod`.`nombre` AS `producto`,`m`.`descripcion` AS `medida`,`pp`.`precio_compra_sugerido` AS `precio_compra_sugerido`,`pp`.`fecha_actualizacion` AS `fecha_actualizacion` from (((`producto_proveedores` `pp` join `proveedores` `prov` on((`pp`.`id_proveedor` = `prov`.`id_proveedor`))) join `productos` `prod` on((`pp`.`id_producto` = `prod`.`id_producto`))) join `medidas` `m` on((`prod`.`id_medida` = `m`.`id_medida`))) where ((`pp`.`activo` = true) and (`pp`.`deleted_at` is null) and (`prov`.`deleted_at` is null) and (`prod`.`deleted_at` is null)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_requerimientos_progreso`
--

/*!50001 DROP VIEW IF EXISTS `v_requerimientos_progreso`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_requerimientos_progreso` AS select `r`.`id_requerimiento` AS `id_requerimiento`,`r`.`codigo` AS `codigo`,`r`.`fecha_emision` AS `fecha_emision`,`r`.`estado` AS `estado`,`prov`.`nombre` AS `proveedor`,`m`.`nombre` AS `mina`,`s`.`nombre` AS `supervisor`,sum(`rd`.`cantidad_solicitada`) AS `total_solicitado`,sum(`rd`.`cantidad_entregada`) AS `total_entregado`,round(((sum(`rd`.`cantidad_entregada`) / sum(`rd`.`cantidad_solicitada`)) * 100),2) AS `porcentaje_cumplimiento` from ((((`requerimientos` `r` join `proveedores` `prov` on((`r`.`id_proveedor` = `prov`.`id_proveedor`))) join `minas` `m` on((`r`.`id_mina` = `m`.`id_mina`))) join `supervisores` `s` on((`r`.`id_supervisor` = `s`.`id_supervisor`))) join `requerimiento_detalles` `rd` on((`r`.`id_requerimiento` = `rd`.`id_requerimiento`))) where (`r`.`deleted_at` is null) group by `r`.`id_requerimiento`,`r`.`codigo`,`r`.`fecha_emision`,`r`.`estado`,`prov`.`nombre`,`m`.`nombre`,`s`.`nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_stock_disponible`
--

/*!50001 DROP VIEW IF EXISTS `v_stock_disponible`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_stock_disponible` AS select `p`.`id_producto` AS `id_producto`,`p`.`id_medida` AS `id_medida`,`p`.`nombre` AS `producto`,`m`.`descripcion` AS `medida`,`c`.`nombre` AS `clasificacion`,`p`.`id_clasificacion` AS `id_clasificacion`,`p`.`stock_actual` AS `stock_actual`,`p`.`precio_venta_base` AS `precio_venta_base`,coalesce((select `pp`.`precio_compra_sugerido` from `producto_proveedores` `pp` where ((`pp`.`id_producto` = `p`.`id_producto`) and (`pp`.`activo` = true) and (`pp`.`deleted_at` is null)) order by `pp`.`fecha_actualizacion` desc limit 1),0) AS `precio_compra_sugerido`,`p`.`created_at` AS `created_at`,`p`.`updated_at` AS `updated_at` from ((`productos` `p` join `medidas` `m` on((`p`.`id_medida` = `m`.`id_medida`))) left join `clasificaciones` `c` on((`p`.`id_clasificacion` = `c`.`id_clasificacion`))) where (`p`.`deleted_at` is null) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-24 22:30:58
