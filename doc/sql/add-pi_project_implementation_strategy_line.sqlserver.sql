IF OBJECT_ID(N'dbo.pi_project_implementation_strategy_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_implementation_strategy_line (
    Id                          INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectId                   INT                NOT NULL,
    SortNo                      INT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_SortNo DEFAULT (0),
    BusinessSegment             NVARCHAR(200)      NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_BusinessSegment DEFAULT (N''),
    OrgScope                    NVARCHAR(200)      NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_OrgScope DEFAULT (N''),
    SubBranches                 NVARCHAR(200)      NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_SubBranches DEFAULT (N''),
    PhaseStrategy               NVARCHAR(100)      NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_PhaseStrategy DEFAULT (N''),
    Pilot                       BIT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_Pilot DEFAULT (0),
    Promotion                   BIT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_Promotion DEFAULT (0),
    PromotionResponsible        NVARCHAR(100)      NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_PromotionResponsible DEFAULT (N''),
    LocationCentralized         BIT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_LocationCentralized DEFAULT (0),
    LocationDecentralized       BIT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_LocationDecentralized DEFAULT (0),
    LocationRemoteCentralized   BIT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_LocationRemoteCentralized DEFAULT (0),
    LocationRemoteDecentralized BIT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_LocationRemoteDecentralized DEFAULT (0),
    SysCreateUser               INT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_SysCreateUser DEFAULT (0),
    SysUpdateUser               INT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_SysUpdateUser DEFAULT (0),
    SysIsDelete                 BIT                NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_SysIsDelete DEFAULT (0),
    SysCreateTime               DATETIME           NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime               DATETIME           NOT NULL CONSTRAINT DF_pi_project_implementation_strategy_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_pi_project_implementation_strategy_line_ProjectId
    ON dbo.pi_project_implementation_strategy_line (ProjectId)
    WHERE SysIsDelete = 0;
END
GO
