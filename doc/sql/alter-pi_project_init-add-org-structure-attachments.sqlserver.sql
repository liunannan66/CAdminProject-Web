IF COL_LENGTH('dbo.pi_project_init', 'OrgStructureAttachmentNames') IS NULL
BEGIN
    ALTER TABLE dbo.pi_project_init
    ADD OrgStructureAttachmentNames NVARCHAR(MAX) NULL;
END
