/*
SQLyog Community v13.1.7 (64 bit)
MySQL - 8.0.30 : Database - db_books
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`db_books` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `db_books`;

/*Table structure for table `ar_internal_metadata` */

DROP TABLE IF EXISTS `ar_internal_metadata`;

CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ar_internal_metadata` */

/*Table structure for table `authors` */

DROP TABLE IF EXISTS `authors`;

CREATE TABLE `authors` (
  `authors_id` int NOT NULL AUTO_INCREMENT,
  `authors_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`authors_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `authors` */

insert  into `authors`(`authors_id`,`authors_name`) values 
(1,'James Bon'),
(2,'Ikbal');

/*Table structure for table `books` */

DROP TABLE IF EXISTS `books`;

CREATE TABLE `books` (
  `book_id` int NOT NULL AUTO_INCREMENT,
  `book_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `author_id` int NOT NULL,
  `book_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `tahun_terbit` varchar(5) DEFAULT '',
  PRIMARY KEY (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `books` */

insert  into `books`(`book_id`,`book_name`,`author_id`,`book_content`,`tahun_terbit`) values 
(1,'Sangkuriang',1,'Bercerita tentang seorang pemuda sakti bernama Sangkuriang, yang jatuh cinta dan ingin menikahi Dayang Sumbi, ibu kandungnya. Dayang Sumbi mengajukan syarat agar Sangkuriang membangun perahu dalam satu malam. Sangkuriang hampir menyelesaikan pekerjaan tersebut, tetapi Dayang Sumbi menggagalkannya dengan cara memaksa ayam berkokok pada saat hari masih gelap gulita. Sangkuriang marah dan menendang kapal yang sedang dibuatnya hingga tertelungkup berubah menjadi gunung yang dikenal sebagai Tangkuban Parahu. Kemudian, dia mengejar Dayang Sumbi yang berubah menjadi bukit dikenal sebagai gunung Putri. Sangkuriang yang tidak dapat menemukan Dayang Sumbi pun akhirnya menghilang ke alam gaib. Pesan moral: bersikaplah jujur dan hindari perbuatan curang.','2016'),
(15,'Situ Bagendit',2,'Situ Bagendit merupakan cerita rakyat mengenai asal-usul situ Bagendit, di mana pada zaman dahulu, Nyai Bagendit, seorang janda kaya yang pelit, memperlakukan orang disekitarnya dengan kejam. Suatu hari, Nyai Bagendit menolak membantu kakek pengembara yang haus dengan cara yang kasar sehingga Sang Kakek pun murka, ia menciptakan banjir besar yang menenggelamkan Nyai Bagendit dengan seluruh kekayaannya. Danau Bagendit pun terbentuk, mengajarkan kita untuk menjauhi sifat pelit dan sombong.','2010'),
(17,'Heawani',2,'ayam','2021'),
(18,'Robot',1,'ayam','2021'),
(19,'Robot1',1,'ayam 1','2021'),
(20,'Robot2',1,'ayam 2','2021');

/*Table structure for table `schema_migrations` */

DROP TABLE IF EXISTS `schema_migrations`;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `schema_migrations` */

/*Table structure for table `users` */

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `users_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(54) NOT NULL DEFAULT '',
  `password` varchar(100) NOT NULL DEFAULT '',
  `level` int NOT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime(6) DEFAULT NULL,
  `remember_created_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`users_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `users` */

insert  into `users`(`users_id`,`username`,`password`,`level`,`email`,`encrypted_password`,`reset_password_token`,`reset_password_sent_at`,`remember_created_at`) values 
(1,'admin','81dc9bdb52d04dc20036dbd8313ed055',1,'bilmanprogrammer@gmail.com','',NULL,NULL,NULL),
(3,'user','81dc9bdb52d04dc20036dbd8313ed055',1,'','data@gmail.com',NULL,NULL,NULL);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
