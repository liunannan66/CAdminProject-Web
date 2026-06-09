-- =============================================================================
-- MySQL 版：基础数据管理菜单 + 角色菜单权限（可重复执行，按 RouteName 判重）
-- SQL Server 请使用：init-basedata-menu-executable.sqlserver.sql
-- 适用：MalusAdmin / 本前端项目（动态路由 VITE_AUTH_ROUTE_MODE=dynamic）
-- 执行后：退出登录并重新登录（后端会缓存用户菜单约数小时）
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 一、菜单 t_sys_menu（父级 + 子级）
-- 字段说明：MenuType 1=目录 2=页面；Status 1=启用；HideInMenu 0=显示
-- -----------------------------------------------------------------------------

-- 1. 父菜单：基础数据管理
INSERT INTO `t_sys_menu` (
  `ParentId`, `MenuType`, `MenuName`, `RouteName`, `RoutePath`,
  `Status`, `HideInMenu`, `Sort`, `Component`, `Icon`, `IconType`,
  `SysCreateUser`, `SysUpdateUser`, `SysIsDelete`, `SysCreateTime`, `SysUpdateTime`
)
SELECT
  0, 1, '基础数据管理', 'basedata', '/basedata',
  1, 0, 4, 'layout.base', 'mdi:database-cog-outline', 1,
  0, 0, 0, NOW(), NOW()
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `t_sys_menu` WHERE `RouteName` = 'basedata' AND IFNULL(`SysIsDelete`, 0) = 0
);

-- 2. 子菜单：产品管理
INSERT INTO `t_sys_menu` (
  `ParentId`, `MenuType`, `MenuName`, `RouteName`, `RoutePath`,
  `Status`, `HideInMenu`, `Sort`, `Component`, `Icon`, `IconType`,
  `SysCreateUser`, `SysUpdateUser`, `SysIsDelete`, `SysCreateTime`, `SysUpdateTime`
)
SELECT
  p.`Id`, 2, '产品管理', 'basedata_product', '/basedata/product',
  1, 0, 1, 'view.basedata_product', 'mdi:package-variant-closed', 1,
  0, 0, 0, NOW(), NOW()
FROM `t_sys_menu` p
WHERE p.`RouteName` = 'basedata' AND IFNULL(p.`SysIsDelete`, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM `t_sys_menu` WHERE `RouteName` = 'basedata_product' AND IFNULL(`SysIsDelete`, 0) = 0
  )
LIMIT 1;

-- 3. 子菜单：报价器管理
INSERT INTO `t_sys_menu` (
  `ParentId`, `MenuType`, `MenuName`, `RouteName`, `RoutePath`,
  `Status`, `HideInMenu`, `Sort`, `Component`, `Icon`, `IconType`,
  `SysCreateUser`, `SysUpdateUser`, `SysIsDelete`, `SysCreateTime`, `SysUpdateTime`
)
SELECT
  p.`Id`, 2, '报价器管理', 'basedata_quoter', '/basedata/quoter',
  1, 0, 2, 'view.basedata_quoter', 'mdi:calculator-variant-outline', 1,
  0, 0, 0, NOW(), NOW()
FROM `t_sys_menu` p
WHERE p.`RouteName` = 'basedata' AND IFNULL(p.`SysIsDelete`, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM `t_sys_menu` WHERE `RouteName` = 'basedata_quoter' AND IFNULL(`SysIsDelete`, 0) = 0
  )
LIMIT 1;

-- 4. 子菜单：付款条件
INSERT INTO `t_sys_menu` (
  `ParentId`, `MenuType`, `MenuName`, `RouteName`, `RoutePath`,
  `Status`, `HideInMenu`, `Sort`, `Component`, `Icon`, `IconType`,
  `SysCreateUser`, `SysUpdateUser`, `SysIsDelete`, `SysCreateTime`, `SysUpdateTime`
)
SELECT
  p.`Id`, 2, '付款条件', 'basedata_payment-term', '/basedata/payment-term',
  1, 0, 3, 'view.basedata_payment-term', 'mdi:cash-clock', 1,
  0, 0, 0, NOW(), NOW()
FROM `t_sys_menu` p
WHERE p.`RouteName` = 'basedata' AND IFNULL(p.`SysIsDelete`, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM `t_sys_menu` WHERE `RouteName` = 'basedata_payment-term' AND IFNULL(`SysIsDelete`, 0) = 0
  )
LIMIT 1;

-- -----------------------------------------------------------------------------
-- 二、角色菜单权限 t_sys_role_menu
-- 将下面 @role_id 改成你的角色 Id（系统管理-角色管理 中查看）
-- 超级管理员(IsSuperAdmin=1) 不依赖此表也会看到全部菜单，但写入不影响
-- 非超管用户必须配置此处才能在侧栏、菜单管理、角色权限树中看到
-- -----------------------------------------------------------------------------

SET @role_id = 6;  -- 默认：信息管理员；可改为 1、2、4 等

INSERT INTO `t_sys_role_menu` (`RoleId`, `MenuId`, `SysCreateUser`, `SysUpdateUser`, `SysDeleteUser`, `SysIsDelete`)
SELECT @role_id, m.`Id`, 0, 0, 0, 0
FROM `t_sys_menu` m
WHERE m.`RouteName` IN ('basedata', 'basedata_product', 'basedata_quoter', 'basedata_payment-term')
  AND IFNULL(m.`SysIsDelete`, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM `t_sys_role_menu` rm
    WHERE rm.`RoleId` = @role_id AND rm.`MenuId` = m.`Id` AND IFNULL(rm.`SysIsDelete`, 0) = 0
  );

-- -----------------------------------------------------------------------------
-- 三、校验（执行完可查看结果）
-- -----------------------------------------------------------------------------
-- SELECT Id, ParentId, MenuName, RouteName, RoutePath, Component FROM t_sys_menu
-- WHERE RouteName LIKE 'basedata%' AND IFNULL(SysIsDelete, 0) = 0 ORDER BY ParentId, Sort;
--
-- SELECT rm.RoleId, r.Name AS RoleName, m.MenuName, m.RouteName
-- FROM t_sys_role_menu rm
-- JOIN t_sys_role r ON r.Id = rm.RoleId
-- JOIN t_sys_menu m ON m.Id = rm.MenuId
-- WHERE m.RouteName LIKE 'basedata%' AND IFNULL(rm.SysIsDelete, 0) = 0;
