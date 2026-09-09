-- 对齐运行库 li_distribution_grade_history 的 JSON 快照列名到 Java 实体扁平列。
-- Java 按 grade_id / previous_grade_id / upgrade_time / grade_name / 两个比例列插入；
-- dump 曾建成 after_grade_id / before_grade_id / change_time + JSON 快照，INSERT 会报 Unknown column。
-- grade_id 存的是等级值（1-5），不是 li_distribution_grade.id。change_time→upgrade_time
-- 按 Java 自动升级语义改名，不是通用变更日志。
-- 每列独立 CHANGE/ADD：旧列存在且目标列不存在才改；已扁平或缺表则 skip。
-- JSON 遗留列（*_snapshot、change_type、member_id 等）不 DROP，插入契约对齐即可。
-- 改名前若 after_grade_id/before_grade_id 能 JOIN 到等级主键，则先转成 grade_sort（对齐 dump 第 25 步）。
-- compose initdb 先跑 patches 后导 dump，表不存在时 skip。
-- 已运行库需手工执行（Docker initdb 只在空数据卷首次执行）：
--   1. 备份
--   2. 看行数并抽样 after_grade_id（本补丁会 SELECT COUNT / LIMIT 10；像雪花 ID 则 JOIN 转等级值）
--   3. docker compose -f docker/docker-compose.yml exec -T mysql \
--        mysql -uroot -plilishop lilishop < docker/init/mysql/patches/008_distribution_grade_history_flatten.sql
--   4. SHOW COLUMNS FROM li_distribution_grade_history; 确认有 grade_id、upgrade_time
--   5. 管理端补偿处理订单分销奖励（支付后入账曾因缺列整笔回滚）
SET NAMES utf8mb4;

SET @has_table := (
  SELECT COUNT(1) FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_grade_history');

SET @has_grade_table := (
  SELECT COUNT(1) FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_grade');

SET @sql := IF(@has_table = 1,
  'SELECT COUNT(*) INTO @dgh_row_count FROM li_distribution_grade_history',
  'SELECT 0 INTO @dgh_row_count');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SELECT @dgh_row_count AS dgh_row_count;

SET @has_after_grade_id := (
  @has_table = 1
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'after_grade_id'));
SET @sql := IF(@has_after_grade_id = 1,
  'SELECT after_grade_id FROM li_distribution_grade_history WHERE after_grade_id IS NOT NULL LIMIT 10',
  'SELECT ''skip li_distribution_grade_history.after_grade_id sample''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_convert_after := (
  @has_after_grade_id = 1
  AND @has_grade_table = 1);
SET @sql := IF(@need_convert_after = 1,
  'UPDATE `li_distribution_grade_history` h INNER JOIN `li_distribution_grade` g ON h.after_grade_id = g.id SET h.after_grade_id = CAST(g.grade_sort AS CHAR)',
  'SELECT ''skip li_distribution_grade_history.after_grade_id to grade_sort''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_convert_before := (
  @has_table = 1
  AND @has_grade_table = 1
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'before_grade_id'));
SET @sql := IF(@need_convert_before = 1,
  'UPDATE `li_distribution_grade_history` h INNER JOIN `li_distribution_grade` g ON h.before_grade_id = g.id SET h.before_grade_id = CAST(g.grade_sort AS CHAR)',
  'SELECT ''skip li_distribution_grade_history.before_grade_id to grade_sort''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  @has_table = 1
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'after_grade_id')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'grade_id'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_grade_history` CHANGE COLUMN `after_grade_id` `grade_id` VARCHAR(64) NOT NULL COMMENT ''变更后等级值（1-5）''',
  'SELECT ''skip li_distribution_grade_history.after_grade_id''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  @has_table = 1
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'before_grade_id')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'previous_grade_id'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_grade_history` CHANGE COLUMN `before_grade_id` `previous_grade_id` VARCHAR(64) DEFAULT NULL COMMENT ''变更前等级值（1-5）''',
  'SELECT ''skip li_distribution_grade_history.before_grade_id''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  @has_table = 1
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'change_time')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'upgrade_time'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_grade_history` CHANGE COLUMN `change_time` `upgrade_time` DATETIME NOT NULL COMMENT ''升级时间（自动升级写入，非通用变更时间）''',
  'SELECT ''skip li_distribution_grade_history.change_time''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  @has_table = 1
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'grade_name'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_grade_history` ADD COLUMN `grade_name` VARCHAR(64) DEFAULT NULL COMMENT ''等级名称快照''',
  'SELECT ''skip li_distribution_grade_history.grade_name''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  @has_table = 1
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'goods_commission_rate'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_grade_history` ADD COLUMN `goods_commission_rate` DECIMAL(10, 4) DEFAULT NULL COMMENT ''商品佣金比例快照''',
  'SELECT ''skip li_distribution_grade_history.goods_commission_rate add''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  @has_table = 1
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_grade_history'
      AND COLUMN_NAME = 'invite_commission_rate'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_grade_history` ADD COLUMN `invite_commission_rate` DECIMAL(10, 4) DEFAULT NULL COMMENT ''邀请佣金比例快照''',
  'SELECT ''skip li_distribution_grade_history.invite_commission_rate add''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
