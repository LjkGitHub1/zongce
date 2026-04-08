/*
 Navicat Premium Dump SQL

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80039 (8.0.39)
 Source Host           : localhost:3306
 Source Schema         : zongcesys

 Target Server Type    : MySQL
 Target Server Version : 80039 (8.0.39)
 File Encoding         : 65001

 Date: 12/03/2026 10:14:57
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for announcement
-- ----------------------------
DROP TABLE IF EXISTS `announcement`;
CREATE TABLE `announcement`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_top` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `start_time` datetime(6) NULL DEFAULT NULL,
  `end_time` datetime(6) NULL DEFAULT NULL,
  `publisher_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `view_count` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `publisher_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `announcement_category_098c3d2a`(`category` ASC) USING BTREE,
  INDEX `announcement_is_top_6ba384e2`(`is_top` ASC) USING BTREE,
  INDEX `announcement_is_active_eed1f3d9`(`is_active` ASC) USING BTREE,
  INDEX `announcement_created_at_7503a2bc`(`created_at` ASC) USING BTREE,
  INDEX `announcement_publisher_id_8af3cd4c_fk_user_id`(`publisher_id` ASC) USING BTREE,
  CONSTRAINT `announcement_publisher_id_8af3cd4c_fk_user_id` FOREIGN KEY (`publisher_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of announcement
-- ----------------------------

-- ----------------------------
-- Table structure for audit_record
-- ----------------------------
DROP TABLE IF EXISTS `audit_record`;
CREATE TABLE `audit_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `material_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `material_id` bigint NOT NULL,
  `auditor_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `result` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_at` datetime(6) NOT NULL,
  `auditor_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `audit_record_material_type_cf27776f`(`material_type` ASC) USING BTREE,
  INDEX `audit_record_material_id_c9259769`(`material_id` ASC) USING BTREE,
  INDEX `audit_record_result_98cc3190`(`result` ASC) USING BTREE,
  INDEX `audit_record_created_at_d25bd057`(`created_at` ASC) USING BTREE,
  INDEX `audit_record_auditor_id_0aa55faa_fk_user_id`(`auditor_id` ASC) USING BTREE,
  INDEX `audit_recor_materia_d3af3c_idx`(`material_type` ASC, `material_id` ASC) USING BTREE,
  CONSTRAINT `audit_record_auditor_id_0aa55faa_fk_user_id` FOREIGN KEY (`auditor_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of audit_record
-- ----------------------------

-- ----------------------------
-- Table structure for auth_group
-- ----------------------------
DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE `auth_group`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_group
-- ----------------------------

-- ----------------------------
-- Table structure for auth_group_permissions
-- ----------------------------
DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE `auth_group_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_group_permissions_group_id_permission_id_0cd325b0_uniq`(`group_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_group_permissions
-- ----------------------------

-- ----------------------------
-- Table structure for auth_permission
-- ----------------------------
DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE `auth_permission`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_permission_content_type_id_codename_01ab375a_uniq`(`content_type_id` ASC, `codename` ASC) USING BTREE,
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 81 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_permission
-- ----------------------------
INSERT INTO `auth_permission` VALUES (1, 'Can add log entry', 1, 'add_logentry');
INSERT INTO `auth_permission` VALUES (2, 'Can change log entry', 1, 'change_logentry');
INSERT INTO `auth_permission` VALUES (3, 'Can delete log entry', 1, 'delete_logentry');
INSERT INTO `auth_permission` VALUES (4, 'Can view log entry', 1, 'view_logentry');
INSERT INTO `auth_permission` VALUES (5, 'Can add permission', 2, 'add_permission');
INSERT INTO `auth_permission` VALUES (6, 'Can change permission', 2, 'change_permission');
INSERT INTO `auth_permission` VALUES (7, 'Can delete permission', 2, 'delete_permission');
INSERT INTO `auth_permission` VALUES (8, 'Can view permission', 2, 'view_permission');
INSERT INTO `auth_permission` VALUES (9, 'Can add group', 3, 'add_group');
INSERT INTO `auth_permission` VALUES (10, 'Can change group', 3, 'change_group');
INSERT INTO `auth_permission` VALUES (11, 'Can delete group', 3, 'delete_group');
INSERT INTO `auth_permission` VALUES (12, 'Can view group', 3, 'view_group');
INSERT INTO `auth_permission` VALUES (13, 'Can add content type', 4, 'add_contenttype');
INSERT INTO `auth_permission` VALUES (14, 'Can change content type', 4, 'change_contenttype');
INSERT INTO `auth_permission` VALUES (15, 'Can delete content type', 4, 'delete_contenttype');
INSERT INTO `auth_permission` VALUES (16, 'Can view content type', 4, 'view_contenttype');
INSERT INTO `auth_permission` VALUES (17, 'Can add session', 5, 'add_session');
INSERT INTO `auth_permission` VALUES (18, 'Can change session', 5, 'change_session');
INSERT INTO `auth_permission` VALUES (19, 'Can delete session', 5, 'delete_session');
INSERT INTO `auth_permission` VALUES (20, 'Can view session', 5, 'view_session');
INSERT INTO `auth_permission` VALUES (21, 'Can add 用户', 6, 'add_user');
INSERT INTO `auth_permission` VALUES (22, 'Can change 用户', 6, 'change_user');
INSERT INTO `auth_permission` VALUES (23, 'Can delete 用户', 6, 'delete_user');
INSERT INTO `auth_permission` VALUES (24, 'Can view 用户', 6, 'view_user');
INSERT INTO `auth_permission` VALUES (25, 'Can add 文件', 7, 'add_file');
INSERT INTO `auth_permission` VALUES (26, 'Can change 文件', 7, 'change_file');
INSERT INTO `auth_permission` VALUES (27, 'Can delete 文件', 7, 'delete_file');
INSERT INTO `auth_permission` VALUES (28, 'Can view 文件', 7, 'view_file');
INSERT INTO `auth_permission` VALUES (29, 'Can add 专著', 8, 'add_monograph');
INSERT INTO `auth_permission` VALUES (30, 'Can change 专著', 8, 'change_monograph');
INSERT INTO `auth_permission` VALUES (31, 'Can delete 专著', 8, 'delete_monograph');
INSERT INTO `auth_permission` VALUES (32, 'Can view 专著', 8, 'view_monograph');
INSERT INTO `auth_permission` VALUES (33, 'Can add 其他学术成果', 9, 'add_otheracademic');
INSERT INTO `auth_permission` VALUES (34, 'Can change 其他学术成果', 9, 'change_otheracademic');
INSERT INTO `auth_permission` VALUES (35, 'Can delete 其他学术成果', 9, 'delete_otheracademic');
INSERT INTO `auth_permission` VALUES (36, 'Can view 其他学术成果', 9, 'view_otheracademic');
INSERT INTO `auth_permission` VALUES (37, 'Can add 其他实践活动', 10, 'add_otherpractice');
INSERT INTO `auth_permission` VALUES (38, 'Can change 其他实践活动', 10, 'change_otherpractice');
INSERT INTO `auth_permission` VALUES (39, 'Can delete 其他实践活动', 10, 'delete_otherpractice');
INSERT INTO `auth_permission` VALUES (40, 'Can view 其他实践活动', 10, 'view_otherpractice');
INSERT INTO `auth_permission` VALUES (41, 'Can add 论文', 11, 'add_paper');
INSERT INTO `auth_permission` VALUES (42, 'Can change 论文', 11, 'change_paper');
INSERT INTO `auth_permission` VALUES (43, 'Can delete 论文', 11, 'delete_paper');
INSERT INTO `auth_permission` VALUES (44, 'Can view 论文', 11, 'view_paper');
INSERT INTO `auth_permission` VALUES (45, 'Can add 课题项目', 12, 'add_researchproject');
INSERT INTO `auth_permission` VALUES (46, 'Can change 课题项目', 12, 'change_researchproject');
INSERT INTO `auth_permission` VALUES (47, 'Can delete 课题项目', 12, 'delete_researchproject');
INSERT INTO `auth_permission` VALUES (48, 'Can view 课题项目', 12, 'view_researchproject');
INSERT INTO `auth_permission` VALUES (49, 'Can add 社会实践调研', 13, 'add_socialpractice');
INSERT INTO `auth_permission` VALUES (50, 'Can change 社会实践调研', 13, 'change_socialpractice');
INSERT INTO `auth_permission` VALUES (51, 'Can delete 社会实践调研', 13, 'delete_socialpractice');
INSERT INTO `auth_permission` VALUES (52, 'Can view 社会实践调研', 13, 'view_socialpractice');
INSERT INTO `auth_permission` VALUES (53, 'Can add 服务社会', 14, 'add_socialservice');
INSERT INTO `auth_permission` VALUES (54, 'Can change 服务社会', 14, 'change_socialservice');
INSERT INTO `auth_permission` VALUES (55, 'Can delete 服务社会', 14, 'delete_socialservice');
INSERT INTO `auth_permission` VALUES (56, 'Can view 服务社会', 14, 'view_socialservice');
INSERT INTO `auth_permission` VALUES (57, 'Can add 科技竞赛', 15, 'add_technologycompetition');
INSERT INTO `auth_permission` VALUES (58, 'Can change 科技竞赛', 15, 'change_technologycompetition');
INSERT INTO `auth_permission` VALUES (59, 'Can delete 科技竞赛', 15, 'delete_technologycompetition');
INSERT INTO `auth_permission` VALUES (60, 'Can view 科技竞赛', 15, 'view_technologycompetition');
INSERT INTO `auth_permission` VALUES (61, 'Can add 公告', 16, 'add_announcement');
INSERT INTO `auth_permission` VALUES (62, 'Can change 公告', 16, 'change_announcement');
INSERT INTO `auth_permission` VALUES (63, 'Can delete 公告', 16, 'delete_announcement');
INSERT INTO `auth_permission` VALUES (64, 'Can view 公告', 16, 'view_announcement');
INSERT INTO `auth_permission` VALUES (65, 'Can add 审核记录', 17, 'add_auditrecord');
INSERT INTO `auth_permission` VALUES (66, 'Can change 审核记录', 17, 'change_auditrecord');
INSERT INTO `auth_permission` VALUES (67, 'Can delete 审核记录', 17, 'delete_auditrecord');
INSERT INTO `auth_permission` VALUES (68, 'Can view 审核记录', 17, 'view_auditrecord');
INSERT INTO `auth_permission` VALUES (69, 'Can add 消息', 18, 'add_message');
INSERT INTO `auth_permission` VALUES (70, 'Can change 消息', 18, 'change_message');
INSERT INTO `auth_permission` VALUES (71, 'Can delete 消息', 18, 'delete_message');
INSERT INTO `auth_permission` VALUES (72, 'Can view 消息', 18, 'view_message');
INSERT INTO `auth_permission` VALUES (73, 'Can add 操作日志', 19, 'add_operationlog');
INSERT INTO `auth_permission` VALUES (74, 'Can change 操作日志', 19, 'change_operationlog');
INSERT INTO `auth_permission` VALUES (75, 'Can delete 操作日志', 19, 'delete_operationlog');
INSERT INTO `auth_permission` VALUES (76, 'Can view 操作日志', 19, 'view_operationlog');
INSERT INTO `auth_permission` VALUES (77, 'Can add 权限配置', 20, 'add_permissionconfig');
INSERT INTO `auth_permission` VALUES (78, 'Can change 权限配置', 20, 'change_permissionconfig');
INSERT INTO `auth_permission` VALUES (79, 'Can delete 权限配置', 20, 'delete_permissionconfig');
INSERT INTO `auth_permission` VALUES (80, 'Can view 权限配置', 20, 'view_permissionconfig');

-- ----------------------------
-- Table structure for django_admin_log
-- ----------------------------
DROP TABLE IF EXISTS `django_admin_log`;
CREATE TABLE `django_admin_log`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `object_repr` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_flag` smallint UNSIGNED NOT NULL,
  `change_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int NULL DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `django_admin_log_content_type_id_c4bce8eb_fk_django_co`(`content_type_id` ASC) USING BTREE,
  INDEX `django_admin_log_user_id_c564eba6_fk_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `django_admin_log_chk_1` CHECK (`action_flag` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_admin_log
-- ----------------------------

-- ----------------------------
-- Table structure for django_content_type
-- ----------------------------
DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE `django_content_type`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `django_content_type_app_label_model_76bd3d3b_uniq`(`app_label` ASC, `model` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_content_type
-- ----------------------------
INSERT INTO `django_content_type` VALUES (1, 'admin', 'logentry');
INSERT INTO `django_content_type` VALUES (3, 'auth', 'group');
INSERT INTO `django_content_type` VALUES (2, 'auth', 'permission');
INSERT INTO `django_content_type` VALUES (4, 'contenttypes', 'contenttype');
INSERT INTO `django_content_type` VALUES (7, 'materials', 'file');
INSERT INTO `django_content_type` VALUES (8, 'materials', 'monograph');
INSERT INTO `django_content_type` VALUES (9, 'materials', 'otheracademic');
INSERT INTO `django_content_type` VALUES (10, 'materials', 'otherpractice');
INSERT INTO `django_content_type` VALUES (11, 'materials', 'paper');
INSERT INTO `django_content_type` VALUES (12, 'materials', 'researchproject');
INSERT INTO `django_content_type` VALUES (13, 'materials', 'socialpractice');
INSERT INTO `django_content_type` VALUES (14, 'materials', 'socialservice');
INSERT INTO `django_content_type` VALUES (15, 'materials', 'technologycompetition');
INSERT INTO `django_content_type` VALUES (5, 'sessions', 'session');
INSERT INTO `django_content_type` VALUES (16, 'system', 'announcement');
INSERT INTO `django_content_type` VALUES (17, 'system', 'auditrecord');
INSERT INTO `django_content_type` VALUES (18, 'system', 'message');
INSERT INTO `django_content_type` VALUES (19, 'system', 'operationlog');
INSERT INTO `django_content_type` VALUES (20, 'system', 'permissionconfig');
INSERT INTO `django_content_type` VALUES (6, 'users', 'user');

-- ----------------------------
-- Table structure for django_migrations
-- ----------------------------
DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE `django_migrations`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_migrations
-- ----------------------------
INSERT INTO `django_migrations` VALUES (1, 'contenttypes', '0001_initial', '2026-01-12 09:47:24.487109');
INSERT INTO `django_migrations` VALUES (2, 'contenttypes', '0002_remove_content_type_name', '2026-01-12 09:47:24.561090');
INSERT INTO `django_migrations` VALUES (3, 'auth', '0001_initial', '2026-01-12 09:47:24.835355');
INSERT INTO `django_migrations` VALUES (4, 'auth', '0002_alter_permission_name_max_length', '2026-01-12 09:47:24.906616');
INSERT INTO `django_migrations` VALUES (5, 'auth', '0003_alter_user_email_max_length', '2026-01-12 09:47:24.911407');
INSERT INTO `django_migrations` VALUES (6, 'auth', '0004_alter_user_username_opts', '2026-01-12 09:47:24.915868');
INSERT INTO `django_migrations` VALUES (7, 'auth', '0005_alter_user_last_login_null', '2026-01-12 09:47:24.920694');
INSERT INTO `django_migrations` VALUES (8, 'auth', '0006_require_contenttypes_0002', '2026-01-12 09:47:24.922727');
INSERT INTO `django_migrations` VALUES (9, 'auth', '0007_alter_validators_add_error_messages', '2026-01-12 09:47:24.930065');
INSERT INTO `django_migrations` VALUES (10, 'auth', '0008_alter_user_username_max_length', '2026-01-12 09:47:24.936103');
INSERT INTO `django_migrations` VALUES (11, 'auth', '0009_alter_user_last_name_max_length', '2026-01-12 09:47:24.942654');
INSERT INTO `django_migrations` VALUES (12, 'auth', '0010_alter_group_name_max_length', '2026-01-12 09:47:24.958593');
INSERT INTO `django_migrations` VALUES (13, 'auth', '0011_update_proxy_permissions', '2026-01-12 09:47:24.965002');
INSERT INTO `django_migrations` VALUES (14, 'auth', '0012_alter_user_first_name_max_length', '2026-01-12 09:47:24.969858');
INSERT INTO `django_migrations` VALUES (15, 'users', '0001_initial', '2026-01-12 09:47:25.302730');
INSERT INTO `django_migrations` VALUES (16, 'admin', '0001_initial', '2026-01-12 09:47:25.432813');
INSERT INTO `django_migrations` VALUES (17, 'admin', '0002_logentry_remove_auto_add', '2026-01-12 09:47:25.438504');
INSERT INTO `django_migrations` VALUES (18, 'admin', '0003_logentry_add_action_flag_choices', '2026-01-12 09:47:25.444236');
INSERT INTO `django_migrations` VALUES (19, 'materials', '0001_initial', '2026-01-12 09:47:26.042083');
INSERT INTO `django_migrations` VALUES (20, 'materials', '0002_initial', '2026-01-12 09:47:26.140411');
INSERT INTO `django_migrations` VALUES (21, 'sessions', '0001_initial', '2026-01-12 09:47:26.173683');
INSERT INTO `django_migrations` VALUES (22, 'system', '0001_initial', '2026-01-12 09:47:26.529359');
INSERT INTO `django_migrations` VALUES (23, 'system', '0002_initial', '2026-01-12 09:47:26.902893');
INSERT INTO `django_migrations` VALUES (24, 'system', '0003_remove_permissionconfig_permission__identit_2ab50c_idx_and_more', '2026-01-13 09:57:59.547987');
INSERT INTO `django_migrations` VALUES (25, 'materials', '0003_add_new_fields', '2026-01-27 03:37:51.431005');

-- ----------------------------
-- Table structure for django_session
-- ----------------------------
DROP TABLE IF EXISTS `django_session`;
CREATE TABLE `django_session`  (
  `session_key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`) USING BTREE,
  INDEX `django_session_expire_date_a5c62663`(`expire_date` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_session
-- ----------------------------
INSERT INTO `django_session` VALUES ('h3mp1btuw756ptj4t0fwco1o0uv9qg4y', '.eJxVjMsOwiAQRf-FtSFQHp1x6d5vINMBpGogKe3K-O_apAvd3nPOfYlA21rC1tMS5ijOQovT7zYRP1LdQbxTvTXJra7LPMldkQft8tpiel4O9--gUC_f2mnlPY7ZWcyogRQn4GiZkBQY6wwwKDQmW58sEeaIxnvvcmZw4zCI9wfHOTc6:1vkyMC:_nHhUJdqhD-hHj5vJtJQsGFpDii_V2MS6afY-TbzYKs', '2026-02-11 05:44:48.346443');

-- ----------------------------
-- Table structure for file
-- ----------------------------
DROP TABLE IF EXISTS `file`;
CREATE TABLE `file`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint NOT NULL,
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `file_ext` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `material_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `material_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `upload_user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `file_material_type_8556d38b`(`material_type` ASC) USING BTREE,
  INDEX `file_material_id_db66bb4c`(`material_id` ASC) USING BTREE,
  INDEX `file_created_at_651c59e6`(`created_at` ASC) USING BTREE,
  INDEX `file_upload_user_id_741786b4_fk_user_id`(`upload_user_id` ASC) USING BTREE,
  INDEX `file_materia_b2a013_idx`(`material_type` ASC, `material_id` ASC) USING BTREE,
  CONSTRAINT `file_upload_user_id_741786b4_fk_user_id` FOREIGN KEY (`upload_user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of file
-- ----------------------------
INSERT INTO `file` VALUES (1, '李金康-中国发展研究基金会-2025年6月.pdf', '李金康-中国发展研究基金会-2025年6月.pdf', 'research_project/1/李金康-中国发展研究基金会-2025年6月.pdf', 2230360, 'application/pdf', '.pdf', 'research_project', 1, '2026-01-14 06:31:32.479701', 7);
INSERT INTO `file` VALUES (2, 'avatar-Cntrmew0.png', 'avatar-Cntrmew0.png', 'technology_competition/4/avatar-Cntrmew0.png', 53959, 'image/png', '.png', 'technology_competition', 4, '2026-01-21 01:47:54.518013', 6);
INSERT INTO `file` VALUES (3, 'bg-oEDCYcDF.png', 'bg-oEDCYcDF.png', 'technology_competition/5/bg-oEDCYcDF.png', 17468, 'image/png', '.png', 'technology_competition', 5, '2026-01-21 01:48:55.757342', 6);
INSERT INTO `file` VALUES (4, 'bg-oEDCYcDF.png', 'bg-oEDCYcDF.png', 'technology_competition/6/bg-oEDCYcDF.png', 17468, 'image/png', '.png', 'technology_competition', 6, '2026-01-21 02:06:03.039688', 6);
INSERT INTO `file` VALUES (5, 'bg-oEDCYcDF.png', 'bg-oEDCYcDF.png', 'research_project/2/bg-oEDCYcDF.png', 17468, 'image/png', '.png', 'research_project', 2, '2026-01-21 03:03:38.543012', 10);
INSERT INTO `file` VALUES (6, 'bg-oEDCYcDF.png', 'bg-oEDCYcDF.png', 'monograph/1/bg-oEDCYcDF.png', 17468, 'image/png', '.png', 'monograph', 1, '2026-01-21 03:04:43.439631', 10);
INSERT INTO `file` VALUES (7, 'bg-oEDCYcDF.png', 'bg-oEDCYcDF.png', 'paper/1/bg-oEDCYcDF.png', 17468, 'image/png', '.png', 'paper', 1, '2026-01-21 03:05:30.727871', 10);
INSERT INTO `file` VALUES (8, 'avatar-Cntrmew0.png', 'avatar-Cntrmew0.png', 'other_academic/1/avatar-Cntrmew0.png', 53959, 'image/png', '.png', 'other_academic', 1, '2026-01-21 03:05:41.245506', 10);
INSERT INTO `file` VALUES (9, 'avatar-Cntrmew0.png', 'avatar-Cntrmew0.png', 'technology_competition/7/avatar-Cntrmew0.png', 53959, 'image/png', '.png', 'technology_competition', 7, '2026-01-21 03:08:35.388182', 10);
INSERT INTO `file` VALUES (10, 'avatar-Cntrmew0.png', 'avatar-Cntrmew0.png', 'social_practice/1/avatar-Cntrmew0.png', 53959, 'image/png', '.png', 'social_practice', 1, '2026-01-21 03:09:05.904511', 10);
INSERT INTO `file` VALUES (11, 'bg-oEDCYcDF.png', 'bg-oEDCYcDF.png', 'social_service/1/bg-oEDCYcDF.png', 17468, 'image/png', '.png', 'social_service', 1, '2026-01-21 03:09:28.874386', 10);
INSERT INTO `file` VALUES (12, 'avatar-Cntrmew0.png', 'avatar-Cntrmew0.png', 'other_practice/1/avatar-Cntrmew0.png', 53959, 'image/png', '.png', 'other_practice', 1, '2026-01-21 03:10:00.680490', 10);

-- ----------------------------
-- Table structure for message
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL,
  `related_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `related_id` bigint NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `message_message_type_8f0bc0b7`(`message_type` ASC) USING BTREE,
  INDEX `message_is_read_d318bff8`(`is_read` ASC) USING BTREE,
  INDEX `message_created_at_1730c33f`(`created_at` ASC) USING BTREE,
  INDEX `message_user_id_60e6a50a_fk_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `message_user_id_60e6a50a_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of message
-- ----------------------------

-- ----------------------------
-- Table structure for monograph
-- ----------------------------
DROP TABLE IF EXISTS `monograph`;
CREATE TABLE `monograph`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `publish` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publish_date` date NULL DEFAULT NULL,
  `number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `supervisor` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `word_count` int NULL DEFAULT NULL,
  `author` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `remark` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `monograph_student_id_a91e54b8`(`student_id` ASC) USING BTREE,
  INDEX `monograph_status_1054a9b1`(`status` ASC) USING BTREE,
  INDEX `monograph_created_at_478175f0`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of monograph
-- ----------------------------
INSERT INTO `monograph` VALUES (1, '2424420037', '李丽梅', 'graduate', 'pending', '2026-01-21 03:04:43.395147', '2026-01-21 03:04:43.395147', '专著', '多少给多少', '2026-01-23', '8645312', '王敏', 15820, '成都市', '');

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `operation_log_operation_fc19dd7e`(`operation` ASC) USING BTREE,
  INDEX `operation_log_module_85d35d79`(`module` ASC) USING BTREE,
  INDEX `operation_log_created_at_c6f837fa`(`created_at` ASC) USING BTREE,
  INDEX `operation_log_user_id_dab8694c_fk_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `operation_log_user_id_dab8694c_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_log
-- ----------------------------
INSERT INTO `operation_log` VALUES (1, '李金康', '创建', '权限管理', 'POST /api/system/permission-configs/batch-update/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:15:48.404866', 1);
INSERT INTO `operation_log` VALUES (2, '王斌', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 03:16:10.243206', 6);
INSERT INTO `operation_log` VALUES (3, '陈艳', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 05:51:39.635557', 7);
INSERT INTO `operation_log` VALUES (4, '陈艳', '创建', '材料管理', 'POST /api/materials/research-projects/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 06:31:32.370132', 7);
INSERT INTO `operation_log` VALUES (5, '陈艳', '创建', '材料管理', 'POST /api/materials/research-projects/1/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-14 06:31:32.492122', 7);
INSERT INTO `operation_log` VALUES (6, '王斌', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 01:34:36.060927', 6);
INSERT INTO `operation_log` VALUES (7, '王斌', '创建', '材料管理', 'POST /api/materials/technology-competitions/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 01:43:29.224666', 6);
INSERT INTO `operation_log` VALUES (8, '王斌', '创建', '材料管理', 'POST /api/materials/technology-competitions/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 01:43:42.337954', 6);
INSERT INTO `operation_log` VALUES (9, '王斌', '创建', '材料管理', 'POST /api/materials/technology-competitions/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 01:47:33.041876', 6);
INSERT INTO `operation_log` VALUES (10, '王斌', '创建', '材料管理', 'POST /api/materials/technology-competitions/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 01:47:54.477192', 6);
INSERT INTO `operation_log` VALUES (11, '王斌', '创建', '材料管理', 'POST /api/materials/technology-competitions/4/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 01:47:54.523282', 6);
INSERT INTO `operation_log` VALUES (12, '王斌', '创建', '材料管理', 'POST /api/materials/technology-competitions/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 01:48:55.722033', 6);
INSERT INTO `operation_log` VALUES (13, '王斌', '创建', '材料管理', 'POST /api/materials/technology-competitions/5/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 01:48:55.762387', 6);
INSERT INTO `operation_log` VALUES (14, '王斌', '创建', '材料管理', 'POST /api/materials/technology-competitions/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 02:06:03.001890', 6);
INSERT INTO `operation_log` VALUES (15, '王斌', '创建', '材料管理', 'POST /api/materials/technology-competitions/6/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 02:06:03.043202', 6);
INSERT INTO `operation_log` VALUES (16, '李金康', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 02:07:05.136903', 1);
INSERT INTO `operation_log` VALUES (17, '李丽梅', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 02:24:08.316024', 10);
INSERT INTO `operation_log` VALUES (18, '李丽梅', '创建', '材料管理', 'POST /api/materials/research-projects/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:03:38.510400', 10);
INSERT INTO `operation_log` VALUES (19, '李丽梅', '创建', '材料管理', 'POST /api/materials/research-projects/2/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:03:38.548125', 10);
INSERT INTO `operation_log` VALUES (20, '李丽梅', '创建', '材料管理', 'POST /api/materials/monographs/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:04:43.404458', 10);
INSERT INTO `operation_log` VALUES (21, '李丽梅', '创建', '材料管理', 'POST /api/materials/monographs/1/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:04:43.445207', 10);
INSERT INTO `operation_log` VALUES (22, '李丽梅', '创建', '材料管理', 'POST /api/materials/papers/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:05:30.699117', 10);
INSERT INTO `operation_log` VALUES (23, '李丽梅', '创建', '材料管理', 'POST /api/materials/papers/1/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:05:30.734911', 10);
INSERT INTO `operation_log` VALUES (24, '李丽梅', '创建', '材料管理', 'POST /api/materials/other-academics/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:05:41.209125', 10);
INSERT INTO `operation_log` VALUES (25, '李丽梅', '创建', '材料管理', 'POST /api/materials/other-academics/1/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:05:41.254594', 10);
INSERT INTO `operation_log` VALUES (26, '李丽梅', '创建', '材料管理', 'POST /api/materials/technology-competitions/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:08:35.339609', 10);
INSERT INTO `operation_log` VALUES (27, '李丽梅', '创建', '材料管理', 'POST /api/materials/technology-competitions/7/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:08:35.394897', 10);
INSERT INTO `operation_log` VALUES (28, '李丽梅', '创建', '材料管理', 'POST /api/materials/social-practices/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:09:05.876540', 10);
INSERT INTO `operation_log` VALUES (29, '李丽梅', '创建', '材料管理', 'POST /api/materials/social-practices/1/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:09:05.906521', 10);
INSERT INTO `operation_log` VALUES (30, '李丽梅', '创建', '材料管理', 'POST /api/materials/social-services/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:09:28.841297', 10);
INSERT INTO `operation_log` VALUES (31, '李丽梅', '创建', '材料管理', 'POST /api/materials/social-services/1/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:09:28.880014', 10);
INSERT INTO `operation_log` VALUES (32, '李丽梅', '创建', '材料管理', 'POST /api/materials/other-practices/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:10:00.648665', 10);
INSERT INTO `operation_log` VALUES (33, '李丽梅', '创建', '材料管理', 'POST /api/materials/other-practices/1/upload_files/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:10:00.684161', 10);
INSERT INTO `operation_log` VALUES (34, '李金康', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 03:22:33.664441', 1);
INSERT INTO `operation_log` VALUES (35, '王斌', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 05:48:34.670943', 6);
INSERT INTO `operation_log` VALUES (36, '李金康', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 05:49:06.739455', 1);
INSERT INTO `operation_log` VALUES (37, '李金康', '更新', '材料管理', 'PUT /api/materials/technology-competitions/5/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 08:58:29.084979', 1);
INSERT INTO `operation_log` VALUES (38, '李金康', '更新', '材料管理', 'PUT /api/materials/technology-competitions/6/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 08:59:01.769054', 1);
INSERT INTO `operation_log` VALUES (39, '李金康', '更新', '材料管理', 'PUT /api/materials/technology-competitions/7/', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-21 08:59:36.756162', 1);
INSERT INTO `operation_log` VALUES (40, '王斌', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-22 01:22:30.463420', 6);
INSERT INTO `operation_log` VALUES (41, '王斌', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-22 01:33:52.992652', 6);
INSERT INTO `operation_log` VALUES (42, '王斌', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-22 04:22:21.301781', 6);
INSERT INTO `operation_log` VALUES (43, '李金康', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '2026-01-22 04:32:39.498749', 1);
INSERT INTO `operation_log` VALUES (44, '李金康', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-27 03:29:32.812891', 1);
INSERT INTO `operation_log` VALUES (45, '李金康', '登录', '用户管理', '用户登录系统', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', '2026-03-12 01:27:16.375834', 1);

-- ----------------------------
-- Table structure for other_academic
-- ----------------------------
DROP TABLE IF EXISTS `other_academic`;
CREATE TABLE `other_academic`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `other_academic_student_id_953a3c71`(`student_id` ASC) USING BTREE,
  INDEX `other_academic_status_2f17e5e0`(`status` ASC) USING BTREE,
  INDEX `other_academic_created_at_af14dfa9`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of other_academic
-- ----------------------------
INSERT INTO `other_academic` VALUES (1, '2424420037', '李丽梅', 'graduate', 'pending', '2026-01-21 03:05:41.196214', '2026-01-21 03:05:41.196214', '方便查询');

-- ----------------------------
-- Table structure for other_practice
-- ----------------------------
DROP TABLE IF EXISTS `other_practice`;
CREATE TABLE `other_practice`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `date` date NULL DEFAULT NULL,
  `organization` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `author` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `remark` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `other_practice_student_id_715e4099`(`student_id` ASC) USING BTREE,
  INDEX `other_practice_status_f3622431`(`status` ASC) USING BTREE,
  INDEX `other_practice_created_at_c08d66e2`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of other_practice
-- ----------------------------
INSERT INTO `other_practice` VALUES (1, '2424420037', '李丽梅', 'graduate', 'pending', '2026-01-21 03:10:00.634501', '2026-01-21 03:10:00.634501', '其他实践', '发的那个简单', '2026-01-09', '的方式', '是否是', '郭德纲的', NULL, NULL);

-- ----------------------------
-- Table structure for paper
-- ----------------------------
DROP TABLE IF EXISTS `paper`;
CREATE TABLE `paper`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `title` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `publication` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publication_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publication_date` date NULL DEFAULT NULL,
  `journal_status` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `partition` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `supervisor` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `first_unit` tinyint(1) NULL DEFAULT NULL,
  `communication` tinyint(1) NULL DEFAULT NULL,
  `author` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `remark` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `paper_student_id_5af3a767`(`student_id` ASC) USING BTREE,
  INDEX `paper_status_d8f4dc6b`(`status` ASC) USING BTREE,
  INDEX `paper_created_at_4f04f5b9`(`created_at` ASC) USING BTREE,
  INDEX `paper_publication_date_0731bb8f`(`publication_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of paper
-- ----------------------------
INSERT INTO `paper` VALUES (1, '2424420037', '李丽梅', 'graduate', 'pending', '2026-01-21 03:05:30.682750', '2026-01-21 03:05:30.682750', '论文1', '合法的开始', '忽然辅导功课', '876453168453', '2026-01-01', '检测设备没办法接受', 'SCIQ2', '返回回到家', 1, 1, '第三方', '');

-- ----------------------------
-- Table structure for permission_config
-- ----------------------------
DROP TABLE IF EXISTS `permission_config`;
CREATE TABLE `permission_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_enabled` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `material_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `permission_config_identity_module_material_type_14fe9dba_uniq`(`identity` ASC, `module` ASC, `material_type` ASC) USING BTREE,
  INDEX `permission_config_identity_aedd3a92`(`identity` ASC) USING BTREE,
  INDEX `permission_config_module_377b5c18`(`module` ASC) USING BTREE,
  INDEX `permission__identit_5f47c2_idx`(`identity` ASC, `module` ASC, `material_type` ASC) USING BTREE,
  INDEX `permission_config_material_type_3ecd3019`(`material_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permission_config
-- ----------------------------
INSERT INTO `permission_config` VALUES (1, 'undergraduate', 'materials', 1, '2026-01-13 08:36:59.940957', '2026-01-14 03:15:48.381604', NULL);
INSERT INTO `permission_config` VALUES (2, 'undergraduate', 'practice', 1, '2026-01-13 09:06:53.698288', '2026-01-14 03:15:48.388025', NULL);
INSERT INTO `permission_config` VALUES (3, 'undergraduate', 'academic', 0, '2026-01-14 01:20:30.977983', '2026-01-14 01:33:32.975519', NULL);
INSERT INTO `permission_config` VALUES (4, 'undergraduate', 'statistics', 0, '2026-01-14 01:27:54.433301', '2026-01-14 01:27:54.433301', NULL);
INSERT INTO `permission_config` VALUES (5, 'graduate', 'statistics', 0, '2026-01-14 01:28:08.770706', '2026-01-14 01:28:08.770706', NULL);
INSERT INTO `permission_config` VALUES (6, 'undergraduate', 'dashboard', 1, '2026-01-14 01:41:44.278887', '2026-01-14 03:15:48.399857', NULL);
INSERT INTO `permission_config` VALUES (7, 'undergraduate', 'practice', 1, '2026-01-14 01:41:44.298634', '2026-01-14 03:15:48.394277', 'technology_competition');
INSERT INTO `permission_config` VALUES (8, 'graduate', 'dashboard', 1, '2026-01-14 01:44:43.236077', '2026-01-14 01:44:43.298886', NULL);
INSERT INTO `permission_config` VALUES (9, 'graduate', 'materials', 1, '2026-01-14 01:44:43.243664', '2026-01-14 01:44:43.243664', NULL);
INSERT INTO `permission_config` VALUES (10, 'graduate', 'academic', 1, '2026-01-14 01:44:43.248584', '2026-01-14 01:44:43.248584', NULL);
INSERT INTO `permission_config` VALUES (11, 'graduate', 'practice', 1, '2026-01-14 01:44:43.253847', '2026-01-14 01:44:43.253847', NULL);
INSERT INTO `permission_config` VALUES (12, 'graduate', 'academic', 1, '2026-01-14 01:44:43.259085', '2026-01-14 01:44:43.259085', 'research_project');
INSERT INTO `permission_config` VALUES (13, 'graduate', 'academic', 1, '2026-01-14 01:44:43.263095', '2026-01-14 01:44:43.263095', 'monograph');
INSERT INTO `permission_config` VALUES (14, 'graduate', 'academic', 1, '2026-01-14 01:44:43.268037', '2026-01-14 01:44:43.268037', 'paper');
INSERT INTO `permission_config` VALUES (15, 'graduate', 'academic', 1, '2026-01-14 01:44:43.273724', '2026-01-14 01:44:43.273724', 'other_academic');
INSERT INTO `permission_config` VALUES (16, 'graduate', 'practice', 1, '2026-01-14 01:44:43.279135', '2026-01-14 01:44:43.280133', 'technology_competition');
INSERT INTO `permission_config` VALUES (17, 'graduate', 'practice', 1, '2026-01-14 01:44:43.284068', '2026-01-14 01:44:43.284068', 'social_practice');
INSERT INTO `permission_config` VALUES (18, 'graduate', 'practice', 1, '2026-01-14 01:44:43.289147', '2026-01-14 01:44:43.289147', 'social_service');
INSERT INTO `permission_config` VALUES (19, 'graduate', 'practice', 1, '2026-01-14 01:44:43.293664', '2026-01-14 01:44:43.293664', 'other_practice');
INSERT INTO `permission_config` VALUES (20, 'undergraduate', 'practice', 0, '2026-01-14 02:37:19.912188', '2026-01-14 02:37:19.912188', 'social_service');

-- ----------------------------
-- Table structure for research_project
-- ----------------------------
DROP TABLE IF EXISTS `research_project`;
CREATE TABLE `research_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `project_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `start_date` date NULL DEFAULT NULL,
  `end_date` date NULL DEFAULT NULL,
  `funds` decimal(10, 2) NULL DEFAULT NULL,
  `number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `personnel` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `remark` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `host` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `participants` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `supervisor` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `research_project_student_id_58d65ce6`(`student_id` ASC) USING BTREE,
  INDEX `research_project_status_ded5502c`(`status` ASC) USING BTREE,
  INDEX `research_project_created_at_e4f6cacb`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of research_project
-- ----------------------------
INSERT INTO `research_project` VALUES (1, '2424420018', '陈艳', 'graduate', 'pending', '2026-01-14 06:31:32.355563', '2026-01-14 06:31:32.355563', '乐乐箱', '国家级', '2025-05-01', '2026-01-15', 30.00, '46843154781551', '张三、李四', '无', NULL, NULL, NULL, NULL);
INSERT INTO `research_project` VALUES (2, '2424420037', '李丽梅', 'graduate', 'pending', '2026-01-21 03:03:38.501770', '2026-01-21 03:03:38.501770', '课题1', '会发给大家', '2026-01-07', '2026-01-15', 2.00, '102452', '张三、李四', 'v', NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for social_practice
-- ----------------------------
DROP TABLE IF EXISTS `social_practice`;
CREATE TABLE `social_practice`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `date` date NULL DEFAULT NULL,
  `author` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `remark` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `host` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `participants` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `social_practice_student_id_041f78a8`(`student_id` ASC) USING BTREE,
  INDEX `social_practice_status_a43f5751`(`status` ASC) USING BTREE,
  INDEX `social_practice_created_at_c9558dd2`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of social_practice
-- ----------------------------
INSERT INTO `social_practice` VALUES (1, '2424420037', '李丽梅', 'graduate', 'pending', '2026-01-21 03:09:05.861111', '2026-01-21 03:09:05.861111', 'v和高科技时代', '梵蒂冈', '2026-01-15', '但是', 'vfdb', NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for social_service
-- ----------------------------
DROP TABLE IF EXISTS `social_service`;
CREATE TABLE `social_service`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `date` date NULL DEFAULT NULL,
  `author` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `remark` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `social_service_student_id_246ef008`(`student_id` ASC) USING BTREE,
  INDEX `social_service_status_0549253f`(`status` ASC) USING BTREE,
  INDEX `social_service_created_at_8348d070`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of social_service
-- ----------------------------
INSERT INTO `social_service` VALUES (1, '2424420037', '李丽梅', 'graduate', 'pending', '2026-01-21 03:09:28.828508', '2026-01-21 03:09:28.828508', '服务社会', '积分抵扣', '2026-01-16', '大师傅但是', '梵蒂冈的', NULL, NULL);

-- ----------------------------
-- Table structure for technology_competition
-- ----------------------------
DROP TABLE IF EXISTS `technology_competition`;
CREATE TABLE `technology_competition`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `competition` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_whitelist` tinyint(1) NULL DEFAULT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `level` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `award_date` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `grade` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `organization` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `group` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `author` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `supervisor` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `remark` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `leader` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `members` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `certificate_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `technology_competition_student_id_f4533f6e`(`student_id` ASC) USING BTREE,
  INDEX `technology_competition_status_37f4c69b`(`status` ASC) USING BTREE,
  INDEX `technology_competition_created_at_0bb66afa`(`created_at` ASC) USING BTREE,
  INDEX `technology_competition_level_ee2ed2bc`(`level` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of technology_competition
-- ----------------------------
INSERT INTO `technology_competition` VALUES (1, '2424420017', '王斌', 'undergraduate', 'pending', '2026-01-21 01:43:29.210013', '2026-01-21 01:43:29.210013', '数学建模比赛', 1, '全国大学生数学建模比赛', 'provincial', '2025年2月', '二等奖', '数学委员会', '团体', '王斌、张三、李四', '王敏', '', NULL, NULL, NULL, NULL);
INSERT INTO `technology_competition` VALUES (2, '2424420017', '王斌', 'undergraduate', 'pending', '2026-01-21 01:43:42.325364', '2026-01-21 01:43:42.325364', '数学建模比赛', 1, '全国大学生数学建模比赛', 'provincial', '2025年2月', '二等奖', '数学委员会', '团体', '王斌、张三、李四', '王敏', '', NULL, NULL, NULL, NULL);
INSERT INTO `technology_competition` VALUES (3, '2424420017', '王斌', 'undergraduate', 'pending', '2026-01-21 01:47:33.030656', '2026-01-21 01:47:33.030656', '数学建模', 1, '全国大学生数学建模比赛', 'provincial', '2025年8月', '二等奖', '数学委员会', '团体', '王斌、张三、李四', '王敏', '无', NULL, NULL, NULL, NULL);
INSERT INTO `technology_competition` VALUES (4, '2424420017', '王斌', 'undergraduate', 'pending', '2026-01-21 01:47:54.467682', '2026-01-21 01:47:54.467682', '数学建模', 1, '全国大学生数学建模比赛', 'provincial', '2025年8月', '二等奖', '数学委员会', '团体', '王斌、张三、李四', '王敏', '无', NULL, NULL, NULL, NULL);
INSERT INTO `technology_competition` VALUES (5, '2424420017', '王斌', 'undergraduate', 'pending', '2026-01-21 01:48:55.714227', '2026-01-21 08:58:29.047275', 'ccc', 0, 'hsfks', 'national', '35435', '一等奖', 'fdgd', 'dfgd', 'dgfhd', 'fdhd', '看见你', NULL, NULL, NULL, NULL);
INSERT INTO `technology_competition` VALUES (6, '2424420017', '王斌', 'undergraduate', 'pending', '2026-01-21 02:06:02.990329', '2026-01-21 08:59:01.752394', '的身份和', 1, '是否获奖时间', 'national', '2025-07', '三等奖', '发生口角的话', '个人', '李金康', '除非是的', '很多比赛机会', NULL, NULL, NULL, NULL);
INSERT INTO `technology_competition` VALUES (7, '2424420037', '李丽梅', 'graduate', 'pending', '2026-01-21 03:08:35.325102', '2026-01-21 08:59:36.745706', '科技竞赛1', 1, '梵蒂冈的', 'provincial', '2026-07', '优秀奖', '第三方', '团体', '感受到、放到数据库', '但是', '股份大股东', NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login` datetime(6) NULL DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `student_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `major` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `class` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `student_id`(`student_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'pbkdf2_sha256$720000$EkKuSEgZ58sdiNu5hS2aja$5QjCGF3Pl+NlLCTtDcuLJLOkTbtdPoq/7ps6N21KnTA=', '2026-01-28 05:44:48.323255', 1, '2424420013', '李金康', 'teacher', '', '24计算机技术', '', '', 1, 1, '2026-01-12 09:48:31.542036', '2026-01-13 08:10:29.589841');
INSERT INTO `user` VALUES (2, 'pbkdf2_sha256$720000$tToKDM6oJDxIhCfcCHrlna$aYkmZbBBu43okTrSpkUfBYhpPaOBhxtCT+EVceEL8Ds=', NULL, 0, '2424420010', '张三', 'undergraduate', '网络安全', '25F', '', '', 1, 0, '2026-01-13 07:57:36.810674', '2026-01-13 07:57:36.810674');
INSERT INTO `user` VALUES (3, 'pbkdf2_sha256$720000$Pap0VDbFPKUjE5MqMNvSwW$ggN5oFF5AgHUHc5KpUGVrsTlT9jZ+MTpyH0UiweyJ8g=', NULL, 0, '2424420014', '李四', 'graduate', '计算机技术', '24计算机技术', '2279421514@qq.com', '13888256345', 1, 0, '2026-01-13 08:06:03.158735', '2026-01-13 08:06:03.158735');
INSERT INTO `user` VALUES (4, 'pbkdf2_sha256$720000$kXOrLFV72f8j2LeraCOQSv$rWbRrMJBg9AFwW4CZrZNfMMBYU++RDTMKEp+Z3Qm9Ac=', NULL, 0, '2424420015', '王五', 'graduate', '计算机技术', '23计算机技术', '2279421514@qq.com', '13888256345', 1, 0, '2026-01-13 08:06:03.799387', '2026-01-13 08:06:03.799387');
INSERT INTO `user` VALUES (5, 'pbkdf2_sha256$720000$2jJ1zzI2S3cSWxwdebCvgr$NY3+RrTywDsN+WdGNDAZv+fto6fBwXWT3htOFzAdy40=', NULL, 0, '2424420016', '刘明', 'undergraduate', '网络安全', '25F', '2279421514@qq.com', '13888256345', 1, 0, '2026-01-13 08:06:04.540886', '2026-01-13 08:06:04.540886');
INSERT INTO `user` VALUES (6, 'pbkdf2_sha256$720000$JhvosiXFRnSut6BsANX62J$JrsF313kFC6+Ew4Zr3tla/38kTqs+2K2OfxpHe0yJAs=', NULL, 0, '2424420017', '王斌', 'undergraduate', '大数据', '24H', '2279421514@qq.com', '13888256345', 1, 0, '2026-01-13 08:06:05.344327', '2026-01-13 08:06:05.344833');
INSERT INTO `user` VALUES (7, 'pbkdf2_sha256$720000$QdQVwjYCKVRhQHyIrPiTW9$6kM7rJw8pbzpLTJRB7QhKzUebB0vBwIkG/l1qYFnbjQ=', NULL, 0, '2424420018', '陈艳', 'graduate', '教育技术', '23教技', '2279421514@qq.com', '13888256345', 1, 0, '2026-01-13 08:06:05.899895', '2026-01-13 08:06:05.899895');
INSERT INTO `user` VALUES (8, 'pbkdf2_sha256$720000$tRqVpEByF4LPjVmD8JMWml$NBmA6fys79ZrG3Uq8kxYtXTNABEBzAQ0uxKkGu4nO5c=', NULL, 0, '2424420019', '孙权', 'undergraduate', '计算机科学与技术', '22A', '2279421514@qq.com', '13888256345', 1, 0, '2026-01-13 08:06:06.411413', '2026-01-13 08:06:06.411413');
INSERT INTO `user` VALUES (9, 'pbkdf2_sha256$720000$YmF23eNmQTkm9tWKHtVgDA$BvccMc6//XQ9+SjBaTANzkeV6oiYRvQLiRNDuuGlZ3s=', NULL, 0, '2424420020', '张敏', 'undergraduate', '计算机科学与技术', '23B', '2279421514@qq.com', '13888256345', 1, 0, '2026-01-13 08:06:07.006780', '2026-01-13 08:06:07.006780');
INSERT INTO `user` VALUES (10, 'pbkdf2_sha256$720000$bZm5CyQKwEcHjvTPJpguS8$MJddprd4dffc1U4E4XbeEbM0UKWEh5cBkMc+iA6iCTM=', NULL, 0, '2424420037', '李丽梅', 'graduate', '计算机技术', '24计算机技术', '', '', 1, 0, '2026-01-13 08:11:47.393631', '2026-01-13 08:11:47.393631');
INSERT INTO `user` VALUES (11, 'pbkdf2_sha256$720000$vMA9rtznOXodimEX37Bh08$KYyZzks+cUDRXM55ws8hLRcUIYiuJknaG6ZYr/ljq9A=', NULL, 0, '2424420012', 'ljk', 'graduate', '计算机技术', '24计算机技术', '2279421514@qq.com', '1369524685', 1, 0, '2026-01-13 08:13:39.417791', '2026-01-13 08:13:39.417791');

-- ----------------------------
-- Table structure for user_groups
-- ----------------------------
DROP TABLE IF EXISTS `user_groups`;
CREATE TABLE `user_groups`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_groups_user_id_group_id_40beef00_uniq`(`user_id` ASC, `group_id` ASC) USING BTREE,
  INDEX `user_groups_group_id_b76f8aba_fk_auth_group_id`(`group_id` ASC) USING BTREE,
  CONSTRAINT `user_groups_group_id_b76f8aba_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `user_groups_user_id_abaea130_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_groups
-- ----------------------------

-- ----------------------------
-- Table structure for user_user_permissions
-- ----------------------------
DROP TABLE IF EXISTS `user_user_permissions`;
CREATE TABLE `user_user_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_user_permissions_user_id_permission_id_7dc6e2e0_uniq`(`user_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `user_user_permission_permission_id_9deb68a3_fk_auth_perm`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `user_user_permission_permission_id_9deb68a3_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `user_user_permissions_user_id_ed4a47ea_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_user_permissions
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
