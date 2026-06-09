-- 产品管理按钮权限（SQL Server）
-- 权限码与框架一致：api:Product:{Action}
-- 执行后请为角色分配并重新登录

DECLARE @role_id INT = 6; -- 按需修改角色 Id

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, p.UserPermiss, 0, 0, 0
FROM (
  VALUES
    (N'api:Product:PageList'),
    (N'api:Product:ListEnabled'),
    (N'api:Product:Add'),
    (N'api:Product:Update'),
    (N'api:Product:Delete')
) AS p(UserPermiss)
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss rp
  WHERE rp.RoleId = @role_id AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);
GO
