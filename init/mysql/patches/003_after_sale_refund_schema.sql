-- 首次启动补齐商家售后确认收货退款链路依赖的表和消息模板字段。
-- 本补丁必须对「基表尚不存在」和「基表已存在」两种状态都安全：
-- compose initdb 按 glob 先跑 patches、后导 lilishop.sql；all-in-one 则相反。
-- ALTER 仅在「表存在且列不存在」时执行；UPDATE 仅在表存在时 PREPARE 执行。
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `li_order_gift_card_record` (
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `create_time` datetime(6) DEFAULT NULL,
  `delete_flag` bit(1) DEFAULT b'0',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `update_time` datetime(6) DEFAULT NULL,
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '订单号',
  `trade_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '交易号',
  `member_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '会员ID',
  `credential_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '礼品卡凭证ID',
  `card_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '礼品卡卡号',
  `deduct_amount` decimal(12,2) DEFAULT 0.00 COMMENT '本次抵扣金额',
  `change_amount` decimal(12,2) DEFAULT 0.00 COMMENT '变动金额',
  `balance_after` decimal(12,2) DEFAULT 0.00 COMMENT '变动后余额',
  `flow_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '流水方向：INCREASE/DECREASE',
  `biz_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '业务类型',
  `biz_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '业务单号',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_li_order_gift_card_order` (`order_sn`),
  KEY `idx_li_order_gift_card_trade` (`trade_sn`),
  KEY `idx_li_order_gift_card_member` (`member_id`),
  KEY `idx_li_order_gift_card_credential` (`credential_id`),
  KEY `idx_li_order_gift_card_biz` (`biz_type`,`biz_sn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='订单礼品卡使用流水';

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_notice_message')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_notice_message' AND COLUMN_NAME = 'scene_code'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_notice_message` ADD COLUMN `scene_code` varchar(64) NULL COMMENT ''业务场景编码，与 NoticeMessageNodeEnum.name 一致'' AFTER `variable`',
  'SELECT ''skip li_notice_message.scene_code''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_notice_message')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_notice_message' AND COLUMN_NAME = 'email_status'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_notice_message` ADD COLUMN `email_status` varchar(16) NOT NULL DEFAULT ''CLOSE'' COMMENT ''邮箱渠道 OPEN/CLOSE'' AFTER `scene_code`',
  'SELECT ''skip li_notice_message.email_status''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_notice_message')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_notice_message' AND COLUMN_NAME = 'email_content'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_notice_message` ADD COLUMN `email_content` varchar(2000) NULL COMMENT ''邮箱正文，空则与站内信同文'' AFTER `email_status`',
  'SELECT ''skip li_notice_message.email_content''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_wechat_message')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_wechat_message' AND COLUMN_NAME = 'scene_code'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_wechat_message` ADD COLUMN `scene_code` varchar(64) NULL COMMENT ''关联站内信场景'' AFTER `remark`',
  'SELECT ''skip li_wechat_message.scene_code''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_alter := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_wechat_mp_message')
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_wechat_mp_message' AND COLUMN_NAME = 'scene_code'));
SET @sql := IF(@need_alter = 1,
  'ALTER TABLE `li_wechat_mp_message` ADD COLUMN `scene_code` varchar(64) NULL COMMENT ''关联站内信场景'' AFTER `order_status`',
  'SELECT ''skip li_wechat_mp_message.scene_code''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_update := (
  SELECT COUNT(1) FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_notice_message');
SET @sql := IF(@need_update = 1,
  'UPDATE `li_notice_message` SET `scene_code` = CASE TRIM(REPLACE(REPLACE(`notice_node`, CHAR(10), ''''), CHAR(13), ''''))
  WHEN ''订单提交成功通知'' THEN ''ORDER_CREATE_SUCCESS''
  WHEN ''订单取消成功通知'' THEN ''ORDER_CANCEL_SUCCESS''
  WHEN ''订单支付成功通知'' THEN ''ORDER_PAY_SUCCESS''
  WHEN ''支付失败自动退款通知'' THEN ''ORDER_PAY_ERROR''
  WHEN ''订单发货通知'' THEN ''ORDER_DELIVER''
  WHEN ''订单完成通知'' THEN ''ORDER_COMPLETE''
  WHEN ''订单评价提醒'' THEN ''ORDER_EVALUATION''
  WHEN ''售后提交成功通知'' THEN ''AFTER_SALE_CREATE_SUCCESS''
  WHEN ''退货审核通过通知'' THEN ''RETURN_GOODS_PASS''
  WHEN ''退款审核通过通知'' THEN ''RETURN_MONEY_PASS''
  WHEN ''退货审核未通过通知'' THEN ''RETURN_GOODS_REFUSE''
  WHEN ''退款审核未通过通知'' THEN ''RETURN_MONEY_REFUSE''
  WHEN ''退货物品签收通知'' THEN ''AFTER_SALE_ROG_PASS''
  WHEN ''退货物品拒收通知'' THEN ''AFTER_SALE_ROG_REFUSE''
  WHEN ''售后完成通知'' THEN ''AFTER_SALE_COMPLETE''
  WHEN ''开团成功通知'' THEN ''PINTUAN_CREATE''
  WHEN ''拼团失败通知'' THEN ''PINTUAN_ERROR''
  WHEN ''拼团成功通知'' THEN ''PINTUAN_SUCCESS''
  WHEN ''积分变更通知'' THEN ''POINT_CHANGE''
  WHEN ''余额账户变更通知'' THEN ''WALLET_CHANGE''
  WHEN ''余额提现申请提交成功通知'' THEN ''WALLET_WITHDRAWAL_CREATE''
  WHEN ''余额提现成功通知'' THEN ''WALLET_WITHDRAWAL_SUCCESS''
  WHEN ''余额提现申请失败通知'' THEN ''WALLET_WITHDRAWAL_ERROR''
  WHEN ''余额提现申请驳回通知'' THEN ''WALLET_WITHDRAWAL_AUDIT_ERROR''
  WHEN ''余额提现申请通过通知'' THEN ''WALLET_WITHDRAWAL_AUDIT_SUCCESS''
  WHEN ''微信提现成功通知'' THEN ''WALLET_WITHDRAWAL_SUCCESS''
  WHEN ''提现申请提交成功通知'' THEN ''WALLET_WITHDRAWAL_CREATE''
  WHEN ''提现申请驳回通知'' THEN ''WALLET_WITHDRAWAL_AUDIT_ERROR''
  ELSE `scene_code`
END
WHERE (`scene_code` IS NULL OR `scene_code` = '''')',
  'SELECT ''skip li_notice_message update: table missing''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_update := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_wechat_message')
  AND (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_notice_message'));
SET @sql := IF(@need_update = 1,
  'UPDATE `li_wechat_message` w INNER JOIN `li_notice_message` n ON n.`scene_code` IS NOT NULL AND n.`scene_code` != '''' AND TRIM(w.`name`) = TRIM(REPLACE(REPLACE(n.`notice_node`, CHAR(10), ''''), CHAR(13), '''')) SET w.`scene_code` = n.`scene_code` WHERE w.`scene_code` IS NULL OR w.`scene_code` = ''''',
  'SELECT ''skip li_wechat_message join update: table missing''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_update := (
  SELECT COUNT(1) FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_wechat_message');
SET @sql := IF(@need_update = 1,
  'UPDATE `li_wechat_message` SET `scene_code` = ''ORDER_PAY_SUCCESS'' WHERE (`scene_code` IS NULL OR `scene_code` = '''') AND `name` = ''订单支付成功通知''',
  'SELECT ''skip li_wechat_message update: table missing''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@need_update = 1,
  'UPDATE `li_wechat_message` SET `scene_code` = ''ORDER_DELIVER'' WHERE (`scene_code` IS NULL OR `scene_code` = '''') AND `name` = ''订单发货''',
  'SELECT ''skip li_wechat_message update: table missing''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@need_update = 1,
  'UPDATE `li_wechat_message` SET `scene_code` = ''ORDER_COMPLETE'' WHERE (`scene_code` IS NULL OR `scene_code` = '''') AND `name` = ''订单完成''',
  'SELECT ''skip li_wechat_message update: table missing''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_update := (
  (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_wechat_mp_message')
  AND (SELECT COUNT(1) FROM information_schema.TABLES
   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_notice_message'));
SET @sql := IF(@need_update = 1,
  'UPDATE `li_wechat_mp_message` w INNER JOIN `li_notice_message` n ON n.`scene_code` IS NOT NULL AND n.`scene_code` != '''' AND TRIM(w.`name`) = TRIM(REPLACE(REPLACE(n.`notice_node`, CHAR(10), ''''), CHAR(13), '''')) SET w.`scene_code` = n.`scene_code` WHERE w.`scene_code` IS NULL OR w.`scene_code` = ''''',
  'SELECT ''skip li_wechat_mp_message join update: table missing''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @need_update := (
  SELECT COUNT(1) FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'li_wechat_mp_message');
SET @sql := IF(@need_update = 1,
  'UPDATE `li_wechat_mp_message` SET `scene_code` = ''ORDER_PAY_SUCCESS'' WHERE (`scene_code` IS NULL OR `scene_code` = '''') AND `name` LIKE ''%订单支付%''',
  'SELECT ''skip li_wechat_mp_message update: table missing''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@need_update = 1,
  'UPDATE `li_wechat_mp_message` SET `scene_code` = ''ORDER_DELIVER'' WHERE (`scene_code` IS NULL OR `scene_code` = '''') AND `name` LIKE ''%发货%''',
  'SELECT ''skip li_wechat_mp_message update: table missing''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF(@need_update = 1,
  'UPDATE `li_wechat_mp_message` SET `scene_code` = ''ORDER_COMPLETE'' WHERE (`scene_code` IS NULL OR `scene_code` = '''') AND `name` LIKE ''%订单完成%''',
  'SELECT ''skip li_wechat_mp_message update: table missing''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
