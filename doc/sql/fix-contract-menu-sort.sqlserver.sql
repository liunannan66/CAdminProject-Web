-- 合同管理目录下子菜单排序：合同管理(1) 在前，项目立项(2) 在后
-- 执行后请重新登录以刷新菜单缓存

UPDATE dbo.t_sys_menu
SET Sort = 1, SysUpdateTime = GETDATE()
WHERE RouteName = N'contract_manage' AND ISNULL(SysIsDelete, 0) = 0;

UPDATE dbo.t_sys_menu
SET Sort = 2, SysUpdateTime = GETDATE()
WHERE RouteName IN (N'contract_project-init', N'contract_project_init')
  AND ISNULL(SysIsDelete, 0) = 0;

SELECT Id, ParentId, MenuName, RouteName, Sort
FROM dbo.t_sys_menu
WHERE RouteName LIKE N'contract%'
  AND ISNULL(SysIsDelete, 0) = 0
ORDER BY ParentId, Sort;
GO
