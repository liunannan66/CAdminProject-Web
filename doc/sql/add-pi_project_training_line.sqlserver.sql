IF OBJECT_ID(N'dbo.pi_project_training_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_training_line (
    Id               INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectId        INT                NOT NULL,
    SortNo           INT                NOT NULL CONSTRAINT DF_pi_project_training_line_SortNo DEFAULT (0),
    TrainingContent  NVARCHAR(200)      NOT NULL,
    Trainer          NVARCHAR(100)      NOT NULL,
    TargetAudience   NVARCHAR(200)      NOT NULL,
    TrainingMethod   NVARCHAR(200)      NOT NULL,
    TrainingLocation NVARCHAR(200)      NOT NULL,
    SysCreateUser    INT                NOT NULL CONSTRAINT DF_pi_project_training_line_SysCreateUser DEFAULT (0),
    SysUpdateUser    INT                NOT NULL CONSTRAINT DF_pi_project_training_line_SysUpdateUser DEFAULT (0),
    SysIsDelete      BIT                NOT NULL CONSTRAINT DF_pi_project_training_line_SysIsDelete DEFAULT (0),
    SysCreateTime    DATETIME           NOT NULL CONSTRAINT DF_pi_project_training_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime    DATETIME           NOT NULL CONSTRAINT DF_pi_project_training_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_pi_project_training_line_ProjectId
    ON dbo.pi_project_training_line (ProjectId)
    WHERE SysIsDelete = 0;
END
GO
