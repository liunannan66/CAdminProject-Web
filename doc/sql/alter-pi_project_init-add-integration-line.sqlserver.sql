-- 项目立项「系统集成范围」子表
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.pi_project_integration_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_integration_line (
    Id                   INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectId            INT                NOT NULL,
    SortNo               INT                NOT NULL CONSTRAINT DF_pi_project_integration_line_SortNo DEFAULT (0),
    InvolvedSystem       NVARCHAR(100)      NOT NULL,
    IntegrationContent   NVARCHAR(200)      NOT NULL,
    InterfaceCaller      NVARCHAR(100)      NOT NULL,
    InterfaceProvider    NVARCHAR(100)      NOT NULL,
    InterfaceDescription NVARCHAR(500)      NULL,
    IntegrationMethod    NVARCHAR(100)      NOT NULL,
    SysCreateUser        INT                NOT NULL CONSTRAINT DF_pi_project_integration_line_SysCreateUser DEFAULT (0),
    SysUpdateUser        INT                NOT NULL CONSTRAINT DF_pi_project_integration_line_SysUpdateUser DEFAULT (0),
    SysIsDelete          BIT                NOT NULL CONSTRAINT DF_pi_project_integration_line_SysIsDelete DEFAULT (0),
    SysCreateTime        DATETIME           NOT NULL CONSTRAINT DF_pi_project_integration_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime        DATETIME           NOT NULL CONSTRAINT DF_pi_project_integration_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_pi_project_integration_line_ProjectId
    ON dbo.pi_project_integration_line (ProjectId)
    WHERE SysIsDelete = 0;
END
GO
