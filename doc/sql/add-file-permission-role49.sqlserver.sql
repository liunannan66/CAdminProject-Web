-- =============================================================================
-- 为角色 49（用户 aaaaaa）补全文件上传/下载/删除权限
-- 执行后请退出登录并重新登录
-- =============================================================================
DECLARE @role_id INT = 49;

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, p.UserPermiss, 0, 0, 0
FROM (
  VALUES
    (N'api:File:Upload'),
    (N'api:File:Download'),
    (N'api:File:Delete')
) AS p(UserPermiss)
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss AS rp
  WHERE rp.RoleId = @role_id AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);

SELECT RoleId, UserPermiss
FROM dbo.t_sys_role_permiss
WHERE RoleId = @role_id AND UserPermiss LIKE N'api:File:%' AND ISNULL(SysIsDelete, 0) = 0
ORDER BY UserPermiss;
GO
