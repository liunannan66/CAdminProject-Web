-- 基础资料管理菜单（产品管理、报价器管理、付款条件）
-- 在 MySQL 中执行后，请重新登录以刷新菜单缓存

INSERT INTO `t_sys_menu` VALUES (68, 0, 1, '基础数据管理', 'basedata', '/basedata', 1, 0, 4, 'layout.base', 'mdi:database-cog-outline', 1, 0, 1, 0, 0, NOW(), NOW(), NULL);
INSERT INTO `t_sys_menu` VALUES (69, 68, 2, '产品管理', 'basedata_product', '/basedata/product', 1, 0, 1, 'view.basedata_product', 'mdi:package-variant-closed', 1, 1, 0, 0, 0, NOW(), NOW(), NULL);
INSERT INTO `t_sys_menu` VALUES (70, 68, 2, '报价器管理', 'basedata_quoter', '/basedata/quoter', 1, 0, 2, 'view.basedata_quoter', 'mdi:calculator-variant-outline', 1, 1, 0, 0, 0, NOW(), NOW(), NULL);
INSERT INTO `t_sys_menu` VALUES (71, 68, 2, '付款条件', 'basedata_payment-term', '/basedata/payment-term', 1, 0, 3, 'view.basedata_payment-term', 'mdi:cash-clock', 1, 1, 0, 0, 0, NOW(), NOW(), NULL);

-- 非超级管理员角色需分配菜单权限（按需调整 RoleId）
-- 信息管理员
INSERT INTO `t_sys_role_menu` (`RoleId`, `MenuId`, `SysCreateUser`, `SysUpdateUser`, `SysDeleteUser`, `SysIsDelete`) VALUES (6, 68, 0, 0, 0, 0);
INSERT INTO `t_sys_role_menu` (`RoleId`, `MenuId`, `SysCreateUser`, `SysUpdateUser`, `SysDeleteUser`, `SysIsDelete`) VALUES (6, 69, 0, 0, 0, 0);
INSERT INTO `t_sys_role_menu` (`RoleId`, `MenuId`, `SysCreateUser`, `SysUpdateUser`, `SysDeleteUser`, `SysIsDelete`) VALUES (6, 70, 0, 0, 0, 0);
INSERT INTO `t_sys_role_menu` (`RoleId`, `MenuId`, `SysCreateUser`, `SysUpdateUser`, `SysDeleteUser`, `SysIsDelete`) VALUES (6, 71, 0, 0, 0, 0);
