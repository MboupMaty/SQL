USE [Certiq]
GO

IF OBJECT_ID('dbo.usp_Create_MachineRegisterHistory', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Create_MachineRegisterHistory;
GO

CREATE PROCEDURE dbo.usp_Create_MachineRegisterHistory
    @DropIfExists BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- --------------------------------------------------------
    -- DROP si demandé
    -- --------------------------------------------------------
    IF OBJECT_ID('dbo.MachineRegisterHistory', 'U') IS NOT NULL AND @DropIfExists = 1
    BEGIN
        DROP TABLE [dbo].[MachineRegisterHistory];
        PRINT '[DROP] Table MachineRegisterHistory supprimée.';
    END



    -- --------------------------------------------------------
    -- Création si elle n'existe pas
    -- --------------------------------------------------------
    IF OBJECT_ID('dbo.MachineRegisterHistory', 'U') IS NULL
    BEGIN
        CREATE TABLE [dbo].[MachineRegisterHistory] (
            MachineRegisterHistoryId  BIGINT       NOT NULL,
            MachineRegisterId         INT          NOT NULL,
            MachineId                 INT          NOT NULL,
            MachineEventHistoryId     BIGINT       NOT NULL,
            NodeIndex                 SMALLINT     NOT NULL,
            ArraySize                 SMALLINT     NOT NULL,
            Value                     SQL_VARIANT  NULL,
            UtcTime                   DATETIME     NOT NULL,
            Quality                   TINYINT      NOT NULL,
            Invalid                   BIT          NOT NULL,

            -- Clé de partition → début de semaine Mercredi → fin Mardi
            -- calculée automatiquement depuis UtcTime
            PartitionWeek AS CAST(
                DATEADD(DAY,
                    -((DATEPART(WEEKDAY, UtcTime) + 4) % 7),
                    CAST(UtcTime AS DATE)
                ) AS DATE
            ) PERSISTED

        ) ON ps_Weekly(PartitionWeek);

        PRINT '[OK] Table MachineRegisterHistory créée avec partitionnement ps_Weekly.';
    END
    ELSE
        PRINT '[SKIP] Table MachineRegisterHistory existe déjà.';

END;
GO

-- --------------------------------------------------------
-- Exécution
-- --------------------------------------------------------
EXEC dbo.usp_Create_MachineRegisterHistory;                   -- crée si manquante
EXEC dbo.usp_Create_MachineRegisterHistory @DropIfExists = 1; -- DROP + recrée