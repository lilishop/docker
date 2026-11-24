-- 楼层装修 > 主题色（三级菜单）
-- 页面：lilishop-ui/manager/src/views/page-decoration/theme-setting.vue
-- 权限：主题色保存走系统设置接口 /manager/setting/setting/*
-- 客户端未指定 utf8mb4 时，UTF-8 源文件会被按 latin1 入库，title 显示为 ä¸»é¢˜è‰²。
SET NAMES utf8mb4;

INSERT INTO li_menu
  (id, create_by, create_time, delete_flag, update_by, update_time, description, front_route, icon, level, name, parent_id, path, sort_order, title, front_component, permission)
VALUES
  (2057668382760361987, 'admin', NOW(), 0, 'admin', NOW(), NULL, 'page-decoration/theme-setting', 'md-color-palette', 2, 'theme-setting', '1367050320584114176', 'themeSetting', 2.0, '主题色', NULL, '/manager/setting/setting*')
ON DUPLICATE KEY UPDATE
  title = '主题色',
  front_route = VALUES(front_route),
  name = VALUES(name),
  path = VALUES(path),
  permission = VALUES(permission),
  update_by = 'admin',
  update_time = NOW();
