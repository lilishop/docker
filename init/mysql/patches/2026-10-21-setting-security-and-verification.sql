-- ===================================================================
-- 升级脚本：新增系统设置配置项（验证码设置 & 安全设置）
-- 适用版本：lilishop 升级迁移
-- 说明：
--   1. VERIFICATION_SETTING：滑块验证码配置（有效时间、水印文字、干扰块数、容错像素、免密登录开关）
--   2. SECURITY_SETTING：系统安全配置（数据脱敏级别、演示站点开关、买家/管理端 Token 有效期）
-- ===================================================================

-- 1. 插入【验证码设置】默认配置（若已存在则忽略，避免覆盖历史设置）
INSERT INTO `li_setting` (
    `id`,
    `create_by`,
    `create_time`,
    `update_by`,
    `update_time`,
    `delete_flag`,
    `setting_value`
) VALUES (
    'VERIFICATION_SETTING',
    'admin',
    NOW(),
    'admin',
    NOW(),
    0,
    '{"effectiveTime":300,"watermark":"LILI-SHOP","interfereNum":0,"faultTolerant":3,"loginBypassEnabled":false}'
) ON DUPLICATE KEY UPDATE
    `update_time` = NOW();

-- 2. 插入【安全设置】默认配置（若已存在则忽略，避免覆盖历史设置）
INSERT INTO `li_setting` (
    `id`,
    `create_by`,
    `create_time`,
    `update_by`,
    `update_time`,
    `delete_flag`,
    `setting_value`
) VALUES (
    'SECURITY_SETTING',
    'admin',
    NOW(),
    'admin',
    NOW(),
    0,
    '{"sensitiveLevel":1,"isDemoSite":false,"buyerTokenExpireTime":259200,"managerTokenExpireTime":86400}'
) ON DUPLICATE KEY UPDATE
    `update_time` = NOW();
