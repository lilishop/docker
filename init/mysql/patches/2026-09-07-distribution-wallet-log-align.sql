-- 对齐运行库 li_distribution_wallet_log 旧列名到实体 / CREATE TABLE 已使用的目标名。
-- Java 已从 logType / canRebateBefore 改为 bizType / beforeCanRebate，仓库两份建表也是新命名，
-- 但 CREATE TABLE IF NOT EXISTS 不会改已有表，运行库仍是 log_type / can_rebate_before 等 9 列。
-- 仅当旧列存在且目标列不存在时 CHANGE COLUMN；全新 dump 已是 biz_type 时 skip。
-- compose initdb 先跑 patches 后导 dump，表不存在时也 skip。
-- 已运行库需手工执行本补丁（Docker initdb 只在空数据卷首次执行）：
--   docker compose -f docker/docker-compose.yml exec -T mysql \
--     mysql -uroot -plilishop lilishop < docker/init/mysql/patches/2026-09-07-distribution-wallet-log-align.sql
SET NAMES utf8mb4;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'log_type')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'biz_type'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_wallet_log` CHANGE COLUMN `log_type` `biz_type` VARCHAR(32) NOT NULL COMMENT ''业务类型：COMMISSION_FREEZE COMMISSION_SETTLE COMMISSION_REFUND WITHDRAW_APPLY WITHDRAW_APPROVE WITHDRAW_REJECT MANUAL_ADJUST''',
  'SELECT ''skip li_distribution_wallet_log.log_type''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'can_rebate_before')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'before_can_rebate'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_wallet_log` CHANGE COLUMN `can_rebate_before` `before_can_rebate` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT ''变动前可提现余额''',
  'SELECT ''skip li_distribution_wallet_log.can_rebate_before''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'can_rebate_after')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'after_can_rebate'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_wallet_log` CHANGE COLUMN `can_rebate_after` `after_can_rebate` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT ''变动后可提现余额''',
  'SELECT ''skip li_distribution_wallet_log.can_rebate_after''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'commission_frozen_before')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'before_commission_frozen'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_wallet_log` CHANGE COLUMN `commission_frozen_before` `before_commission_frozen` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT ''变动前待结算佣金冻结''',
  'SELECT ''skip li_distribution_wallet_log.commission_frozen_before''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'commission_frozen_after')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'after_commission_frozen'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_wallet_log` CHANGE COLUMN `commission_frozen_after` `after_commission_frozen` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT ''变动后待结算佣金冻结''',
  'SELECT ''skip li_distribution_wallet_log.commission_frozen_after''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'withdrawal_frozen_before')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'before_withdrawal_frozen'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_wallet_log` CHANGE COLUMN `withdrawal_frozen_before` `before_withdrawal_frozen` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT ''变动前提现冻结''',
  'SELECT ''skip li_distribution_wallet_log.withdrawal_frozen_before''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'withdrawal_frozen_after')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'after_withdrawal_frozen'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_wallet_log` CHANGE COLUMN `withdrawal_frozen_after` `after_withdrawal_frozen` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT ''变动后提现冻结''',
  'SELECT ''skip li_distribution_wallet_log.withdrawal_frozen_after''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'withdrawn_total_before')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'before_withdrawn_total'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_wallet_log` CHANGE COLUMN `withdrawn_total_before` `before_withdrawn_total` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT ''变动前累计已提现''',
  'SELECT ''skip li_distribution_wallet_log.withdrawn_total_before''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'withdrawn_total_after')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_wallet_log' AND COLUMN_NAME = 'after_withdrawn_total'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_wallet_log` CHANGE COLUMN `withdrawn_total_after` `after_withdrawn_total` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT ''变动后累计已提现''',
  'SELECT ''skip li_distribution_wallet_log.withdrawn_total_after''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
