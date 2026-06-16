IF OBJECT_ID(N'dbo.pi_project_task', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.pi_project_task
    (
        Id              INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
        ProjectId       INT            NOT NULL,
        SortNo          INT            NOT NULL CONSTRAINT DF_pi_project_task_SortNo DEFAULT (1),
        TaskName        NVARCHAR(200)  NOT NULL,
        Description     NVARCHAR(1000) NULL,
        StartDate       DATE           NOT NULL,
        EndDate         DATE           NOT NULL,
        AssigneeUserId  INT            NOT NULL,
        AssigneeName    NVARCHAR(50)   NOT NULL,
        Priority        NVARCHAR(20)   NOT NULL CONSTRAINT DF_pi_project_task_Priority DEFAULT (N'normal'),
        Progress        INT            NOT NULL CONSTRAINT DF_pi_project_task_Progress DEFAULT (0),
        Status          NVARCHAR(20)   NOT NULL CONSTRAINT DF_pi_project_task_Status DEFAULT (N'pending'),
        Remark          NVARCHAR(500)  NULL,
        SysCreateUser   INT            NOT NULL CONSTRAINT DF_pi_project_task_SysCreateUser DEFAULT (0),
        SysCreateTime   DATETIME       NOT NULL CONSTRAINT DF_pi_project_task_SysCreateTime DEFAULT (GETDATE()),
        SysUpdateUser   INT            NOT NULL CONSTRAINT DF_pi_project_task_SysUpdateUser DEFAULT (0),
        SysUpdateTime   DATETIME       NOT NULL CONSTRAINT DF_pi_project_task_SysUpdateTime DEFAULT (GETDATE()),
        SysIsDelete     BIT            NOT NULL CONSTRAINT DF_pi_project_task_SysIsDelete DEFAULT (0)
    );

    CREATE INDEX IX_pi_project_task_ProjectId ON dbo.pi_project_task (ProjectId) WHERE SysIsDelete = 0;
    CREATE INDEX IX_pi_project_task_AssigneeUserId ON dbo.pi_project_task (AssigneeUserId) WHERE SysIsDelete = 0;
END
GO
