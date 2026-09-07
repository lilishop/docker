-- 运行库 li_distribution_grade_history 若已是实体列（goods_commission_rate /
-- invite_commission_rate），从 decimal(10,2) 放到 decimal(10,4)，与等级表比例精度一致。
-- 只影响快照展示，不参与佣金计算。仓库建表仍是 JSON 快照结构，本补丁不改那些定义。
-- 仅当表存在、列存在、且仍是 decimal(10,2) 时 MODIFY；列不存在或已是 (10,4) 时 skip。
-- compose initdb 先跑 patches 后导 dump，表不存在或 dump 为快照结构时也 skip。
-- 已运行库需手工执行本补丁（Docker initdb 只在空数据卷首次执行）：
--   docker compose -f docker/docker-compose.yml exec -T mysql \
--     mysql -uroot -plilishop lilishop < docker/init/mysql/patches/006_distribution_grade_history_rate.sql
SET NAMES utf8mb4;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_grade_history')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'goods_commission_rate'
      AND DATA_TYPE = 'decimal'
      AND NUMERIC_PRECISION = 10
      AND NUMERIC_SCALE = 2));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_grade_history` MODIFY COLUMN `goods_commission_rate` DECIMAL(10, 4) NULL COMMENT ''商品佣金比例快照''',
  'SELECT ''skip li_distribution_grade_history.goods_commission_rate''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_grade_history')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'invite_commission_rate'
      AND DATA_TYPE = 'decimal'
      AND NUMERIC_PRECISION = 10
      AND NUMERIC_SCALE = 2));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_grade_history` MODIFY COLUMN `invite_commission_rate` DECIMAL(10, 4) NULL COMMENT ''邀请佣金比例快照''',
  'SELECT ''skip li_distribution_grade_history.invite_commission_rate''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
