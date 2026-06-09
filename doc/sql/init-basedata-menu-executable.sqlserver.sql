-- =============================================================================
-- SQL Server 版：基础数据管理菜单 + 角色菜单权限（可重复执行，按 RouteName 判重）
-- 适用：MalusAdmin + 本前端项目（VITE_AUTH_ROUTE_MODE=dynamic）
-- 执行后：退出登录并重新登录（后端会缓存用户菜单）
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 一、菜单 t_sys_menu
-- MenuType：1=目录  2=页面；Status：1=启用；HideInMenu：0=显示
-- -----------------------------------------------------------------------------

-- 1. 父菜单：基础数据管理
INSERT INTO dbo.t_sys_menu (
  ParentId, MenuType, MenuName, RouteName, RoutePath,
  Status, HideInMenu, Sort, Component, Icon, IconType,
  SysCreateUser, SysUpdateUser, SysIsDelete, SysCreateTime, SysUpdateTime
)
SELECT
  0, 1, N'基础数据管理', N'basedata', N'/basedata',
  1, 0, 4, N'layout.base', N'mdi:database-cog-outline', 1,
  0, 0, 0, GETDATE(), GETDATE()
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_menu WHERE RouteName = N'basedata' AND ISNULL(SysIsDelete, 0) = 0
);

-- 2. 子菜单：产品管理
INSERT INTO dbo.t_sys_menu (
  ParentId, MenuType, MenuName, RouteName, RoutePath,
  Status, HideInMenu, Sort, Component, Icon, IconType,
  SysCreateUser, SysUpdateUser, SysIsDelete, SysCreateTime, SysUpdateTime
)
SELECT TOP (1)
  p.Id, 2, N'产品管理', N'basedata_product', N'/basedata/product',
  1, 0, 1, N'view.basedata_product', N'mdi:package-variant-closed', 1,
  0, 0, 0, GETDATE(), GETDATE()
FROM dbo.t_sys_menu AS p
WHERE p.RouteName = N'basedata' AND ISNULL(p.SysIsDelete, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_menu WHERE RouteName = N'basedata_product' AND ISNULL(SysIsDelete, 0) = 0
  );

-- 3. 子菜单：报价器管理
INSERT INTO dbo.t_sys_menu (
  ParentId, MenuType, MenuName, RouteName, RoutePath,
  Status, HideInMenu, Sort, Component, Icon, IconType,
  SysCreateUser, SysUpdateUser, SysIsDelete, SysCreateTime, SysUpdateTime
)
SELECT TOP (1)
  p.Id, 2, N'报价器管理', N'basedata_quoter', N'/basedata/quoter',
  1, 0, 2, N'view.basedata_quoter', N'mdi:calculator-variant-outline', 1,
  0, 0, 0, GETDATE(), GETDATE()
FROM dbo.t_sys_menu AS p
WHERE p.RouteName = N'basedata' AND ISNULL(p.SysIsDelete, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_menu WHERE RouteName = N'basedata_quoter' AND ISNULL(SysIsDelete, 0) = 0
  );

-- 4. 子菜单：付款条件
INSERT INTO dbo.t_sys_menu (
  ParentId, MenuType, MenuName, RouteName, RoutePath,
  Status, HideInMenu, Sort, Component, Icon, IconType,
  SysCreateUser, SysUpdateUser, SysIsDelete, SysCreateTime, SysUpdateTime
)
SELECT TOP (1)
  p.Id, 2, N'付款条件', N'basedata_payment-term', N'/basedata/payment-term',
  1, 0, 3, N'view.basedata_payment-term', N'mdi:cash-clock', 1,
  0, 0, 0, GETDATE(), GETDATE()
FROM dbo.t_sys_menu AS p
WHERE p.RouteName = N'basedata' AND ISNULL(p.SysIsDelete, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_menu WHERE RouteName = N'basedata_payment-term' AND ISNULL(SysIsDelete, 0) = 0
  );

-- -----------------------------------------------------------------------------
-- 二、角色菜单权限 t_sys_role_menu
-- 将 @role_id 改为你的角色 Id（角色管理列表中的 Id）
-- 超级管理员一般会加载全部菜单；非超管必须配置此项
-- -----------------------------------------------------------------------------

DECLARE @role_id INT = 6;  -- 按需修改，例如 1、2、4

-- 若表无 SysDeleteUser 列，请改用下方「无 SysDeleteUser」版本并注释本段
INSERT INTO dbo.t_sys_role_menu (RoleId, MenuId, SysCreateUser, SysUpdateUser, SysDeleteUser, SysIsDelete)
SELECT @role_id, m.Id, 0, 0, 0, 0
FROM dbo.t_sys_menu AS m
WHERE m.RouteName IN (N'basedata', N'basedata_product', N'basedata_quoter', N'basedata_payment-term')
  AND ISNULL(m.SysIsDelete, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_role_menu AS rm
    WHERE rm.RoleId = @role_id AND rm.MenuId = m.Id AND ISNULL(rm.SysIsDelete, 0) = 0
  );

/*
-- 无 SysDeleteUser 列时使用：
INSERT INTO dbo.t_sys_role_menu (RoleId, MenuId, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, m.Id, 0, 0, 0
FROM dbo.t_sys_menu AS m
WHERE m.RouteName IN (N'basedata', N'basedata_product', N'basedata_quoter', N'basedata_payment-term')
  AND ISNULL(m.SysIsDelete, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_role_menu AS rm
    WHERE rm.RoleId = @role_id AND rm.MenuId = m.Id AND ISNULL(rm.SysIsDelete, 0) = 0
  );
*/

-- -----------------------------------------------------------------------------
-- 三、校验
-- -----------------------------------------------------------------------------
SELECT Id, ParentId, MenuName, RouteName, RoutePath, Component
FROM dbo.t_sys_menu
WHERE RouteName LIKE N'basedata%' AND ISNULL(SysIsDelete, 0) = 0
ORDER BY ParentId, Sort;

SELECT rm.RoleId, r.Name AS RoleName, m.MenuName, m.RouteName
FROM dbo.t_sys_role_menu AS rm
INNER JOIN dbo.t_sys_role AS r ON r.Id = rm.RoleId
INNER JOIN dbo.t_sys_menu AS m ON m.Id = rm.MenuId
WHERE m.RouteName LIKE N'basedata%' AND ISNULL(rm.SysIsDelete, 0) = 0;

-- -----------------------------------------------------------------------------
-- 四、账号 aaaaaa 无法看到基础数据管理时排查
-- -----------------------------------------------------------------------------
-- SELECT u.Account, u.UserRolesId, u.IsSuperAdmin FROM dbo.t_sys_user u WHERE u.Account = N'aaaaaa';
-- SELECT rm.MenuId, m.MenuName, m.RouteName, m.ParentId
-- FROM dbo.t_sys_role_menu rm
-- JOIN dbo.t_sys_menu m ON m.Id = rm.MenuId
-- WHERE rm.RoleId = 6 AND m.RouteName LIKE N'basedata%';
-- 父菜单 RouteName=basedata 与子菜单都应在 t_sys_role_menu 中；改权限后需重新登录
