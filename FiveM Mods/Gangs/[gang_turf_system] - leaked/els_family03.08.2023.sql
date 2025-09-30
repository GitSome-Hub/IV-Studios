CREATE TABLE IF NOT EXISTS `els_familys` (
  `owner_id` longtext DEFAULT NULL,
  `family_id` int(4) DEFAULT NULL,
  `family_name` varchar(50) DEFAULT NULL,
  `family_img` longtext DEFAULT NULL,
  `family_meta` varchar(9999) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `owner_name` varchar(50) DEFAULT NULL,
  `family_chat` longtext DEFAULT NULL,
  KEY `family_id` (`family_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;