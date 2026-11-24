-- 修复运营后台「主题色」菜单标题乱码。
-- 原因：2026-10-09 补丁写入中文 title 时客户端未 SET NAMES utf8mb4，
-- UTF-8 字节被按 latin1 转存，侧边栏显示为 ä¸»é¢˜è‰²。
SET NAMES utf8mb4;

UPDATE li_menu
SET title = '主题色',
    update_by = 'system',
    update_time = NOW()
WHERE delete_flag = 0
  AND (id = 2057668382760361987 OR name = 'theme-setting')
  AND title <> '主题色';
