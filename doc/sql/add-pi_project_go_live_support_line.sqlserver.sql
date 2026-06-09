IF OBJECT_ID(N'dbo.pi_project_go_live_support_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_go_live_support_line (
    Id                  INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectId           INT                NOT NULL,
    SortNo              INT                NOT NULL CONSTRAINT DF_pi_project_go_live_support_line_SortNo DEFAULT (0),
    SupportContent      NVARCHAR(200)      NOT NULL,
    CompletionCriteria  NVARCHAR(500)      NULL,
    SysCreateUser       INT                NOT NULL CONSTRAINT DF_pi_project_go_live_support_line_SysCreateUser DEFAULT (0),
    SysUpdateUser       INT                NOT NULL CONSTRAINT DF_pi_project_go_live_support_line_SysUpdateUser DEFAULT (0),
    SysIsDelete         BIT                NOT NULL CONSTRAINT DF_pi_project_go_live_support_line_SysIsDelete DEFAULT (0),
    SysCreateTime       DATETIME           NOT NULL CONSTRAINT DF_pi_project_go_live_support_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime       DATETIME           NOT NULL CONSTRAINT DF_pi_project_go_live_support_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_pi_project_go_live_support_line_ProjectId
    ON dbo.pi_project_go_live_support_line (ProjectId)
    WHERE SysIsDelete = 0;
END
GO
