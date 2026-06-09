-- =============================================================================
-- SQL Server：合同管理菜单 + 角色菜单 + 按钮权限（可重复执行）
-- 适用：MalusAdmin + 本前端（VITE_AUTH_ROUTE_MODE=dynamic）
-- 执行后：退出登录并重新登录
-- 权限码与 src/constants/contract.ts 中 CONTRACT_AUTH 一致
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 一、菜单 t_sys_menu
-- -----------------------------------------------------------------------------

INSERT INTO dbo.t_sys_menu (
  ParentId, MenuType, MenuName, RouteName, RoutePath,
  Status, HideInMenu, Sort, Component, Icon, IconType,
  SysCreateUser, SysUpdateUser, SysIsDelete, SysCreateTime, SysUpdateTime
)
SELECT
  0, 1, N'合同管理', N'contract', N'/contract',
  1, 0, 5, N'layout.base', N'mdi:file-document-edit-outline', 1,
  0, 0, 0, GETDATE(), GETDATE()
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_menu WHERE RouteName = N'contract' AND ISNULL(SysIsDelete, 0) = 0
);

INSERT INTO dbo.t_sys_menu (
  ParentId, MenuType, MenuName, RouteName, RoutePath,
  Status, HideInMenu, Sort, Component, Icon, IconType,
  SysCreateUser, SysUpdateUser, SysIsDelete, SysCreateTime, SysUpdateTime
)
SELECT TOP (1)
  p.Id, 2, N'合同管理', N'contract_manage', N'/contract/manage',
  1, 0, 1, N'view.contract_manage', N'mdi:file-document-multiple-outline', 1,
  0, 0, 0, GETDATE(), GETDATE()
FROM dbo.t_sys_menu AS p
WHERE p.RouteName = N'contract' AND ISNULL(p.SysIsDelete, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_menu WHERE RouteName = N'contract_manage' AND ISNULL(SysIsDelete, 0) = 0
  );

INSERT INTO dbo.t_sys_menu (
  ParentId, MenuType, MenuName, RouteName, RoutePath,
  Status, HideInMenu, Sort, Component, Icon, IconType,
  SysCreateUser, SysUpdateUser, SysIsDelete, SysCreateTime, SysUpdateTime
)
SELECT TOP (1)
  p.Id, 2, N'项目立项', N'contract_project-init', N'/contract/project-init',
  1, 0, 2, N'view.contract_project-init', N'mdi:rocket-launch-outline', 1,
  0, 0, 0, GETDATE(), GETDATE()
FROM dbo.t_sys_menu AS p
WHERE p.RouteName = N'contract' AND ISNULL(p.SysIsDelete, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_menu
    WHERE RouteName IN (N'contract_project-init', N'contract_project_init')
      AND ISNULL(SysIsDelete, 0) = 0
  );

-- 子菜单排序：合同管理在前(1)，项目立项在后(2)
UPDATE dbo.t_sys_menu SET Sort = 1, SysUpdateTime = GETDATE()
WHERE RouteName = N'contract_manage' AND ISNULL(SysIsDelete, 0) = 0;

UPDATE dbo.t_sys_menu SET Sort = 2, SysUpdateTime = GETDATE()
WHERE RouteName IN (N'contract_project-init', N'contract_project_init')
  AND ISNULL(SysIsDelete, 0) = 0;

-- -----------------------------------------------------------------------------
-- 二、角色菜单 t_sys_role_menu（修改 @role_id）
-- -----------------------------------------------------------------------------

DECLARE @role_id INT = 6;

INSERT INTO dbo.t_sys_role_menu (RoleId, MenuId, SysCreateUser, SysUpdateUser, SysDeleteUser, SysIsDelete)
SELECT @role_id, m.Id, 0, 0, 0, 0
FROM dbo.t_sys_menu AS m
WHERE m.RouteName IN (N'contract', N'contract_manage', N'contract_project-init', N'contract_project_init')
  AND ISNULL(m.SysIsDelete, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_role_menu AS rm
    WHERE rm.RoleId = @role_id AND rm.MenuId = m.Id AND ISNULL(rm.SysIsDelete, 0) = 0
  );

-- -----------------------------------------------------------------------------
-- 三、按钮权限 t_sys_role_permiss
-- -----------------------------------------------------------------------------

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, p.UserPermiss, 0, 0, 0
FROM (
  VALUES
    (N'api:Contract:PageList'),
    (N'api:Contract:Detail'),
    (N'api:Contract:Add'),
    (N'api:Contract:Update'),
    (N'api:Contract:Delete'),
    (N'api:Contract:ProjectInit'),
    (N'api:Contract:SubmitApproval')
) AS p(UserPermiss)
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss AS rp
  WHERE rp.RoleId = @role_id AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);

-- -----------------------------------------------------------------------------
-- 四、校验
-- -----------------------------------------------------------------------------
SELECT Id, ParentId, MenuName, RouteName, RoutePath, Component
FROM dbo.t_sys_menu
WHERE RouteName LIKE N'contract%' AND ISNULL(SysIsDelete, 0) = 0
ORDER BY ParentId, Sort;

SELECT rp.RoleId, rp.UserPermiss
FROM dbo.t_sys_role_permiss AS rp
WHERE rp.UserPermiss LIKE N'api:Contract:%' AND ISNULL(rp.SysIsDelete, 0) = 0;
