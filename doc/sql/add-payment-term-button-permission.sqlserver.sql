-- 付款条件模块按钮权限（SQL Server）
-- 执行后请为对应角色分配权限，并让相关用户重新登录
-- 权限码需与前端 src/constants/basedata-payment-term.ts 中 PAYMENT_TERM_AUTH 一致

-- 表名：t_sys_role_permiss（MalusAdmin）
-- 以下为信息管理员 RoleId=6 示例，请按库中角色 Id 修改

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT 6, p.UserPermiss, 0, 0, 0
FROM (
  VALUES
    (N'api:PaymentTerm:PageList'),
    (N'api:PaymentTerm:ListEnabled'),
    (N'api:PaymentTerm:Add'),
    (N'api:PaymentTerm:Update'),
    (N'api:PaymentTerm:Delete')
) AS p(UserPermiss)
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss rp
  WHERE rp.RoleId = 6 AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);
GO
