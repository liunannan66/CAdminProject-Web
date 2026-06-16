IF COL_LENGTH('dbo.pi_project_init', 'SowReferenceAttachmentNames') IS NULL
BEGIN
  ALTER TABLE dbo.pi_project_init
    ADD SowReferenceAttachmentNames NVARCHAR(MAX) NULL;
END
GO
