-- 项目立项主表增加「里程碑」字段（与合同 Milestone 对应，从合同自动带入）
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH(N'dbo.pi_project_init', N'Milestone') IS NULL
BEGIN
  ALTER TABLE dbo.pi_project_init
    ADD Milestone NVARCHAR(MAX) NULL;
END
GO

-- 历史数据：旧版将合同里程碑写入 Background，迁移到 Milestone 并清空 Background
UPDATE dbo.pi_project_init
SET Milestone = Background,
    Background = NULL
WHERE SysIsDelete = 0
  AND Milestone IS NULL
  AND Background IS NOT NULL
  AND LTRIM(RTRIM(Background)) <> N'';
GO
