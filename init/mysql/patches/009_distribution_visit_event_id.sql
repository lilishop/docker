-- 运行库 li_distribution_visit_event.event_id 从 VARCHAR(64) 加长到 VARCHAR(255)。
-- 访问幂等键由服务端拼接 visitorId:distributionId:goodsId:yyyy-MM-dd，现网约 87 位，超过 64。
-- 仅当表存在、列为 varchar、且 CHARACTER_MAXIMUM_LENGTH < 255 时 MODIFY；无表或已是 255 则 skip。
-- compose initdb 先跑 patches 后导 dump，表不存在时 skip。
-- 已运行库需手工执行本补丁（Docker initdb 只在空数据卷首次执行）：
--   docker compose -f docker/docker-compose.yml exec -T mysql \
--     mysql -uroot -plilishop lilishop < docker/init/mysql/patches/009_distribution_visit_event_id.sql
SET NAMES utf8mb4;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_distribution_visit_event')
  AND EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'li_distribution_visit_event'
      AND COLUMN_NAME = 'event_id'
      AND DATA_TYPE = 'varchar'
      AND CHARACTER_MAXIMUM_LENGTH < 255));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_distribution_visit_event` MODIFY COLUMN `event_id` VARCHAR(255) NOT NULL COMMENT ''服务端幂等键：visitorId:distributionId:goodsId:yyyy-MM-dd''',
  'SELECT ''skip li_distribution_visit_event.event_id''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
