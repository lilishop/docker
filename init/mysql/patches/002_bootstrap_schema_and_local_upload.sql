-- 首次启动补齐商品参数关联表，并让默认上传走本地文件存储。
CREATE TABLE IF NOT EXISTS `li_category_parameter` (
  `id` bigint NOT NULL COMMENT 'ID',
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '创建者',
  `create_time` datetime(6) DEFAULT NULL COMMENT '创建时间',
  `delete_flag` bit(1) DEFAULT NULL COMMENT '删除标志 true/false 删除/未删除',
  `update_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '更新者',
  `update_time` datetime(6) DEFAULT NULL COMMENT '更新时间',
  `category_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分类ID',
  `parameter_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '参数ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_li_category_parameter_category_parameter` (`category_id`,`parameter_id`) USING BTREE,
  KEY `idx_li_category_parameter_category_id` (`category_id`) USING BTREE,
  KEY `idx_li_category_parameter_parameter_id` (`parameter_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='分类-参数关联';

INSERT IGNORE INTO `li_category_parameter` (`id`, `category_id`, `parameter_id`)
SELECT `id`, `category_id`, `id`
FROM `li_parameters`
WHERE `category_id` IS NOT NULL;

INSERT INTO `li_setting` (
  `id`,
  `create_by`,
  `create_time`,
  `delete_flag`,
  `update_by`,
  `update_time`,
  `setting_value`
) VALUES (
  'OSS_SETTING',
  'admin',
  NOW(6),
  b'0',
  'admin',
  NOW(6),
  '{"type":"LOCAL","localFilePath":"data/uploads","localFileUrlPrefix":"/files"}'
) ON DUPLICATE KEY UPDATE
  `update_by` = 'admin',
  `update_time` = NOW(6),
  `setting_value` = '{"type":"LOCAL","localFilePath":"data/uploads","localFileUrlPrefix":"/files"}';
