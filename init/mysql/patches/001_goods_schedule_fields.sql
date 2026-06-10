-- 商品定时上下架字段补齐。
-- 当前代码实体会读取这些字段，旧初始化 SQL 未包含时会导致商品列表 SELECT 失败。
SET @col_exists := (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'li_goods'
    AND COLUMN_NAME = 'scheduled_upper_time'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `li_goods` ADD COLUMN `scheduled_upper_time` DATETIME NULL COMMENT ''计划上架时间''',
  'SELECT ''scheduled_upper_time exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists := (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'li_goods'
    AND COLUMN_NAME = 'scheduled_upper_reason'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `li_goods` ADD COLUMN `scheduled_upper_reason` VARCHAR(255) NULL COMMENT ''计划上架原因''',
  'SELECT ''scheduled_upper_reason exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists := (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'li_goods'
    AND COLUMN_NAME = 'scheduled_down_time'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `li_goods` ADD COLUMN `scheduled_down_time` DATETIME NULL COMMENT ''计划下架时间''',
  'SELECT ''scheduled_down_time exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists := (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'li_goods'
    AND COLUMN_NAME = 'scheduled_down_reason'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `li_goods` ADD COLUMN `scheduled_down_reason` VARCHAR(255) NULL COMMENT ''计划下架原因''',
  'SELECT ''scheduled_down_reason exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
