USE [Certiq]
GO

IF OBJECT_ID('dbo.usp_Create_AllTables', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Create_AllTables;
GO

CREATE PROCEDURE dbo.usp_Create_AllTables
    @DropIfExists BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '===== CRÉATION DES TABLES =====';

    -- --------------------------------------------------------
    -- TABLE 1 : Machine (partition sur ModifiedUtcTime)
    -- --------------------------------------------------------
    IF OBJECT_ID('dbo.Machine', 'U') IS NOT NULL AND @DropIfExists = 1
        DROP TABLE [dbo].[Machine];

    IF OBJECT_ID('dbo.Machine', 'U') IS NULL
    BEGIN
        CREATE TABLE [dbo].[Machine] (
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
            PartitionWeek AS CAST(
                DATEADD(DAY,
                    -((DATEPART(WEEKDAY, ModifiedUtcTime) + 4) % 7),
                    CAST(ModifiedUtcTime AS DATE)
                ) AS DATE
            ) PERSISTED
        ) ON ps_Weekly(PartitionWeek);
        PRINT '[OK] Table Machine créée.';
    END
    ELSE
        PRINT '[SKIP] Table Machine existe déjà.';

    -- --------------------------------------------------------
    -- TABLE 2 : MachineEventDefinition
    -- --------------------------------------------------------
    -- ← coller ici 
    -- --------------------------------------------------------
    -- TABLE 3 : MachineEventHistory
    -- --------------------------------------------------------
    -- ← coller ici les colonnes une fois que tu me les donnes

    -- --------------------------------------------------------
    -- TABLE 4 : MachineRegisterDefinition
    -- --------------------------------------------------------
    -- ← coller ici les colonnes une fois que tu me les donnes

    -- --------------------------------------------------------
    -- TABLE 5 : MachineRegisterHistory
    -- --------------------------------------------------------
    -- ← coller ici les colonnes une fois que tu me les donnes

    PRINT '===== FIN CRÉATION =====';
END;
GO

-- Exécution
EXEC dbo.usp_Create_AllTables;                    -- crée les tables manquantes
EXEC dbo.usp_Create_AllTables @DropIfExists = 1;  -- DROP + recrée tout