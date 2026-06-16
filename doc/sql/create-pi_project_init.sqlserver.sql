-- =============================================================================
-- 项目立项表 pi_project_init / 子表（SQL Server）
-- 执行库：MalusAdminTest
-- =============================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.pi_project_init', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_init (
    Id                          INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectNo                   NVARCHAR(80)       NOT NULL,
    ProjectName                 NVARCHAR(100)      NOT NULL,
    ProjectType                 VARCHAR(20)        NOT NULL CONSTRAINT DF_pi_project_init_ProjectType DEFAULT ('self'),
    Status                      VARCHAR(20)        NOT NULL CONSTRAINT DF_pi_project_init_Status DEFAULT ('draft'),
    ContractId                  INT                NOT NULL,
    ContractNo                  NVARCHAR(50)       NOT NULL,
    ContractName                NVARCHAR(100)      NOT NULL,
    CustomerName                NVARCHAR(100)      NOT NULL,
    PlanStartDate               DATE               NOT NULL,
    PlanEndDate                 DATE               NOT NULL,
    Background                  NVARCHAR(MAX)      NULL,
    Objective                   NVARCHAR(MAX)      NULL,
    Milestone                   NVARCHAR(MAX)      NULL,
    CustomDevelopmentScope      NVARCHAR(MAX)      NULL,
    ImplementationStrategy      NVARCHAR(MAX)      NULL,
    ContractType                VARCHAR(20)        NOT NULL,
    SignDate                    DATE               NOT NULL,
    ContactPerson               NVARCHAR(50)       NULL,
    PartyA                      NVARCHAR(100)      NULL,
    ProjectManager              NVARCHAR(50)       NULL,
    Phone                       NVARCHAR(30)       NULL,
    Wechat                      NVARCHAR(50)       NULL,
    Address                     NVARCHAR(200)      NULL,
    Email                       NVARCHAR(100)      NULL,
    ContractQuoteAmount         DECIMAL(18, 2)     NOT NULL CONSTRAINT DF_pi_project_init_ContractQuoteAmount DEFAULT (0),
    ContractAttachmentNames     NVARCHAR(MAX)      NULL,
    RequirementAttachmentNames  NVARCHAR(MAX)      NULL,
    SysCreateUser               INT                NOT NULL CONSTRAINT DF_pi_project_init_SysCreateUser DEFAULT (0),
    SysUpdateUser               INT                NOT NULL CONSTRAINT DF_pi_project_init_SysUpdateUser DEFAULT (0),
    SysIsDelete                 BIT                NOT NULL CONSTRAINT DF_pi_project_init_SysIsDelete DEFAULT (0),
    SysCreateTime               DATETIME           NOT NULL CONSTRAINT DF_pi_project_init_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime               DATETIME           NOT NULL CONSTRAINT DF_pi_project_init_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE UNIQUE INDEX UX_pi_project_init_ProjectNo
    ON dbo.pi_project_init (ProjectNo)
    WHERE SysIsDelete = 0;

  CREATE INDEX IX_pi_project_init_ContractId
    ON dbo.pi_project_init (ContractId)
    WHERE SysIsDelete = 0;
END
GO

IF OBJECT_ID(N'dbo.pi_project_payment_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_payment_line (
    Id                 INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectId          INT                NOT NULL,
    SortNo             INT                NOT NULL CONSTRAINT DF_pi_project_payment_line_SortNo DEFAULT (0),
    TermName           NVARCHAR(50)       NOT NULL,
    SettlementMethod   VARCHAR(20)        NOT NULL,
    PaymentRatio       DECIMAL(5, 2)      NOT NULL,
    Node               NVARCHAR(100)      NOT NULL,
    Remark             NVARCHAR(200)      NULL,
    SysCreateUser      INT                NOT NULL CONSTRAINT DF_pi_project_payment_line_SysCreateUser DEFAULT (0),
    SysUpdateUser      INT                NOT NULL CONSTRAINT DF_pi_project_payment_line_SysUpdateUser DEFAULT (0),
    SysIsDelete        BIT                NOT NULL CONSTRAINT DF_pi_project_payment_line_SysIsDelete DEFAULT (0),
    SysCreateTime      DATETIME           NOT NULL CONSTRAINT DF_pi_project_payment_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime      DATETIME           NOT NULL CONSTRAINT DF_pi_project_payment_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_pi_project_payment_line_ProjectId
    ON dbo.pi_project_payment_line (ProjectId)
    WHERE SysIsDelete = 0;
END
GO

IF OBJECT_ID(N'dbo.pi_project_product_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_product_line (
    Id              INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectId       INT                NOT NULL,
    SortNo          INT                NOT NULL CONSTRAINT DF_pi_project_product_line_SortNo DEFAULT (0),
    ProductId       INT                NOT NULL,
    ProductName     NVARCHAR(50)       NOT NULL,
    Category        VARCHAR(20)        NOT NULL,
    CategoryLabel   NVARCHAR(30)       NOT NULL,
    Version         NVARCHAR(30)       NOT NULL,
    Quantity        INT                NOT NULL CONSTRAINT DF_pi_project_product_line_Quantity DEFAULT (1),
    AmountWithTax   DECIMAL(18, 2)     NOT NULL CONSTRAINT DF_pi_project_product_line_AmountWithTax DEFAULT (0),
    SysCreateUser   INT                NOT NULL CONSTRAINT DF_pi_project_product_line_SysCreateUser DEFAULT (0),
    SysUpdateUser   INT                NOT NULL CONSTRAINT DF_pi_project_product_line_SysUpdateUser DEFAULT (0),
    SysIsDelete     BIT                NOT NULL CONSTRAINT DF_pi_project_product_line_SysIsDelete DEFAULT (0),
    SysCreateTime   DATETIME           NOT NULL CONSTRAINT DF_pi_project_product_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime   DATETIME           NOT NULL CONSTRAINT DF_pi_project_product_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_pi_project_product_line_ProjectId
    ON dbo.pi_project_product_line (ProjectId)
    WHERE SysIsDelete = 0;
END
GO

IF OBJECT_ID(N'dbo.pi_project_implementation_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_implementation_line (
    Id              INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectId       INT                NOT NULL,
    SortNo          INT                NOT NULL CONSTRAINT DF_pi_project_implementation_line_SortNo DEFAULT (0),
    ModuleName      NVARCHAR(50)       NOT NULL,
    SubModuleName   NVARCHAR(50)       NOT NULL,
    Description     NVARCHAR(MAX)      NULL,
    Remark          NVARCHAR(200)      NULL,
    SysCreateUser   INT                NOT NULL CONSTRAINT DF_pi_project_implementation_line_SysCreateUser DEFAULT (0),
    SysUpdateUser   INT                NOT NULL CONSTRAINT DF_pi_project_implementation_line_SysUpdateUser DEFAULT (0),
    SysIsDelete     BIT                NOT NULL CONSTRAINT DF_pi_project_implementation_line_SysIsDelete DEFAULT (0),
    SysCreateTime   DATETIME           NOT NULL CONSTRAINT DF_pi_project_implementation_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime   DATETIME           NOT NULL CONSTRAINT DF_pi_project_implementation_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_pi_project_implementation_line_ProjectId
    ON dbo.pi_project_implementation_line (ProjectId)
    WHERE SysIsDelete = 0;
END
GO

IF OBJECT_ID(N'dbo.pi_project_org_scope_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_org_scope_line (
    Id                    INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectId             INT                NOT NULL,
    SortNo                INT                NOT NULL CONSTRAINT DF_pi_project_org_scope_line_SortNo DEFAULT (0),
    OrgName               NVARCHAR(100)      NULL,
    CompanyName           NVARCHAR(100)      NOT NULL,
    CompanyQualification  NVARCHAR(200)      NULL,
    SysCreateUser         INT                NOT NULL CONSTRAINT DF_pi_project_org_scope_line_SysCreateUser DEFAULT (0),
    SysUpdateUser         INT                NOT NULL CONSTRAINT DF_pi_project_org_scope_line_SysUpdateUser DEFAULT (0),
    SysIsDelete           BIT                NOT NULL CONSTRAINT DF_pi_project_org_scope_line_SysIsDelete DEFAULT (0),
    SysCreateTime         DATETIME           NOT NULL CONSTRAINT DF_pi_project_org_scope_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime         DATETIME           NOT NULL CONSTRAINT DF_pi_project_org_scope_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_pi_project_org_scope_line_ProjectId
    ON dbo.pi_project_org_scope_line (ProjectId)
    WHERE SysIsDelete = 0;
END
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

IF OBJECT_ID(N'dbo.pi_project_data_conversion_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.pi_project_data_conversion_line (
    Id                INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ProjectId         INT                NOT NULL,
    SortNo            INT                NOT NULL CONSTRAINT DF_pi_project_data_conversion_line_SortNo DEFAULT (0),
    DataName          NVARCHAR(100)      NOT NULL,
    ScopeDescription  NVARCHAR(500)      NULL,
    SysCreateUser     INT                NOT NULL CONSTRAINT DF_pi_project_data_conversion_line_SysCreateUser DEFAULT (0),
    SysUpdateUser     INT                NOT NULL CONSTRAINT DF_pi_project_data_conversion_line_SysUpdateUser DEFAULT (0),
    SysIsDelete       BIT                NOT NULL CONSTRAINT DF_pi_project_data_conversion_line_SysIsDelete DEFAULT (0),
    SysCreateTime     DATETIME           NOT NULL CONSTRAINT DF_pi_project_data_conversion_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime     DATETIME           NOT NULL CONSTRAINT DF_pi_project_data_conversion_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_pi_project_data_conversion_line_ProjectId
    ON dbo.pi_project_data_conversion_line (ProjectId)
    WHERE SysIsDelete = 0;
END
GO

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

-- 立项接口权限（角色 6 与 49）
DECLARE @role_id INT = 6;

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, p.UserPermiss, 0, 0, 0
FROM (
  VALUES
    (N'api:ProjectInit:PageList'),
    (N'api:ProjectInit:Detail'),
    (N'api:ProjectInit:Add'),
    (N'api:ProjectInit:Update'),
    (N'api:ProjectInit:Delete')
) AS p(UserPermiss)
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss AS rp
  WHERE rp.RoleId = @role_id AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);

SET @role_id = 49;

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, p.UserPermiss, 0, 0, 0
FROM (
  VALUES
    (N'api:ProjectInit:PageList'),
    (N'api:ProjectInit:Detail'),
    (N'api:ProjectInit:Add'),
    (N'api:ProjectInit:Update'),
    (N'api:ProjectInit:Delete')
) AS p(UserPermiss)
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss AS rp
  WHERE rp.RoleId = @role_id AND rp.UserPermiss = p.UserPermiss AND ISNULL(rp.SysIsDelete, 0) = 0
);
GO
