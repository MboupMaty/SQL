USE [Certiq]
GO

IF OBJECT_ID('dbo.usp_Sync_Machine', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Sync_Machine;
GO

CREATE PROCEDURE dbo.usp_Sync_Machine
    @DeltaDays      INT = 7,
    @RunArchive     BIT = 1     -- lancer l'archivage après le sync ?
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateCoupure NVARCHAR(30) =
        CONVERT(NVARCHAR(30), DATEADD(DAY, -@DeltaDays, GETDATE()), 120);

    DECLARE @SQL NVARCHAR(MAX);

    -- --------------------------------------------------------
    -- ÉTAPE 1 : MERGE — sync depuis le serveur lié
    -- --------------------------------------------------------
    SET @SQL = N'
    MERGE [Certiq].[dbo].[Machine] AS target
    USING (
        SELECT *
        FROM OPENQUERY([LMQ-Certiq-01],
            ''SELECT
                MachineId,
                CompanyId,
                CreatedUtcTime,
                ModifiedUtcTime,
                MachineSerialNumber,
                MachineOpId,
                FleetNumberId,
                MachineTypeId,
                IsCommunicationEnabled,
                CommunicationToken,
                CommunicationTimeout,
                Timezone,
                ContractId,
                ContractStartDate,
                ContractEndDate,
                PhoneNumber,
                DefaultWorkModel,
                ManualDataEnteringEnabled,
                MachineModel,
                ComUnitType,
                MachineReportingType,
                OperationalState,
                Visible,
                IsTemplate,
                TreeLevel,
                TreeHierarchy,
                TreeParent,
                SiteInfo,
                Comments,
                MachineLoginEnabled,
                MachineLoginUsername,
                MachineLoginPassword,
                MachineLoginLanguageLocale,
                ExpensesCurrency,
                Guid,
                GuidCreatedUtcTime,
                PublishEnabled,
                DataWarehouseId,
                LicenceKey,
                LicenceActive,
                LicenceActivationUtcTime,
                LicenceExpiryUtcTime,
                MachineUsrId,
                LifeCycleState,
                LifeCycleStateModifiedUtcTime,
                deleted_at
              FROM promine_db.dbo.vw_Machine
              WHERE ModifiedUtcTime >= ''''' + @DateCoupure + ''''')
    ) AS source
    ON target.MachineId = source.MachineId

    -- Ligne modifiée → UPDATE
    WHEN MATCHED AND source.ModifiedUtcTime > target.ModifiedUtcTime
    THEN UPDATE SET
        target.CompanyId                     = source.CompanyId,
        target.CreatedUtcTime                = source.CreatedUtcTime,
        target.ModifiedUtcTime               = source.ModifiedUtcTime,
        target.MachineSerialNumber           = source.MachineSerialNumber,
        target.MachineOpId                   = source.MachineOpId,
        target.FleetNumberId                 = source.FleetNumberId,
        target.MachineTypeId                 = source.MachineTypeId,
        target.IsCommunicationEnabled        = source.IsCommunicationEnabled,
        target.CommunicationToken            = source.CommunicationToken,
        target.CommunicationTimeout          = source.CommunicationTimeout,
        target.Timezone                      = source.Timezone,
        target.ContractId                    = source.ContractId,
        target.ContractStartDate             = source.ContractStartDate,
        target.ContractEndDate               = source.ContractEndDate,
        target.PhoneNumber                   = source.PhoneNumber,
        target.DefaultWorkModel              = source.DefaultWorkModel,
        target.ManualDataEnteringEnabled     = source.ManualDataEnteringEnabled,
        target.MachineModel                  = source.MachineModel,
        target.ComUnitType                   = source.ComUnitType,
        target.MachineReportingType          = source.MachineReportingType,
        target.OperationalState              = source.OperationalState,
        target.Visible                       = source.Visible,
        target.IsTemplate                    = source.IsTemplate,
        target.TreeLevel                     = source.TreeLevel,
        target.TreeHierarchy                 = source.TreeHierarchy,
        target.TreeParent                    = source.TreeParent,
        target.SiteInfo                      = source.SiteInfo,
        target.Comments                      = source.Comments,
        target.MachineLoginEnabled           = source.MachineLoginEnabled,
        target.MachineLoginUsername          = source.MachineLoginUsername,
        target.MachineLoginPassword          = source.MachineLoginPassword,
        target.MachineLoginLanguageLocale    = source.MachineLoginLanguageLocale,
        target.ExpensesCurrency              = source.ExpensesCurrency,
        target.Guid                          = source.Guid,
        target.GuidCreatedUtcTime            = source.GuidCreatedUtcTime,
        target.PublishEnabled                = source.PublishEnabled,
        target.DataWarehouseId               = source.DataWarehouseId,
        target.LicenceKey                    = source.LicenceKey,
        target.LicenceActive                 = source.LicenceActive,
        target.LicenceActivationUtcTime      = source.LicenceActivationUtcTime,
        target.LicenceExpiryUtcTime          = source.LicenceExpiryUtcTime,
        target.MachineUsrId                  = source.MachineUsrId,
        target.LifeCycleState                = source.LifeCycleState,
        target.LifeCycleStateModifiedUtcTime = source.LifeCycleStateModifiedUtcTime,
        target.deleted_at                    = source.deleted_at

    -- Nouvelle ligne → INSERT
    -- PartitionWeek calculée automatiquement par SQL Server
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            MachineId, CompanyId, CreatedUtcTime, ModifiedUtcTime,
            MachineSerialNumber, MachineOpId, FleetNumberId, MachineTypeId,
            IsCommunicationEnabled, CommunicationToken, CommunicationTimeout,
            Timezone, ContractId, ContractStartDate, ContractEndDate,
            PhoneNumber, DefaultWorkModel, ManualDataEnteringEnabled,
            MachineModel, ComUnitType, MachineReportingType, OperationalState,
            Visible, IsTemplate, TreeLevel, TreeHierarchy, TreeParent,
            SiteInfo, Comments, MachineLoginEnabled, MachineLoginUsername,
            MachineLoginPassword, MachineLoginLanguageLocale, ExpensesCurrency,
            Guid, GuidCreatedUtcTime, PublishEnabled, DataWarehouseId,
            LicenceKey, LicenceActive, LicenceActivationUtcTime,
            LicenceExpiryUtcTime, MachineUsrId, LifeCycleState,
            LifeCycleStateModifiedUtcTime, deleted_at
        )
        VALUES (
            source.MachineId, source.CompanyId, source.CreatedUtcTime,
            source.ModifiedUtcTime, source.MachineSerialNumber, source.MachineOpId,
            source.FleetNumberId, source.MachineTypeId, source.IsCommunicationEnabled,
            source.CommunicationToken, source.CommunicationTimeout, source.Timezone,
            source.ContractId, source.ContractStartDate, source.ContractEndDate,
            source.PhoneNumber, source.DefaultWorkModel, source.ManualDataEnteringEnabled,
            source.MachineModel, source.ComUnitType, source.MachineReportingType,
            source.OperationalState, source.Visible, source.IsTemplate,
            source.TreeLevel, source.TreeHierarchy, source.TreeParent,
            source.SiteInfo, source.Comments, source.MachineLoginEnabled,
            source.MachineLoginUsername, source.MachineLoginPassword,
            source.MachineLoginLanguageLocale, source.ExpensesCurrency,
            source.Guid, source.GuidCreatedUtcTime, source.PublishEnabled,
            source.DataWarehouseId, source.LicenceKey, source.LicenceActive,
            source.LicenceActivationUtcTime, source.LicenceExpiryUtcTime,
            source.MachineUsrId, source.LifeCycleState,
            source.LifeCycleStateModifiedUtcTime, source.deleted_at
        );

    ';

    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT '[OK] Sync Machine terminé.';
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
EXEC dbo.usp_Sync_Machine;                          -- sync + archive (défaut)
EXEC dbo.usp_Sync_Machine @RunArchive = 0;          -- sync seulement
EXEC dbo.usp_Sync_Machine @DeltaDays = 30;          -- 30 jours + archive