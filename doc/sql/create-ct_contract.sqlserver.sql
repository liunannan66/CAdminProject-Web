-- =============================================================================
-- 合同管理表 ct_contract / 子表（SQL Server）
-- 执行库：MalusAdminTest（与 WebApi 连接串一致）
-- =============================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.ct_contract', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.ct_contract (
    Id                          INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ContractNo                  NVARCHAR(50)       NOT NULL,
    ContractName                NVARCHAR(100)      NOT NULL,
    CustomerName                NVARCHAR(100)      NOT NULL,
    SignDate                    DATE               NOT NULL,
    ContractType                VARCHAR(20)        NOT NULL,
    DeliveryDate                DATE               NOT NULL,
    SalesOwner                  NVARCHAR(50)       NOT NULL,
    QuoteAmount                 DECIMAL(18, 2)     NOT NULL CONSTRAINT DF_ct_contract_QuoteAmount DEFAULT (0),
    Milestone                   NVARCHAR(MAX)      NULL,
    Remark                      NVARCHAR(MAX)      NULL,
    ApprovalFlow                VARCHAR(50)        NULL,
    Status                      VARCHAR(20)        NOT NULL CONSTRAINT DF_ct_contract_Status DEFAULT ('draft'),
    ContractAttachmentNames     NVARCHAR(MAX)      NULL,
    RequirementAttachmentNames  NVARCHAR(MAX)      NULL,
    SysCreateUser               INT                NOT NULL CONSTRAINT DF_ct_contract_SysCreateUser DEFAULT (0),
    SysUpdateUser               INT                NOT NULL CONSTRAINT DF_ct_contract_SysUpdateUser DEFAULT (0),
    SysIsDelete                 BIT                NOT NULL CONSTRAINT DF_ct_contract_SysIsDelete DEFAULT (0),
    SysCreateTime               DATETIME           NOT NULL CONSTRAINT DF_ct_contract_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime               DATETIME           NOT NULL CONSTRAINT DF_ct_contract_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE UNIQUE INDEX UX_ct_contract_ContractNo
    ON dbo.ct_contract (ContractNo)
    WHERE SysIsDelete = 0;
END
GO

IF OBJECT_ID(N'dbo.ct_contract_payment_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.ct_contract_payment_line (
    Id                 INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ContractId         INT                NOT NULL,
    SortNo             INT                NOT NULL CONSTRAINT DF_ct_contract_payment_line_SortNo DEFAULT (0),
    TermName           NVARCHAR(50)       NOT NULL,
    SettlementMethod   VARCHAR(20)        NOT NULL,
    PaymentRatio       DECIMAL(5, 2)      NOT NULL,
    Node               NVARCHAR(100)      NOT NULL,
    Remark             NVARCHAR(200)      NULL,
    SysCreateUser      INT                NOT NULL CONSTRAINT DF_ct_contract_payment_line_SysCreateUser DEFAULT (0),
    SysUpdateUser      INT                NOT NULL CONSTRAINT DF_ct_contract_payment_line_SysUpdateUser DEFAULT (0),
    SysIsDelete        BIT                NOT NULL CONSTRAINT DF_ct_contract_payment_line_SysIsDelete DEFAULT (0),
    SysCreateTime      DATETIME           NOT NULL CONSTRAINT DF_ct_contract_payment_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime      DATETIME           NOT NULL CONSTRAINT DF_ct_contract_payment_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_ct_contract_payment_line_ContractId
    ON dbo.ct_contract_payment_line (ContractId)
    WHERE SysIsDelete = 0;
END
GO

IF OBJECT_ID(N'dbo.ct_contract_product_line', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.ct_contract_product_line (
    Id              INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ContractId      INT                NOT NULL,
    SortNo          INT                NOT NULL CONSTRAINT DF_ct_contract_product_line_SortNo DEFAULT (0),
    ProductId       INT                NOT NULL,
    ProductName     NVARCHAR(50)       NOT NULL,
    Category        VARCHAR(20)        NOT NULL,
    CategoryLabel   NVARCHAR(30)       NOT NULL,
    Version         NVARCHAR(30)       NOT NULL,
    Quantity        INT                NOT NULL CONSTRAINT DF_ct_contract_product_line_Quantity DEFAULT (1),
    AmountWithTax   DECIMAL(18, 2)     NOT NULL CONSTRAINT DF_ct_contract_product_line_AmountWithTax DEFAULT (0),
    SysCreateUser   INT                NOT NULL CONSTRAINT DF_ct_contract_product_line_SysCreateUser DEFAULT (0),
    SysUpdateUser   INT                NOT NULL CONSTRAINT DF_ct_contract_product_line_SysUpdateUser DEFAULT (0),
    SysIsDelete     BIT                NOT NULL CONSTRAINT DF_ct_contract_product_line_SysIsDelete DEFAULT (0),
    SysCreateTime   DATETIME           NOT NULL CONSTRAINT DF_ct_contract_product_line_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime   DATETIME           NOT NULL CONSTRAINT DF_ct_contract_product_line_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE INDEX IX_ct_contract_product_line_ContractId
    ON dbo.ct_contract_product_line (ContractId)
    WHERE SysIsDelete = 0;
END
GO

-- 详情接口权限（若已执行 init-contract-menu 可单独补 Detail）
DECLARE @role_id INT = 6;

INSERT INTO dbo.t_sys_role_permiss (RoleId, UserPermiss, SysCreateUser, SysUpdateUser, SysIsDelete)
SELECT @role_id, N'api:Contract:Detail', 0, 0, 0
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.t_sys_role_permiss AS rp
  WHERE rp.RoleId = @role_id AND rp.UserPermiss = N'api:Contract:Detail' AND ISNULL(rp.SysIsDelete, 0) = 0
);
GO
