-- --------------------------------------------------------
-- Machine  (partition sur ModifiedUtcTime)
-- --------------------------------------------------------


USE [Certiq]
GO


IF OBJECT_ID('dbo.Machine', 'U') IS NOT NULL
    DROP TABLE [dbo].[Machine];

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

    -- Clé de partition → début de semaine Mercredi → fin de semaine Mardi 
    PartitionWeek AS CAST(
        DATEADD(DAY,
            -((DATEPART(WEEKDAY, ModifiedUtcTime) + 4) % 7),
            CAST(ModifiedUtcTime AS DATE)
        ) AS DATE
    ) PERSISTED

) ON ps_Weekly(PartitionWeek);  -- ← table partitionnée
GO