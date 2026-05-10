USE [Certiq_Archive]
GO

IF OBJECT_ID('dbo.usp_Create_AllArchiveTables', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Create_AllArchiveTables;
GO

CREATE PROCEDURE dbo.usp_Create_AllArchiveTables
    @DropIfExists BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '===== CRÉATION DES TABLES ARCHIVE =====';

    -- --------------------------------------------------------
    -- TABLE 1 : Machine_Archive
    -- --------------------------------------------------------
    IF OBJECT_ID('dbo.Machine_Archive', 'U') IS NOT NULL AND @DropIfExists = 1
        DROP TABLE [dbo].[Machine_Archive];

    IF OBJECT_ID('dbo.Machine_Archive', 'U') IS NULL
    BEGIN
        CREATE TABLE [dbo].[Machine_Archive] (
            MachineId                     INT              NOT NULL,
            CompanyId                     INT              NULL,
            CreatedUtcTime                DATETIME         NULL,
            ModifiedUtcTime               DATETIME         NULL,
            MachineSerialNumber           NVARCHAR(255)    NULL,
            MachineOpId                   INT              NULL,
            FleetNumberId                 INT              NULL,
            MachineTypeId                 INT              NULL,
            IsCommunicationEnabled        BIT              NULL,
            CommunicationToken            NVARCHAR(255)    NULL,
            CommunicationTimeout          INT              NULL,
            Timezone                      NVARCHAR(100)    NULL,
            ContractId                    INT              NULL,
            ContractStartDate             DATETIME         NULL,
            ContractEndDate               DATETIME         NULL,
            PhoneNumber                   NVARCHAR(50)     NULL,
            DefaultWorkModel              INT              NULL,
            ManualDataEnteringEnabled     BIT              NULL,
            MachineModel                  NVARCHAR(255)    NULL,
            ComUnitType                   INT              NULL,
            MachineReportingType          INT              NULL,
            OperationalState              INT              NULL,
            Visible                       BIT              NULL,
            IsTemplate                    BIT              NULL,
            TreeLevel                     INT              NULL,
            TreeHierarchy                 NVARCHAR(255)    NULL,
            TreeParent                    INT              NULL,
            SiteInfo                      NVARCHAR(MAX)    NULL,
            Comments                      NVARCHAR(MAX)    NULL,
            MachineLoginEnabled           BIT              NULL,
            MachineLoginUsername          NVARCHAR(255)    NULL,
            MachineLoginPassword          NVARCHAR(255)    NULL,
            MachineLoginLanguageLocale    NVARCHAR(50)     NULL,
            ExpensesCurrency              NVARCHAR(10)     NULL,
            Guid                          UNIQUEIDENTIFIER NULL,
            GuidCreatedUtcTime            DATETIME         NULL,
            PublishEnabled                BIT              NULL,
            DataWarehouseId               INT              NULL,
            LicenceKey                    NVARCHAR(255)    NULL,
            LicenceActive                 BIT              NULL,
            LicenceActivationUtcTime      DATETIME         NULL,
            LicenceExpiryUtcTime          DATETIME         NULL,
            MachineUsrId                  INT              NULL,
            LifeCycleState                INT              NULL,
            LifeCycleStateModifiedUtcTime DATETIME         NULL,
            deleted_at                    DATETIME         NULL,
            PartitionWeek                 DATE             NULL,
            ArchivedAt                    DATETIME         NOT NULL DEFAULT GETDATE()
        ) ON [PRIMARY];
        PRINT '[OK] Table Machine_Archive créée.';
    END
    ELSE
        PRINT '[SKIP] Table Machine_Archive existe déjà.';

    -- --------------------------------------------------------
    -- TABLE 2 : MachineEventDefinition_Archive
    -- --------------------------------------------------------
    -- ← colonnes à ajouter

    -- --------------------------------------------------------
    -- TABLE 3 : MachineEventHistory_Archive
    -- --------------------------------------------------------
    -- ← colonnes à ajouter

    -- --------------------------------------------------------
    -- TABLE 4 : MachineRegisterDefinition_Archive
    -- --------------------------------------------------------
    -- ← colonnes à ajouter

    -- --------------------------------------------------------
    -- TABLE 5 : MachineRegisterHistory_Archive
    -- --------------------------------------------------------
    -- ← colonnes à ajouter

    PRINT '===== FIN CRÉATION TABLES ARCHIVE =====';
END;
GO

-- Exécution
EXEC dbo.usp_Create_AllArchiveTables;                    -- crée les tables manquantes
EXEC dbo.usp_Create_AllArchiveTables @DropIfExists = 1;  -- DROP + recrée tout