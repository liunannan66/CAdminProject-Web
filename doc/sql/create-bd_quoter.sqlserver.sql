-- =============================================================================
-- 报价器管理表 bd_quoter（SQL Server）
-- =============================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.bd_quoter', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.bd_quoter (
    Id              INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    ModuleName      NVARCHAR(50)       NOT NULL,
    SubModuleName   NVARCHAR(50)       NOT NULL,
    Description     NVARCHAR(300)      NOT NULL,
    UnitPrice       DECIMAL(18, 2)     NULL,
    Status          TINYINT            NOT NULL CONSTRAINT DF_bd_quoter_Status DEFAULT (1),
    SysCreateUser   INT                NOT NULL CONSTRAINT DF_bd_quoter_SysCreateUser DEFAULT (0),
    SysUpdateUser   INT                NOT NULL CONSTRAINT DF_bd_quoter_SysUpdateUser DEFAULT (0),
    SysIsDelete     BIT                NOT NULL CONSTRAINT DF_bd_quoter_SysIsDelete DEFAULT (0),
    SysCreateTime   DATETIME           NOT NULL CONSTRAINT DF_bd_quoter_SysCreateTime DEFAULT (GETDATE()),
    SysUpdateTime   DATETIME           NOT NULL CONSTRAINT DF_bd_quoter_SysUpdateTime DEFAULT (GETDATE())
  );
END
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'UX_bd_quoter_Module_Sub' AND object_id = OBJECT_ID(N'dbo.bd_quoter')
)
BEGIN
  CREATE UNIQUE INDEX UX_bd_quoter_Module_Sub
    ON dbo.bd_quoter (ModuleName, SubModuleName)
    WHERE SysIsDelete = 0;
END
GO

-- 种子数据（与前端 mock 对齐）
IF NOT EXISTS (SELECT 1 FROM dbo.bd_quoter WHERE ModuleName = N'财务云' AND SubModuleName = N'总账初始化' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_quoter (ModuleName, SubModuleName, Description, UnitPrice, Status)
  VALUES (N'财务云', N'总账初始化', N'会计科目、凭证字、账簿参数等基础资料配置与期初余额录入', 8000, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_quoter WHERE ModuleName = N'财务云' AND SubModuleName = N'报表合并' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_quoter (ModuleName, SubModuleName, Description, UnitPrice, Status)
  VALUES (N'财务云', N'报表合并', N'合并报表模板设计、抵消分录规则配置及合并流程培训', 12000, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_quoter WHERE ModuleName = N'供应链云' AND SubModuleName = N'采购管理' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_quoter (ModuleName, SubModuleName, Description, UnitPrice, Status)
  VALUES (N'供应链云', N'采购管理', N'采购申请、采购订单、收料入库及供应商协同流程实施', 15000, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_quoter WHERE ModuleName = N'供应链云' AND SubModuleName = N'库存管理' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_quoter (ModuleName, SubModuleName, Description, UnitPrice, Status)
  VALUES (N'供应链云', N'库存管理', N'仓库档案、批次序列号、盘点调拨及库存报表上线', 10000, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_quoter WHERE ModuleName = N'制造云' AND SubModuleName = N'生产订单' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_quoter (ModuleName, SubModuleName, Description, UnitPrice, Status)
  VALUES (N'制造云', N'生产订单', N'BOM、工艺路线、生产订单下达与完工入库流程配置', 18000, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_quoter WHERE ModuleName = N'人力资源' AND SubModuleName = N'薪酬核算' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_quoter (ModuleName, SubModuleName, Description, UnitPrice, Status)
  VALUES (N'人力资源', N'薪酬核算', N'薪酬项目、计税规则、工资发放及社保公积金对接', 9000, 0);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_quoter WHERE ModuleName = N'项目交付' AND SubModuleName = N'上线切换' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_quoter (ModuleName, SubModuleName, Description, UnitPrice, Status)
  VALUES (N'项目交付', N'上线切换', N'切换方案编制、数据迁移验证、关键用户培训与上线陪跑', NULL, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bd_quoter WHERE ModuleName = N'项目交付' AND SubModuleName = N'运维支持' AND SysIsDelete = 0)
  INSERT INTO dbo.bd_quoter (ModuleName, SubModuleName, Description, UnitPrice, Status)
  VALUES (N'项目交付', N'运维支持', N'上线后问题响应、补丁评估与月度运维巡检（按人天计）', 1200, 1);
GO
