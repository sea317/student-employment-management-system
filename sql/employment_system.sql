CREATE DATABASE  IF NOT EXISTS `employment_system` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `employment_system`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: employment_system
-- ------------------------------------------------------
-- Server version	9.7.0

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
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '90da2633-5a4d-11f1-be82-c4c6e617cba5:1-93';

--
-- Table structure for table `application`
--

DROP TABLE IF EXISTS `application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application` (
  `app_id` int NOT NULL AUTO_INCREMENT,
  `stu_id` char(12) COLLATE utf8mb4_general_ci NOT NULL,
  `rec_id` int NOT NULL,
  `apply_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('已投递','待查看','面试','录用','不合适') COLLATE utf8mb4_general_ci DEFAULT '已投递',
  PRIMARY KEY (`app_id`),
  KEY `stu_id` (`stu_id`),
  KEY `rec_id` (`rec_id`),
  CONSTRAINT `application_ibfk_1` FOREIGN KEY (`stu_id`) REFERENCES `graduate` (`stu_id`) ON DELETE CASCADE,
  CONSTRAINT `application_ibfk_2` FOREIGN KEY (`rec_id`) REFERENCES `recruitment` (`rec_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application`
--

LOCK TABLES `application` WRITE;
/*!40000 ALTER TABLE `application` DISABLE KEYS */;
INSERT INTO `application` VALUES (1,'20240001',1,'2025-09-01 10:30:00','已投递'),(2,'20240001',2,'2025-09-02 14:20:00','面试'),(3,'20240002',1,'2025-09-03 09:15:00','待查看'),(4,'20240002',3,'2025-09-04 11:00:00','已投递'),(5,'20240003',2,'2025-09-05 16:30:00','不合适'),(6,'20240004',4,'2025-09-06 10:00:00','面试'),(7,'20240005',1,'2025-09-07 13:45:00','已投递'),(8,'20240001',4,'2026-06-19 00:29:39','已投递');
/*!40000 ALTER TABLE `application` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booth`
--

DROP TABLE IF EXISTS `booth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booth` (
  `booth_id` int NOT NULL AUTO_INCREMENT,
  `fair_id` int NOT NULL,
  `booth_no` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `employer_id` int DEFAULT NULL,
  `is_occupied` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`booth_id`),
  UNIQUE KEY `uk_fair_booth` (`fair_id`,`booth_no`),
  KEY `employer_id` (`employer_id`),
  CONSTRAINT `booth_ibfk_1` FOREIGN KEY (`fair_id`) REFERENCES `jobfair` (`fair_id`) ON DELETE CASCADE,
  CONSTRAINT `booth_ibfk_2` FOREIGN KEY (`employer_id`) REFERENCES `employer` (`employer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booth`
--

LOCK TABLES `booth` WRITE;
/*!40000 ALTER TABLE `booth` DISABLE KEYS */;
INSERT INTO `booth` VALUES (1,1,'A01',NULL,0),(2,1,'A02',NULL,0),(3,1,'A03',NULL,0),(4,1,'A04',NULL,0),(5,1,'A05',NULL,0),(6,1,'B01',NULL,0),(7,1,'B02',NULL,0),(8,1,'B03',NULL,0),(9,1,'B04',NULL,0),(10,1,'B05',NULL,0),(11,1,'C01',NULL,0),(12,1,'C02',NULL,0),(13,1,'C03',NULL,0),(14,1,'C04',NULL,0),(15,1,'C05',NULL,0),(16,1,'D01',NULL,0),(17,1,'D02',NULL,0),(18,1,'D03',NULL,0),(19,1,'D04',NULL,0),(20,1,'D05',NULL,0),(21,1,'E01',NULL,0),(22,1,'E02',NULL,0),(23,1,'E03',NULL,0),(24,1,'E04',NULL,0),(25,1,'E05',NULL,0);
/*!40000 ALTER TABLE `booth` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employer`
--

DROP TABLE IF EXISTS `employer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employer` (
  `employer_id` int NOT NULL AUTO_INCREMENT COMMENT '单位ID',
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码',
  `name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '单位名称',
  `location` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '单位地点',
  `nature` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '单位性质',
  `economy_type` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '经济类型',
  `publisher` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '发布人',
  `department` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '所在部门',
  `contact` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系方式',
  `intro` text COLLATE utf8mb4_general_ci COMMENT '单位简介',
  `is_published` enum('是','否') COLLATE utf8mb4_general_ci DEFAULT '否' COMMENT '发布状态',
  `valid_date` date DEFAULT NULL COMMENT '有效期',
  `audit_status` enum('待审核','通过','未通过') COLLATE utf8mb4_general_ci DEFAULT '待审核' COMMENT '审核状态',
  PRIMARY KEY (`employer_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employer`
--

LOCK TABLES `employer` WRITE;
/*!40000 ALTER TABLE `employer` DISABLE KEYS */;
INSERT INTO `employer` VALUES (1,'huawei','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','华为技术有限公司','深圳','民营企业','股份制',NULL,NULL,'hr@huawei.com',NULL,'否',NULL,'通过'),(2,'alibaba','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','阿里巴巴集团','杭州','民营企业','股份制',NULL,NULL,'hr@alibaba.com',NULL,'否',NULL,'通过'),(3,'tencent','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','腾讯科技','深圳','民营企业','股份制',NULL,NULL,'hr@tencent.com',NULL,'否',NULL,'通过'),(4,'bytedance','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','字节跳动','北京','民营企业','股份制',NULL,NULL,'hr@bytedance.com',NULL,'否',NULL,'通过'),(5,'zhaopin','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','智联招聘','北京','合资企业','股份制',NULL,NULL,'hr@zhaopin.com',NULL,'否',NULL,'通过');
/*!40000 ALTER TABLE `employer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `graduate`
--

DROP TABLE IF EXISTS `graduate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `graduate` (
  `stu_id` char(12) COLLATE utf8mb4_general_ci NOT NULL COMMENT '学号',
  `name` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT '姓名',
  `age` int DEFAULT NULL COMMENT '年龄',
  `gender` enum('男','女') COLLATE utf8mb4_general_ci NOT NULL COMMENT '性别',
  `birth_date` date DEFAULT NULL COMMENT '出生日期',
  `nation` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '民族',
  `political_status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '政治面貌',
  `major` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT '专业',
  `college` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '院系名称',
  `education` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '学历',
  `edu_system` enum('2年','3年','4年') COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '学制',
  `cultivate_type` enum('非定向','定向') COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '培养方式',
  `hometown` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '生源地',
  `phone` varchar(15) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系电话',
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录密码',
  `created_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`stu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `graduate`
--

LOCK TABLES `graduate` WRITE;
/*!40000 ALTER TABLE `graduate` DISABLE KEYS */;
INSERT INTO `graduate` VALUES ('20240001','张三',22,'男','2026-06-11','汉族','共青团员','人工智能','信息学院','本科','4年','非定向','湖南长沙','13900001115','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','2026-06-16 16:21:58'),('20240002','李四',23,'女','2001-08-23','汉族','中共党员','计算机科学','信息学院','本科','4年','非定向','湖南株洲','13800000002','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','2026-06-16 16:21:58'),('20240003','王五',22,'男','2002-11-02','苗族','共青团员','软件工程','软件学院','本科','4年','定向','湖南湘潭','13800000003','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','2026-06-16 16:21:58'),('20240004','赵六',24,'女','2000-03-15','汉族','群众','数据科学','数据学院','硕士','3年','非定向','湖南衡阳','13800000004','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','2026-06-16 16:21:58'),('20240005','周七',21,'男','2003-07-19','汉族','共青团员','人工智能','信息学院','本科','4年','非定向','湖南岳阳','13800000005','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','2026-06-16 16:21:58');
/*!40000 ALTER TABLE `graduate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobfair`
--

DROP TABLE IF EXISTS `jobfair`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobfair` (
  `fair_id` int NOT NULL AUTO_INCREMENT COMMENT '招聘会ID',
  `title` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '招聘会标题',
  `fair_time` datetime NOT NULL COMMENT '招聘会时间',
  `location` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT '招聘会地点',
  `content` text COLLATE utf8mb4_general_ci COMMENT '招聘会内容',
  `demand_major` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '需求专业',
  `edu_required` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '学历要求',
  `demand_num` int DEFAULT NULL COMMENT '需求人数',
  `is_published` enum('是','否') COLLATE utf8mb4_general_ci DEFAULT '否' COMMENT '发布状态',
  `total_booths` int DEFAULT '0' COMMENT '总摊位数',
  PRIMARY KEY (`fair_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobfair`
--

LOCK TABLES `jobfair` WRITE;
/*!40000 ALTER TABLE `jobfair` DISABLE KEYS */;
INSERT INTO `jobfair` VALUES (1,'2025届秋季校园招聘会','2025-10-15 09:00:00','学校体育馆','大型综合招聘会，欢迎各用人单位参加',NULL,NULL,NULL,'是',50),(2,'IT专场招聘会','2025-11-01 14:00:00','信息学院报告厅','IT企业专场，面向计算机相关专业',NULL,NULL,NULL,'是',30),(3,'2026届春季双选会','2026-03-20 09:00:00','大学生活动中心','春季大型双选会',NULL,NULL,NULL,'否',80),(4,'招聘会','2026-06-19 12:40:00','湖南工业大学','123',NULL,NULL,NULL,'是',4);
/*!40000 ALTER TABLE `jobfair` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `news`
--

DROP TABLE IF EXISTS `news`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `news` (
  `news_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `category` enum('就业指导','就业政策') COLLATE utf8mb4_general_ci NOT NULL,
  `publish_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `publisher` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `content` text COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`news_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `news`
--

LOCK TABLES `news` WRITE;
/*!40000 ALTER TABLE `news` DISABLE KEYS */;
INSERT INTO `news` VALUES (1,'2025届毕业生就业指南','就业指导','2026-06-16 16:21:58','就业指导中心','各位毕业生：请认真准备个人简历，积极参加校园招聘会，关注就业信息网发布的最新招聘信息。祝大家找到理想工作！'),(2,'关于举办秋季大型招聘会的通知','就业政策','2026-06-16 16:21:58','就业办','学校定于2025年10月15日举办秋季大型招聘会，届时将有50余家用人单位参会。请各学院组织毕业生准时参加。'),(3,'简历撰写技巧分享','就业指导','2026-06-16 16:21:58','职业发展中心','一份优秀的简历应该包含：个人信息、教育背景、实习经历、项目经验、专业技能、获奖情况等。建议针对不同岗位定制简历。'),(4,'毕业生就业协议签订须知','就业政策','2026-06-16 16:21:58','就业办','毕业生与用人单位达成意向后，应及时签订就业协议。协议一式三份，学生、单位、学校各执一份。'),(5,'321','就业指导','2026-06-19 13:49:05','系统管理员','312');
/*!40000 ALTER TABLE `news` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recruitment`
--

DROP TABLE IF EXISTS `recruitment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment` (
  `rec_id` int NOT NULL AUTO_INCREMENT COMMENT '招聘ID',
  `employer_id` int NOT NULL COMMENT '单位ID',
  `major_needed` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '招聘专业',
  `edu_required` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '学历要求',
  `demand_num` int DEFAULT '0' COMMENT '需求人数',
  `recruit_method` enum('现场','委托') COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '招聘方式',
  `fair_id` int DEFAULT NULL COMMENT '招聘会ID',
  `booth_no` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '摊位编号',
  `job_description` text COLLATE utf8mb4_general_ci COMMENT '岗位描述',
  `publish_date` date DEFAULT (curdate()) COMMENT '发布日期',
  `audit_status` enum('待审核','已通过','已下架') COLLATE utf8mb4_general_ci DEFAULT '待审核' COMMENT '审核状态',
  PRIMARY KEY (`rec_id`),
  KEY `employer_id` (`employer_id`),
  KEY `fair_id` (`fair_id`),
  CONSTRAINT `recruitment_ibfk_1` FOREIGN KEY (`employer_id`) REFERENCES `employer` (`employer_id`) ON DELETE CASCADE,
  CONSTRAINT `recruitment_ibfk_2` FOREIGN KEY (`fair_id`) REFERENCES `jobfair` (`fair_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment`
--

LOCK TABLES `recruitment` WRITE;
/*!40000 ALTER TABLE `recruitment` DISABLE KEYS */;
INSERT INTO `recruitment` VALUES (1,1,'人工智能','本科',30,'现场',NULL,NULL,'AI算法工程师，负责机器学习模型开发与优化','2026-06-16','已通过'),(2,1,'计算机科学','本科',20,'现场',NULL,NULL,'软件开发工程师，负责后端系统开发','2026-06-16','已通过'),(3,2,'软件工程','本科',25,'委托',NULL,NULL,'Java开发工程师，负责业务系统开发','2026-06-16','已通过'),(4,3,'人工智能','硕士',15,'现场',NULL,NULL,'机器学习研究员，负责AI算法研究','2026-06-16','已通过'),(5,5,'数据科学','本科',10,'委托',NULL,NULL,'数据分析师，负责数据挖掘与分析','2026-06-16','已通过'),(6,1,'通信工程','本科',18,'现场',NULL,NULL,'通信工程师，负责5G技术研发','2026-06-16','已通过'),(7,2,'产品经理','本科',8,'委托',NULL,NULL,'产品经理，负责产品规划和设计','2026-06-16','待审核');
/*!40000 ALTER TABLE `recruitment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resume`
--

DROP TABLE IF EXISTS `resume`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resume` (
  `resume_id` int NOT NULL AUTO_INCREMENT COMMENT '简历编号',
  `stu_id` char(12) COLLATE utf8mb4_general_ci NOT NULL COMMENT '学号',
  `graduation_time` date DEFAULT NULL COMMENT '毕业时间',
  `job_intention` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '求职意向',
  `foreign_lang` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '外语语种',
  `foreign_level` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '外语水平',
  `computer_level` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '电脑水平',
  `former_position` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '曾任职务',
  `phone` varchar(15) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系信箱',
  `address` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系地址',
  `work_experience` text COLLATE utf8mb4_general_ci COMMENT '工作经历/社会实践',
  `cover_letter` text COLLATE utf8mb4_general_ci COMMENT '自荐信',
  `is_published` tinyint(1) DEFAULT '0' COMMENT '是否发布',
  PRIMARY KEY (`resume_id`),
  KEY `stu_id` (`stu_id`),
  CONSTRAINT `resume_ibfk_1` FOREIGN KEY (`stu_id`) REFERENCES `graduate` (`stu_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resume`
--

LOCK TABLES `resume` WRITE;
/*!40000 ALTER TABLE `resume` DISABLE KEYS */;
INSERT INTO `resume` VALUES (1,'20240001','2026-06-19','开发工程师','英语','cet-6','熟悉python',NULL,'124324234','31231321@qq.com','213','123','321',0);
/*!40000 ALTER TABLE `resume` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_fair_booth_allocation`
--

DROP TABLE IF EXISTS `v_fair_booth_allocation`;
/*!50001 DROP VIEW IF EXISTS `v_fair_booth_allocation`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_fair_booth_allocation` AS SELECT 
 1 AS `fair_id`,
 1 AS `fair_name`,
 1 AS `fair_time`,
 1 AS `location`,
 1 AS `booth_no`,
 1 AS `is_occupied`,
 1 AS `employer_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_graduate_job_info`
--

DROP TABLE IF EXISTS `v_graduate_job_info`;
/*!50001 DROP VIEW IF EXISTS `v_graduate_job_info`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_graduate_job_info` AS SELECT 
 1 AS `stu_id`,
 1 AS `name`,
 1 AS `major`,
 1 AS `education`,
 1 AS `job_intention`,
 1 AS `phone`,
 1 AS `email`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_fair_booth_allocation`
--

/*!50001 DROP VIEW IF EXISTS `v_fair_booth_allocation`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = gbk */;
/*!50001 SET character_set_results     = gbk */;
/*!50001 SET collation_connection      = gbk_chinese_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_fair_booth_allocation` AS select `jf`.`fair_id` AS `fair_id`,`jf`.`title` AS `fair_name`,`jf`.`fair_time` AS `fair_time`,`jf`.`location` AS `location`,`b`.`booth_no` AS `booth_no`,`b`.`is_occupied` AS `is_occupied`,`e`.`name` AS `employer_name` from ((`jobfair` `jf` left join `booth` `b` on((`jf`.`fair_id` = `b`.`fair_id`))) left join `employer` `e` on((`b`.`employer_id` = `e`.`employer_id`))) where (`jf`.`is_published` = '��') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_graduate_job_info`
--

/*!50001 DROP VIEW IF EXISTS `v_graduate_job_info`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = gbk */;
/*!50001 SET character_set_results     = gbk */;
/*!50001 SET collation_connection      = gbk_chinese_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_graduate_job_info` AS select `g`.`stu_id` AS `stu_id`,`g`.`name` AS `name`,`g`.`major` AS `major`,`g`.`education` AS `education`,`r`.`job_intention` AS `job_intention`,`r`.`phone` AS `phone`,`r`.`email` AS `email` from (`graduate` `g` left join `resume` `r` on((`g`.`stu_id` = `r`.`stu_id`))) where ((`r`.`is_published` = true) or (`r`.`is_published` is null)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-07 12:29:22
