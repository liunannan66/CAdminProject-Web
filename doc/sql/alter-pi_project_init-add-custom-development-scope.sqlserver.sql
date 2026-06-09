-- 项目立项主表增加「定制化开发范围」文本字段
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH(N'dbo.pi_project_init', N'CustomDevelopmentScope') IS NULL
BEGIN
  ALTER TABLE dbo.pi_project_init
    ADD CustomDevelopmentScope NVARCHAR(MAX) NULL;
END
GO
