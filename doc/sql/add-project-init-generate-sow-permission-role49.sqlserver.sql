-- 项目立项「生成 SOW」按钮权限（角色 6 与 49）
DECLARE @role_id INT = 6;

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, p.UserPermiss, 0, 0, 0
FROM (VALUES (N'api:ProjectInit:GenerateSow')) AS p(UserPermiss)
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss AS rp
  WHERE rp.RoleId = @role_id AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);

SET @role_id = 49;

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, p.UserPermiss, 0, 0, 0
FROM (VALUES (N'api:ProjectInit:GenerateSow')) AS p(UserPermiss)
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss AS rp
  WHERE rp.RoleId = @role_id AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);
GO
