-- 基础数据管理下新增「付款条件」菜单（已存在基础数据管理时使用）
-- 在 MySQL 中执行后，请重新登录以刷新菜单缓存

INSERT INTO `t_sys_menu` VALUES (71, 68, 2, '付款条件', 'basedata_payment-term', '/basedata/payment-term', 1, 0, 3, 'view.basedata_payment-term', 'mdi:cash-clock', 1, 1, 0, 0, 0, NOW(), NOW(), NULL);

-- 非超级管理员角色需分配菜单权限（按需调整 RoleId、MenuId）
-- 信息管理员
INSERT INTO `t_sys_role_menu` (`RoleId`, `MenuId`, `SysCreateUser`, `SysUpdateUser`, `SysDeleteUser`, `SysIsDelete`) VALUES (6, 71, 0, 0, 0, 0);
