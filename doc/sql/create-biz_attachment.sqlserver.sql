-- =============================================================================
-- 业务附件表 biz_attachment（SQL Server）
-- 执行库：MalusAdminTest
-- =============================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.biz_attachment', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.biz_attachment (
    Id            INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    BizType       VARCHAR(30)        NOT NULL,
    BizId         INT                NOT NULL CONSTRAINT DF_biz_attachment_BizId DEFAULT (0),
    FileName      NVARCHAR(255)      NOT NULL,
    StoredPath    NVARCHAR(500)      NOT NULL,
    FileSize      BIGINT             NOT NULL CONSTRAINT DF_biz_attachment_FileSize DEFAULT (0),
    ContentType   NVARCHAR(100)      NULL,
    SortNo        INT                NOT NULL CONSTRAINT DF_biz_attachment_SortNo DEFAULT (0),
    SysCreateUser INT                NOT NULL CONSTRAINT DF_biz_attachment_SysCreateUser DEFAULT (0),
    SysUpdateUser INT                NOT NULL CONSTRAINT DF_biz_attachment_SysUpdateUser DEFAULT (0),
    SysIsDelete   BIT                NOT NULL CONSTRAINT DF_biz_attachment_SysIsDelete DEFAULT (0),
    SysCreateTime DATETIME           NOT NULL CONSTRAINT DF_biz_attachment_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime DATETIME           NOT NULL CONSTRAINT DF_biz_attachment_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_biz_attachment_Biz
    ON dbo.biz_attachment (BizType, BizId)
    WHERE SysIsDelete = 0;
END
GO

-- 文件接口按钮权限（修改 @role_id 后执行）
DECLARE @role_id INT = 6;

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
GO
