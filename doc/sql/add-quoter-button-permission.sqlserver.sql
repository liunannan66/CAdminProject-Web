-- 报价器管理按钮权限（SQL Server），RoleId=6 请按需修改
INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT 6, p.UserPermiss, 0, 0, 0
FROM (
  VALUES
    (N'api:Quoter:PageList'),
    (N'api:Quoter:ListModuleNames'),
    (N'api:Quoter:ListEnabled'),
    (N'api:Quoter:Add'),
    (N'api:Quoter:Update'),
    (N'api:Quoter:Delete')
) AS p(UserPermiss)
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss rp
  WHERE rp.RoleId = 6 AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);
GO
