-- 项目任务（扁平清单）API 权限
DECLARE @role_id INT = 6;

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, p.UserPermiss, 0, 0, 0
FROM (VALUES
    (N'api:ProjectTask:PageList'),
    (N'api:ProjectTask:MyPageList'),
    (N'api:ProjectTask:Detail'),
    (N'api:ProjectTask:Add'),
    (N'api:ProjectTask:Update'),
    (N'api:ProjectTask:UpdateProgress'),
    (N'api:ProjectTask:Delete')
) AS p(UserPermiss)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_role_permiss AS rp
    WHERE rp.RoleId = @role_id AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);

SET @role_id = 49;

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, p.UserPermiss, 0, 0, 0
FROM (VALUES
    (N'api:ProjectTask:PageList'),
    (N'api:ProjectTask:MyPageList'),
    (N'api:ProjectTask:Detail'),
    (N'api:ProjectTask:Add'),
    (N'api:ProjectTask:Update'),
    (N'api:ProjectTask:UpdateProgress'),
    (N'api:ProjectTask:Delete')
) AS p(UserPermiss)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.t_sys_role_permiss AS rp
    WHERE rp.RoleId = @role_id AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);
GO
