-- =============================================================
-- 统一消息中心（Message Hub）全新纯净初始化 SQL
-- 适用场景：全新数据库安装 / 完整重置 li_notice_message 表
-- =============================================================

SET NAMES utf8mb4;

-- -------------------------------------------------------------
-- 1. 创建消息模板核心表 (li_notice_message)
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `li_notice_message`;
CREATE TABLE `li_notice_message`  (
  `id` bigint NOT NULL COMMENT '主键ID',
  `create_by` varchar(255) NULL DEFAULT NULL,
  `create_time` datetime(6) NULL DEFAULT NULL,
  `delete_flag` bit(1) NULL DEFAULT b'0',
  `update_by` varchar(255) NULL DEFAULT NULL,
  `update_time` datetime(6) NULL DEFAULT NULL,
  `notice_node` varchar(255) NOT NULL COMMENT '模板应用场景描述 (如 订单发货通知)',
  `notice_title` varchar(255) NULL DEFAULT NULL COMMENT '站内信标题',
  `notice_content` varchar(500) NULL DEFAULT NULL COMMENT '站内信正文 (可编辑，支持 #{variable} 替换)',
  `notice_status` varchar(16) NOT NULL DEFAULT 'OPEN' COMMENT '站内信开启状态 OPEN/CLOSE',
  `variable` varchar(255) NULL DEFAULT NULL COMMENT '变量参数列表',
  `scene_code` varchar(64) NOT NULL COMMENT '业务场景编码，与 NoticeMessageNodeEnum.name 一致',
  `type` varchar(32) NOT NULL DEFAULT 'MEMBER' COMMENT '受众类型: MEMBER(会员) / STORE(商户) / PLATFORM(平台)',
  `sms_status` varchar(16) NOT NULL DEFAULT 'CLOSE' COMMENT '短信开启状态 OPEN/CLOSE',
  `sms_template_code` varchar(64) NULL DEFAULT NULL COMMENT '短信服务商模板CODE (如 SMS_191840050)',
  `sms_content` varchar(500) NULL DEFAULT NULL COMMENT '短信报备正文预览 (只读参考)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_notice_scene_code` (`scene_code`) USING BTREE,
  INDEX `idx_notice_type` (`type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '统一消息中心配置表' ROW_FORMAT = DYNAMIC;

-- -------------------------------------------------------------
-- 2. 初始化全量有效消息模板数据
-- -------------------------------------------------------------

-- (1) 会员模板消息 (MEMBER: 站内信 + 短信 + 微信公众号 + 微信小程序)
INSERT INTO `li_notice_message` (`id`, `create_time`, `notice_node`, `notice_title`, `notice_content`, `notice_status`, `variable`, `scene_code`, `type`, `sms_status`, `sms_content`, `sms_template_code`) VALUES
(3, NOW(), '订单发货通知', '订单发货通知', '您购买的商品【#{goods}】已发货，请注意查收物流信息哦~', 'OPEN', 'goods', 'ORDER_DELIVER', 'MEMBER', 'CLOSE', '【商城平台】尊敬的会员：您的订单 ${order_sn} 已发出，承运商：${express_name}，运单号：${logistics_no}。', 'SMS_512652545'),
(4, NOW(), '订单完成通知', '订单完成通知', '您购买的商品【#{goods}】订单已完成，期待您分享商品评价与购物心得哦~', 'OPEN', 'goods', 'ORDER_COMPLETE', 'MEMBER', 'CLOSE', '【商城平台】尊敬的会员：您的订单 ${order_sn} 已完成，感谢您的选购与支持。', 'SMS_512652546'),
(7, NOW(), '拼团成功通知', '拼团成功通知', '恭喜，您参与的【#{goods}】拼团已成功，我们将尽快为您安排发货哦~', 'OPEN', 'goods', 'PINTUAN_SUCCESS', 'MEMBER', 'CLOSE', '【商城平台】尊敬的会员：您的拼团 ${goods} 已成团，我们将尽快为您安排发货。', 'SMS_512582449'),
(9, NOW(), '售后审核通知', '售后审核结果通知', '您的售后申请（商品：【#{goods}】）已审核，审核结果：#{audit_result}，请进入售后中心查看详情。', 'OPEN', 'goods,audit_result', 'AFTER_SALE_AUDIT', 'MEMBER', 'CLOSE', '【商城平台】尊敬的会员：您的售后申请已审核，请登录商城在售后中心查看审核结果。', 'SMS_512537655'),
(16, NOW(), '积分变更通知', '积分变更通知', '您的积分账户发生变动：本次获得 #{income_points} 积分，消费 #{expenditure_points} 积分，积分可在商城抵扣使用哦~', 'OPEN', 'income_points,expenditure_points', 'POINT_CHANGE', 'MEMBER', 'CLOSE', '【商城平台】尊敬的会员：您的积分账户发生变动，到账 ${income_points} 积分，消费 ${expenditure_points} 积分。', NULL),
(17, NOW(), '余额账户变更通知', '余额账户变更通知', '您的余额账户发生变动：本次收入 ¥#{income}，支出 ¥#{expenditure}，请进入我的钱包查看详情。', 'OPEN', 'income,expenditure', 'WALLET_CHANGE', 'MEMBER', 'CLOSE', '【商城平台】尊敬的会员：您的余额账户发生变动，变动金额：${money} 元。', NULL),
(20, NOW(), '提现申请审核通知', '提现申请审核通知', '您的余额提现申请（金额：¥#{price}）已审核，审核结果：#{audit_result}，请进入我的钱包查看详情。', 'OPEN', 'price,audit_result', 'WALLET_WITHDRAWAL_AUDIT_ERROR', 'MEMBER', 'CLOSE', '【商城平台】尊敬的会员：您的余额提现申请已审核完成，请登录商城在个人中心查看详情。', NULL);

-- (2) 商户模板消息 (STORE: 站内信 + 短信 + 微信公众号，无小程序)
INSERT INTO `li_notice_message` (`id`, `create_time`, `notice_node`, `notice_title`, `notice_content`, `notice_status`, `variable`, `scene_code`, `type`, `sms_status`, `sms_content`, `sms_template_code`) VALUES
(101, NOW(), '店铺入驻结果', '店铺入驻结果通知', '恭喜您，您的店铺入驻申请已经审核通过，请登录商家后台进行店铺管理。', 'OPEN', 'store_name', 'STORE_AUDIT_RESULT', 'STORE', 'CLOSE', '【商城平台】尊敬的商家：您的店铺入驻申请审核结果已出，请登录商家后台查看。', NULL),
(102, NOW(), '订单付款成功通知', '商户订单付款提醒', '您有新的订单付款成功，订单号：#{order_sn}，请尽快安排发货。', 'OPEN', 'order_sn', 'STORE_ORDER_PAY_SUCCESS', 'STORE', 'CLOSE', '【商城平台】尊敬的商家：您的店铺有新订单付款成功（单号：${order_sn}），请尽快安排发货。', NULL),
(103, NOW(), '用户售后申请通知', '用户售后申请提醒', '买家对订单 #{order_sn} 发起了售后申请，请及时在商家后台进行审核处理。', 'OPEN', 'order_sn', 'STORE_AFTER_SALE_APPLY', 'STORE', 'CLOSE', '【商城平台】尊敬的商家：买家已对订单 ${order_sn} 发起售后申请，请登录商家后台及时处理。', NULL);

-- (3) 平台消息模板 (PLATFORM: 仅短信，关闭站内信，无微信公众号、无小程序)
INSERT INTO `li_notice_message` (`id`, `create_time`, `notice_node`, `notice_title`, `notice_content`, `notice_status`, `variable`, `scene_code`, `type`, `sms_status`, `sms_content`, `sms_template_code`) VALUES
(201, NOW(), '新店铺入驻待审核通知', '新店铺入驻审核提醒', '', 'CLOSE', 'store_name', 'PLATFORM_STORE_AUDIT_NOTIFY', 'PLATFORM', 'CLOSE', '【商城平台】尊敬的管理员：有新的店铺申请入驻（店铺名称：${store_name}），请及时登录管理后台审核。', NULL);

-- -------------------------------------------------------------
-- 3. 菜单名称更新为“消息模板”
-- -------------------------------------------------------------
UPDATE `li_menu`
SET `title` = '消息模板'
WHERE `front_route` = 'sys/message/noticeMessageTemplate' OR `name` = 'noticeMessageTemplate';


-- -------------------------------------------------------------
-- 4. 微信小程序订阅消息模板配置 (li_wechat_mp_message)
-- -------------------------------------------------------------
DELETE FROM `li_wechat_mp_message`;
INSERT INTO `li_wechat_mp_message` (`id`, `create_time`, `name`, `template_id`, `code`, `keywords`, `keywords_text`, `enable`, `order_status`, `scene_code`) VALUES
(374, NOW(), '订单发货提醒', '374', '8UqLGc3kBUDN3md_czOLAcLi_gPBXysS49cVuaSrPMk', '["GOODS_INFO","ORDER_SN","LOGISTICS_TIME","REMARK"]', '["thing1","character_string15","date4","thing12"]', b'1', 'DELIVERED', 'ORDER_DELIVER'),
(3606, NOW(), '订单已完成提醒', '3606', 'knckkHDSRC7eYuX_4sOJaS_zpHvG3Z13Fzqh78hxBsQ', '["GOODS_INFO","ORDER_SN","COMPLETE_TIME","REMARK"]', '["thing3","character_string5","time9","thing4"]', b'1', 'COMPLETED', 'ORDER_COMPLETE'),
(766, NOW(), '拼团成功通知', '766', 'gdEG644QpBsT_LBnjeCbwlueZx8-5RgCeEVs7y9Ei78', '["GOODS_INFO","ORDER_SN","PINTUAN_TIME","REMARK"]', '["thing1","character_string13","date7","thing5"]', b'1', 'UNDELIVERED', 'PINTUAN_SUCCESS'),
(2927, NOW(), '售后申请审核通知', '2927', 'j5-2nnrKZOZNpodLJUS2cLjftPUlKJok7m4JZf5-LcM', '["GOODS_INFO","AFTER_SALE_SN","AUDIT_RESULT","REMARK"]', '["thing4","character_string13","phrase2","thing3"]', b'1', 'AFTER_SALE_AUDIT', 'AFTER_SALE_AUDIT'),
(3595, NOW(), '积分变更提醒', '3595', 'iq4eRz5juxFsFwiRmbu5GPXfBY0w9Kkskf6Kt_m4NnE', '["CHANGE_POINT","CURRENT_POINT","POINT_TIME","REMARK"]', '["number2","thing11","time12","thing4"]', b'1', 'POINT_CHANGE', 'POINT_CHANGE'),
(15259, NOW(), '账户余额变动通知', '15259', 'hhuKGE5VzE4TVPJ3ZMmWNs0RRM-HdxmcRdS5ZdOSCZY', '["CHANGE_AMOUNT","WALLET_BALANCE","WALLET_TIME","CHANGE_REASON"]', '["character_string1","amount2","time3","thing4"]', b'1', 'WALLET_CHANGE', 'WALLET_CHANGE'),
(20020, NOW(), '提现结果通知', '20020', 'jmXHzErl2ELJ3u3vexC-jJ2eDr3CAzkYi74v39WYkiA', '["WITHDRAW_AMOUNT","WITHDRAW_RESULT","APPLY_TIME","WARM_REMIND"]', '["amount1","phrase2","date3","thing4"]', b'1', 'WALLET_WITHDRAWAL_AUDIT_ERROR', 'WALLET_WITHDRAWAL_AUDIT_ERROR');
