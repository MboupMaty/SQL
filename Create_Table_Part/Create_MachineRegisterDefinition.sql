USE [Certiq]
GO

IF OBJECT_ID('dbo.usp_Sync_MachineRegisterDefinition', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Sync_MachineRegisterDefinition;
GO

CREATE PROCEDURE dbo.usp_Sync_MachineRegisterDefinition
    @RunArchive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    -- --------------------------------------------------------
    -- ÉTAPE 1 : MERGE — sync complet sans filtre de date
    -- --------------------------------------------------------
    SET @SQL = N'
    MERGE [Certiq].[dbo].[MachineRegisterDefinition] AS target
    USING (
        SELECT *
        FROM OPENQUERY([LMQ-Certiq-01],
            ''SELECT
                MachineRegisterId,
                MachineId,
                RegisterName,
                RegisterDescription,
                MachineDataType,
                RegisterDomain,
                IsNodeRegister,
                NodeIndex,
                RegisterAccess,
                VisibleForCustomer,
                Unit,                  
                DecimalCount,
                IsArray,
                ArraySize,
                DefaultGraphType,
                PresentationScaling,
                PresentationScale,
                PresentationOffset,
                AreMinMaxValid,
                MinAllowedValue,
                MaxAllowedValue,
                TreeLevel,
                TreeHierarchy,
                TreeParent,
                ViewOrder,
                RegisterType,
                RegisterValueType,
                TransmissionPriority,
                AddHistory,
                ExternalName1,
                ExternalName2
              FROM promine_db.dbo.vw_MachineRegisterDefinition'')
    ) AS source
    ON target.MachineRegisterId = source.MachineRegisterId
   AND target.MachineId         = source.MachineId

    -- Ligne existante → UPDATE
    WHEN MATCHED
    THEN UPDATE SET
        target.RegisterName          = source.RegisterName,
        target.RegisterDescription   = source.RegisterDescription,
        target.MachineDataType       = source.MachineDataType,
        target.RegisterDomain        = source.RegisterDomain,
        target.IsNodeRegister        = source.IsNodeRegister,
        target.NodeIndex             = source.NodeIndex,
        target.RegisterAccess        = source.RegisterAccess,
        target.VisibleForCustomer    = source.VisibleForCustomer,
        target.Unit                  = source.Unit,
        target.DecimalCount          = source.DecimalCount,
        target.IsArray               = source.IsArray,
        target.ArraySize             = source.ArraySize,
        target.DefaultGraphType      = source.DefaultGraphType,
        target.PresentationScaling   = source.PresentationScaling,
        target.PresentationScale     = source.PresentationScale,
        target.PresentationOffset    = source.PresentationOffset,
        target.AreMinMaxValid        = source.AreMinMaxValid,
        target.MinAllowedValue       = source.MinAllowedValue,
        target.MaxAllowedValue       = source.MaxAllowedValue,
        target.TreeLevel             = source.TreeLevel,
        target.TreeHierarchy         = source.TreeHierarchy,
        target.TreeParent            = source.TreeParent,
        target.ViewOrder             = source.ViewOrder,
        target.RegisterType          = source.RegisterType,
        target.RegisterValueType     = source.RegisterValueType,
        target.TransmissionPriority  = source.TransmissionPriority,
        target.AddHistory            = source.AddHistory,
        target.ExternalName1         = source.ExternalName1,
        target.ExternalName2         = source.ExternalName2,
        target.PartitionWeek         = dbo.fn_GetPartitionWeek(GETDATE())

    -- Nouvelle ligne → INSERT
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            MachineRegisterId,
            MachineId,
            RegisterName,
            RegisterDescription,
            MachineDataType,
            RegisterDomain,
            IsNodeRegister,
            NodeIndex,
            RegisterAccess,
            VisibleForCustomer,
            Unit,
            DecimalCount,
            IsArray,
            ArraySize,
            DefaultGraphType,
            PresentationScaling,
            PresentationScale,
            PresentationOffset,
            AreMinMaxValid,
            MinAllowedValue,
            MaxAllowedValue,
            TreeLevel,
            TreeHierarchy,
            TreeParent,
            ViewOrder,
            RegisterType,
            RegisterValueType,
            TransmissionPriority,
            AddHistory,
            ExternalName1,
            ExternalName2,
            PartitionWeek
        )
        VALUES (
            source.MachineRegisterId,
            source.MachineId,
            source.RegisterName,
            source.RegisterDescription,
            source.MachineDataType,
            source.RegisterDomain,
            source.IsNodeRegister,
            source.NodeIndex,
            source.RegisterAccess,
            source.VisibleForCustomer,
            source.Unit,
            source.DecimalCount,
            source.IsArray,
            source.ArraySize,
            source.DefaultGraphType,
            source.PresentationScaling,
            source.PresentationScale,
            source.PresentationOffset,
            source.AreMinMaxValid,
            source.MinAllowedValue,
            source.MaxAllowedValue,
            source.TreeLevel,
            source.TreeHierarchy,
            source.TreeParent,
            source.ViewOrder,
            source.RegisterType,
            source.RegisterValueType,
            source.TransmissionPriority,
            source.AddHistory,
            source.ExternalName1,
            source.ExternalName2,
            dbo.fn_GetPartitionWeek(GETDATE())  -- ← pas de date de modif → date du jour
        )

    WHEN NOT MATCHED BY SOURCE THEN DELETE;
    ';

    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT '[OK] Sync MachineRegisterDefinition terminé.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] Sync — ' + ERROR_MESSAGE();
        THROW;
    END CATCH

    -- --------------------------------------------------------
    -- ÉTAPE 2 : Archivage par SWITCH
    -- --------------------------------------------------------
    IF @RunArchive = 1
    BEGIN
        EXEC dbo.usp_Archive_Switch @ArchiveAfterDays = 7;
    END
END;
GO

-- Exécution
EXEC dbo.usp_Sync_MachineRegisterDefinition;                 -- sync + archive
EXEC dbo.usp_Sync_MachineRegisterDefinition @RunArchive = 0; -- sync seulement