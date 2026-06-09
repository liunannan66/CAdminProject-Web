-- =============================================================================
-- 产品管理表 bd_product（SQL Server）
-- 执行库：MalusAdminTest（与 WebApi 连接串一致）
-- =============================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.bd_product', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.bd_product (
    Id              INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Category        VARCHAR(20)        NOT NULL,
    Name            NVARCHAR(50)       NOT NULL,
    Version         NVARCHAR(30)       NOT NULL,
    Description     NVARCHAR(200)      NULL,
    Status          TINYINT            NOT NULL CONSTRAINT DF_bd_product_Status DEFAULT (1),
    SysCreateUser   INT                NOT NULL CONSTRAINT DF_bd_product_SysCreateUser DEFAULT (0),
    SysUpdateUser   INT                NOT NULL CONSTRAINT DF_bd_product_SysUpdateUser DEFAULT (0),
    SysIsDelete     BIT                NOT NULL CONSTRAINT DF_bd_product_SysIsDelete DEFAULT (0),
    SysCreateTime   DATETIME           NOT NULL CONSTRAINT DF_bd_product_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime   DATETIME           NOT NULL CONSTRAINT DF_bd_product_SysUpdateTime DEFAULT (GETDATE())
  );

  CREATE UNIQUE INDEX UX_bd_product_Name_Version
    ON dbo.bd_product (Name, Version)
    WHERE SysIsDelete = 0;
END
GO

-- 种子数据（与前端 mock 对齐，可重复执行跳过已存在）
IF NOT EXISTS (SELECT 1 FROM dbo.bd_product WHERE Name = N'金蝶云·星空' AND Version = N'旗舰版' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_product (Category, Name, Version, Description, Status)
  VALUES (N'main', N'金蝶云·星空', N'旗舰版', N'面向集团型企业的云 ERP 产品，支持多组织、多业态管理', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_product WHERE Name = N'金蝶云·星空' AND Version = N'生鲜版' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_product (Category, Name, Version, Description, Status)
  VALUES (N'main', N'金蝶云·星空', N'生鲜版', N'面向快消生鲜行业的专用版本，覆盖冷链与批次管理', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_product WHERE Name = N'金蝶 KIS' AND Version = N'专业版' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_product (Category, Name, Version, Description, Status)
  VALUES (N'main', N'金蝶 KIS', N'专业版', N'小微企业财务业务一体化解决方案', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_product WHERE Name = N'第三方 BI 报表' AND Version = N'V3.2' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_product (Category, Name, Version, Description, Status)
  VALUES (N'third', N'第三方 BI 报表', N'V3.2', N'外部采购的数据可视化与经营分析组件', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_product WHERE Name = N'第三方电子签章' AND Version = N'标准版' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_product (Category, Name, Version, Description, Status)
  VALUES (N'third', N'第三方电子签章', N'标准版', N'合同电子签署服务对接模块', 0);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_product WHERE Name = N'金蝶云·星瀚' AND Version = N'企业版' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_product (Category, Name, Version, Description, Status)
  VALUES (N'main', N'金蝶云·星瀚', N'企业版', N'大型企业数字化核心平台，支持复杂业务流程编排', 1);
GO
