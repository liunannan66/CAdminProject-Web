-- 任务管理菜单（任务池/WBS）
-- SQL Server 版本：在数据库中执行后，请重新登录以刷新菜单缓存

-- 1. 父菜单：任务管理（排序在合同管理之后，Sort=6）
IF EXISTS (
    SELECT 1
    FROM dbo.t_sys_menu
    WHERE RouteName = N'task' AND ISNULL(SysIsDelete, 0) = 0
)
BEGIN
    UPDATE dbo.t_sys_menu
    SET MenuName = N'任务管理',
        RoutePath = N'/task',
        Status = 1,
        HideInMenu = 0,
        Sort = 6,
        Component = N'layout.base',
        Icon = N'carbon:task',
        IconType = 1,
        SysUpdateTime = GETDATE()
    WHERE RouteName = N'task' AND ISNULL(SysIsDelete, 0) = 0;
END
ELSE
BEGIN
    INSERT INTO dbo.t_sys_menu (
        ParentId, MenuType, MenuName, RouteName, RoutePath,
        Status, HideInMenu, Sort, Component, Icon, IconType,
        SysCreateUser, SysUpdateUser, SysDeleteUser, SysIsDelete,
        SysCreateTime, SysUpdateTime
    )
    VALUES (
        0, 1, N'任务管理', N'task', N'/task',
        1, 0, 6, N'layout.base', N'carbon:task', 1,
        0, 0, 0, 0,
        GETDATE(), GETDATE()
    );
END
GO

-- 2. 子菜单：任务池（WBS）
IF EXISTS (
    SELECT 1
    FROM dbo.t_sys_menu
    WHERE RouteName = N'task_wbs' AND ISNULL(SysIsDelete, 0) = 0
)
BEGIN
    UPDATE dbo.t_sys_menu
    SET MenuName = N'任务池（WBS）',
        RoutePath = N'/task/wbs',
        Status = 1,
        HideInMenu = 0,
        Sort = 1,
        Component = N'view.task_wbs',
        Icon = N'carbon:view-next',
        IconType = 1,
        SysUpdateTime = GETDATE()
    WHERE RouteName = N'task_wbs' AND ISNULL(SysIsDelete, 0) = 0;
END
ELSE
BEGIN
    INSERT INTO dbo.t_sys_menu (
        ParentId, MenuType, MenuName, RouteName, RoutePath,
        Status, HideInMenu, Sort, Component, Icon, IconType,
        SysCreateUser, SysUpdateUser, SysDeleteUser, SysIsDelete,
        SysCreateTime, SysUpdateTime
    )
    SELECT TOP (1)
        m.Id, 2, N'任务池（WBS）', N'task_wbs', N'/task/wbs',
        1, 0, 1, N'view.task_wbs', N'carbon:view-next', 1,
        0, 0, 0, 0,
        GETDATE(), GETDATE()
    FROM dbo.t_sys_menu m
    WHERE m.RouteName = N'task' AND ISNULL(m.SysIsDelete, 0) = 0;
END
GO

-- 3. 非超级管理员角色菜单权限（按需修改 RoleId）
DECLARE @role_id INT = 6;

INSERT INTO dbo.t_sys_role_menu (
    RoleId, MenuId, SysCreateUser, SysUpdateUser, SysDeleteUser, SysIsDelete
)
SELECT @role_id, m.Id, 0, 0, 0, 0
FROM dbo.t_sys_menu m
WHERE m.RouteName IN (N'task', N'task_wbs')
  AND ISNULL(m.SysIsDelete, 0) = 0
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.t_sys_role_menu rm
      WHERE rm.RoleId = @role_id
        AND rm.MenuId = m.Id
        AND ISNULL(rm.SysIsDelete, 0) = 0
  );
GO
