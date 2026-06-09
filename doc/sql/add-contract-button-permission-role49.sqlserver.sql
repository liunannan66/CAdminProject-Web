-- =============================================================================
-- 为角色 49（用户 aaaaaa）补全合同管理按钮权限
-- 执行后请退出登录并重新登录
-- =============================================================================
DECLARE @role_id INT = 49;

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

SELECT RoleId, UserPermiss
FROM dbo.t_sys_role_permiss
WHERE RoleId = @role_id AND UserPermiss LIKE N'api:Contract:%' AND ISNULL(SysIsDelete, 0) = 0
ORDER BY UserPermiss;
GO
