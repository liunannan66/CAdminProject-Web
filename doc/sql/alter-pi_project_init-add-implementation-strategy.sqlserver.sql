-- 项目立项主表增加「实施策略」富文本字段
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH(N'dbo.pi_project_init', N'ImplementationStrategy') IS NULL
BEGIN
  ALTER TABLE dbo.pi_project_init
    ADD ImplementationStrategy NVARCHAR(MAX) NULL;
END
GO
