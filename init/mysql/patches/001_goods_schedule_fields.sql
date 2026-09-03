-- 商品定时上下架字段补齐。
-- 当前代码实体会读取这些字段，旧初始化 SQL 未包含时会导致商品列表 SELECT 失败。
-- ALTER 仅在「表存在且列不存在」时执行，避免 compose initdb（patches 先于 dump）对不存在的表报 1146。
SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_goods')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_goods' AND COLUMN_NAME = 'scheduled_upper_time'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_goods` ADD COLUMN `scheduled_upper_time` DATETIME NULL COMMENT ''计划上架时间''',
  'SELECT ''skip li_goods.scheduled_upper_time''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_goods')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_goods' AND COLUMN_NAME = 'scheduled_upper_reason'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_goods` ADD COLUMN `scheduled_upper_reason` VARCHAR(255) NULL COMMENT ''计划上架原因''',
  'SELECT ''skip li_goods.scheduled_upper_reason''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_goods')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_goods' AND COLUMN_NAME = 'scheduled_down_time'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_goods` ADD COLUMN `scheduled_down_time` DATETIME NULL COMMENT ''计划下架时间''',
  'SELECT ''skip li_goods.scheduled_down_time''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_goods')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_goods' AND COLUMN_NAME = 'scheduled_down_reason'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_goods` ADD COLUMN `scheduled_down_reason` VARCHAR(255) NULL COMMENT ''计划下架原因''',
  'SELECT ''skip li_goods.scheduled_down_reason''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
