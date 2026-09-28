-- =============================================================================
-- lilishop 演示数据清理脚本
-- 用途：在已初始化的库上执行，清空业务演示数据，保留系统底座
-- 使用前请先备份数据库！
--
-- 保留：
--   表结构全部保留
--   li_admin_user / li_setting / li_menu / li_store_menu / li_user_role
--   li_role / li_role_menu（即使当前为空也保留）
--   li_region（行政区划）
--   li_logistics / li_after_sale_reason / li_goods_unit
--   li_sensitive_words / li_custom_words
--   li_notice_message / li_notice_message_template
--   li_member_grade / li_member_level
--   li_article_category
--   li_sms_sign / li_sms_template
--   li_wechat_mp_message / li_wechat_message
--   li_app_version
--   xxl_job_group / xxl_job_info / xxl_job_user / xxl_job_lock
--
-- 清空：商品/类目/品牌/店铺/会员/订单/营销/统计等演示业务数据
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------- 售后 ----------
TRUNCATE TABLE `li_after_sale`;
TRUNCATE TABLE `li_after_sale_log`;

-- ---------- 文章（保留分类） ----------
TRUNCATE TABLE `li_article`;

-- ---------- 类目 / 品牌 / 规格参数 ----------
TRUNCATE TABLE `li_brand`;
TRUNCATE TABLE `li_category`;
TRUNCATE TABLE `li_category_brand`;
TRUNCATE TABLE `li_category_parameter`;
TRUNCATE TABLE `li_category_parameter_group`;
TRUNCATE TABLE `li_category_parameter_group_rel`;
TRUNCATE TABLE `li_category_specification`;
TRUNCATE TABLE `li_parameters`;
TRUNCATE TABLE `li_specification`;
TRUNCATE TABLE `li_spec_values`;

-- ---------- 商品 ----------
TRUNCATE TABLE `li_goods`;
TRUNCATE TABLE `li_goods_sku`;
TRUNCATE TABLE `li_goods_gallery`;
TRUNCATE TABLE `li_goods_params`;
TRUNCATE TABLE `li_goods_collection`;
TRUNCATE TABLE `li_goods_group`;
TRUNCATE TABLE `li_goods_group_goods`;
TRUNCATE TABLE `li_goods_tag`;
TRUNCATE TABLE `li_goods_tag_scope`;
TRUNCATE TABLE `li_goods_tag_stat`;
TRUNCATE TABLE `li_goods_words`;
TRUNCATE TABLE `li_draft_goods`;
TRUNCATE TABLE `li_hot_words_history`;

-- ---------- 店铺 / 店员 ----------
TRUNCATE TABLE `li_store`;
TRUNCATE TABLE `li_store_detail`;
TRUNCATE TABLE `li_store_address`;
TRUNCATE TABLE `li_store_collection`;
TRUNCATE TABLE `li_store_flow`;
TRUNCATE TABLE `li_store_goods_label`;
TRUNCATE TABLE `li_store_logistics`;
TRUNCATE TABLE `li_store_message`;
TRUNCATE TABLE `li_store_role`;
TRUNCATE TABLE `li_store_menu_role`;
TRUNCATE TABLE `li_store_department`;
TRUNCATE TABLE `li_store_department_role`;
TRUNCATE TABLE `li_store_data_report_form`;
TRUNCATE TABLE `li_clerk`;
TRUNCATE TABLE `li_clerk_role`;
TRUNCATE TABLE `li_freight_template`;
TRUNCATE TABLE `li_freight_template_child`;

-- ---------- 会员 ----------
TRUNCATE TABLE `li_member`;
TRUNCATE TABLE `li_member_address`;
TRUNCATE TABLE `li_member_wallet`;
TRUNCATE TABLE `li_member_benefit`;
TRUNCATE TABLE `li_member_coupon`;
TRUNCATE TABLE `li_member_coupon_sign`;
TRUNCATE TABLE `li_member_evaluation`;
TRUNCATE TABLE `li_member_experience_log`;
TRUNCATE TABLE `li_member_grade_benefit_grant`;
TRUNCATE TABLE `li_member_group`;
TRUNCATE TABLE `li_member_group_user`;
TRUNCATE TABLE `li_member_level_record`;
TRUNCATE TABLE `li_member_message`;
TRUNCATE TABLE `li_member_notice`;
TRUNCATE TABLE `li_member_notice_log`;
TRUNCATE TABLE `li_member_notice_senter`;
TRUNCATE TABLE `li_member_points_history`;
TRUNCATE TABLE `li_member_receipt`;
TRUNCATE TABLE `li_member_share_buy_log`;
TRUNCATE TABLE `li_member_share_code`;
TRUNCATE TABLE `li_member_share_log`;
TRUNCATE TABLE `li_member_share_register_log`;
TRUNCATE TABLE `li_member_sign`;
TRUNCATE TABLE `li_member_statistics_data`;
TRUNCATE TABLE `li_member_withdraw_apply`;
TRUNCATE TABLE `li_connect`;
TRUNCATE TABLE `li_connect_config`;
TRUNCATE TABLE `li_foot_print`;

-- ---------- 订单 / 交易 / 财务 ----------
TRUNCATE TABLE `li_order`;
TRUNCATE TABLE `li_order_item`;
TRUNCATE TABLE `li_order_log`;
TRUNCATE TABLE `li_order_package`;
TRUNCATE TABLE `li_order_package_item`;
TRUNCATE TABLE `li_order_complaint`;
TRUNCATE TABLE `li_order_complaint_communication`;
TRUNCATE TABLE `li_order_gift_card_record`;
TRUNCATE TABLE `li_trade`;
TRUNCATE TABLE `li_bill`;
TRUNCATE TABLE `li_receipt`;
TRUNCATE TABLE `li_recharge`;
TRUNCATE TABLE `li_refund_log`;
TRUNCATE TABLE `li_wallet_log`;
TRUNCATE TABLE `payment_log`;

-- ---------- 营销 ----------
TRUNCATE TABLE `li_coupon`;
TRUNCATE TABLE `li_coupon_activity`;
TRUNCATE TABLE `li_coupon_activity_item`;
TRUNCATE TABLE `li_full_discount`;
TRUNCATE TABLE `li_flash_discount`;
TRUNCATE TABLE `li_nth_item_discount`;
TRUNCATE TABLE `li_pintuan`;
TRUNCATE TABLE `li_promotion_goods`;
TRUNCATE TABLE `li_seckill`;
TRUNCATE TABLE `li_seckill_apply`;
TRUNCATE TABLE `li_kanjia_activity`;
TRUNCATE TABLE `li_kanjia_activity_goods`;
TRUNCATE TABLE `li_kanjia_activity_log`;
TRUNCATE TABLE `li_points_goods`;
TRUNCATE TABLE `li_points_goods_category`;
TRUNCATE TABLE `li_wholesale`;
TRUNCATE TABLE `li_special`;
TRUNCATE TABLE `li_gift_card_cash_activity`;
TRUNCATE TABLE `li_gift_card_cash_create_batch`;
TRUNCATE TABLE `li_gift_card_cash_credential`;
TRUNCATE TABLE `li_gift_card_cash_issue_batch`;
TRUNCATE TABLE `li_gift_card_cash_user_card`;

-- ---------- 分销 ----------
TRUNCATE TABLE `li_distribution`;
TRUNCATE TABLE `li_distribution_cash`;
TRUNCATE TABLE `li_distribution_goods`;
TRUNCATE TABLE `li_distribution_order`;
TRUNCATE TABLE `li_distribution_selected_goods`;

-- ---------- 采购 / 库存 / 报损 ----------
TRUNCATE TABLE `li_procurement_order`;
TRUNCATE TABLE `li_procurement_order_item`;
TRUNCATE TABLE `li_procurement_inbound`;
TRUNCATE TABLE `li_procurement_inbound_item`;
TRUNCATE TABLE `li_purchase_order`;
TRUNCATE TABLE `li_purchase_order_item`;
TRUNCATE TABLE `li_purchase_quoted`;
TRUNCATE TABLE `li_purchase_quoted_item`;
TRUNCATE TABLE `li_inventory_count`;
TRUNCATE TABLE `li_inventory_count_item`;
TRUNCATE TABLE `li_damage_report`;
TRUNCATE TABLE `li_damage_report_item`;
TRUNCATE TABLE `li_stock_reason`;

-- ---------- 直播 / 小程序直播 ----------
TRUNCATE TABLE `li_live_block`;
TRUNCATE TABLE `li_live_coupon`;
TRUNCATE TABLE `li_live_goods`;
TRUNCATE TABLE `li_live_message`;
TRUNCATE TABLE `li_live_room`;
TRUNCATE TABLE `li_live_user`;
TRUNCATE TABLE `li_studio`;
TRUNCATE TABLE `li_studio_commodity`;
TRUNCATE TABLE `li_commodity`;

-- ---------- 微信视频号 ----------
TRUNCATE TABLE `li_wx_channel_category`;
TRUNCATE TABLE `li_wx_channel_category_mapping`;
TRUNCATE TABLE `li_wx_channel_goods`;
TRUNCATE TABLE `li_wx_channel_order`;
TRUNCATE TABLE `li_wx_channel_refund`;

-- ---------- IM / 客服 / 消息 ----------
TRUNCATE TABLE `li_im_message`;
TRUNCATE TABLE `li_im_talk`;
TRUNCATE TABLE `li_message`;
TRUNCATE TABLE `li_seat`;
TRUNCATE TABLE `li_seat_setting`;
TRUNCATE TABLE `li_service_notice`;
TRUNCATE TABLE `li_sms_reach`;

-- ---------- 页面装修 / 文件 / 其它 ----------
TRUNCATE TABLE `li_page_data`;
TRUNCATE TABLE `li_file`;
TRUNCATE TABLE `li_file_directory`;
TRUNCATE TABLE `li_feedback`;
TRUNCATE TABLE `li_qa`;
TRUNCATE TABLE `li_short_link`;
TRUNCATE TABLE `li_verification_source`;
TRUNCATE TABLE `li_system_log`;
TRUNCATE TABLE `li_department`;
TRUNCATE TABLE `li_department_role`;
TRUNCATE TABLE `li_data_report_form`;
TRUNCATE TABLE `li_data_report_form_item`;
TRUNCATE TABLE `li_s_platform_view_data`;

-- ---------- XXL-JOB 运行日志（保留任务配置与用户） ----------
TRUNCATE TABLE `xxl_job_log`;
TRUNCATE TABLE `xxl_job_log_report`;
TRUNCATE TABLE `xxl_job_logglue`;
TRUNCATE TABLE `xxl_job_registry`;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- 执行后建议检查：
--   1. 管理端能否用 admin 登录
--   2. 菜单是否正常
--   3. 修改 li_setting 中的域名 / OSS / 支付 / 短信配置
--   4. 重新创建类目、店铺、商品
-- =============================================================================
