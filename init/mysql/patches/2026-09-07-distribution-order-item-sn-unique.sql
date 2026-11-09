-- 给 li_distribution_order.order_item_sn 加 UNIQUE，挡住双路径（提交后事件 + MQ）并发重复入账。
-- 先统计 GROUP BY order_item_sn HAVING COUNT(*) > 1：有重复则 skip，不预写删除规则，留给人工处理。
-- 无重复且尚无 uk_do_order_item_sn 时 ADD UNIQUE；随后若仍有非唯一 idx_do_order_item_sn 则 DROP，避免同列双索引。
-- compose initdb 先跑 patches 后导 dump，表不存在时 skip。
-- 已运行库需手工执行本补丁（Docker initdb 只在空数据卷首次执行）：
--   docker compose -f docker/docker-compose.yml exec -T mysql \
--     mysql -uroot -plilishop lilishop < docker/init/mysql/patches/2026-09-07-distribution-order-item-sn-unique.sql
SET NAMES utf8mb4;

SET @has_table := (
  SELECT COUNT(1) FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_order');

SET @dup_count := 0;
SET @sql := IF(@has_table = 1,
  'SELECT COUNT(*) INTO @dup_count FROM (SELECT order_item_sn FROM li_distribution_order GROUP BY order_item_sn HAVING COUNT(*) > 1) dup_oi',
  'SELECT 0 INTO @dup_count');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_unique := (
  @has_table = 1
  AND @dup_count = 0
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_order' AND COLUMN_NAME = 'order_item_sn')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_order' AND INDEX_NAME = 'uk_do_order_item_sn'));
SET @sql := IF(@need_unique = 1,
  'ALTER TABLE `li_distribution_order` ADD UNIQUE KEY `uk_do_order_item_sn` (`order_item_sn`)',
  IF(@dup_count > 0,
    'SELECT ''skip li_distribution_order.uk_do_order_item_sn: duplicate order_item_sn''',
    'SELECT ''skip li_distribution_order.uk_do_order_item_sn'''));
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_drop_idx := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_order')
  AND EXISTS (
    SELECT 1 FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_order' AND INDEX_NAME = 'uk_do_order_item_sn')
  AND EXISTS (
    SELECT 1 FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_order' AND INDEX_NAME = 'idx_do_order_item_sn'));
SET @sql := IF(@need_drop_idx = 1,
  'ALTER TABLE `li_distribution_order` DROP INDEX `idx_do_order_item_sn`',
  'SELECT ''skip li_distribution_order.idx_do_order_item_sn drop''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
