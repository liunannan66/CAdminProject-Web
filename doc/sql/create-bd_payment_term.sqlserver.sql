-- =============================================================================
-- 付款条件管理表 bd_payment_term（SQL Server）
-- =============================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.bd_payment_term', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.bd_payment_term (
    Id                INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Name              NVARCHAR(50)       NOT NULL,
    SettlementMethod  VARCHAR(20)        NOT NULL,
    PaymentRatio      DECIMAL(5, 2)      NOT NULL,
    Node              NVARCHAR(100)      NOT NULL,
    Remark            NVARCHAR(200)      NULL,
    Status            TINYINT            NOT NULL CONSTRAINT DF_bd_payment_term_Status DEFAULT (1),
    SysCreateUser     INT                NOT NULL CONSTRAINT DF_bd_payment_term_SysCreateUser DEFAULT (0),
    SysUpdateUser     INT                NOT NULL CONSTRAINT DF_bd_payment_term_SysUpdateUser DEFAULT (0),
    SysIsDelete       BIT                NOT NULL CONSTRAINT DF_bd_payment_term_SysIsDelete DEFAULT (0),
    SysCreateTime     DATETIME           NOT NULL CONSTRAINT DF_bd_payment_term_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime     DATETIME           NOT NULL CONSTRAINT DF_bd_payment_term_SysUpdateTime DEFAULT (GETDATE())
  );
END
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'UX_bd_payment_term_Name' AND object_id = OBJECT_ID(N'dbo.bd_payment_term')
)
BEGIN
  CREATE UNIQUE INDEX UX_bd_payment_term_Name
    ON dbo.bd_payment_term (Name)
    WHERE SysIsDelete = 0;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.bd_payment_term WHERE Name = N'合同签订预付款' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_payment_term (Name, SettlementMethod, PaymentRatio, Node, Remark, Status)
  VALUES (N'合同签订预付款', 'prepay', 30, N'合同签订后 7 个工作日内', N'项目启动前收取', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_payment_term WHERE Name = N'一期进度款' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_payment_term (Name, SettlementMethod, PaymentRatio, Node, Remark, Status)
  VALUES (N'一期进度款', 'progress', 40, N'完成一期验收后', N'对应里程碑一期', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_payment_term WHERE Name = N'终验款' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_payment_term (Name, SettlementMethod, PaymentRatio, Node, Remark, Status)
  VALUES (N'终验款', 'acceptance', 25, N'项目终验通过后 15 日内', N'', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_payment_term WHERE Name = N'质保金' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_payment_term (Name, SettlementMethod, PaymentRatio, Node, Remark, Status)
  VALUES (N'质保金', 'warranty', 5, N'质保期满且无未结事项', N'质保期 12 个月', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_payment_term WHERE Name = N'月结服务费' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_payment_term (Name, SettlementMethod, PaymentRatio, Node, Remark, Status)
  VALUES (N'月结服务费', 'monthly', 100, N'每月 25 日前结算上月费用', N'运维类合同适用', 0);
GO
