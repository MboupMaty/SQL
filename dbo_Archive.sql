USE [Certiq]    -- ← tables source ici
GO

IF OBJECT_ID('dbo.usp_Archive_Switch', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Archive_Switch;
GO

CREATE PROCEDURE dbo.usp_Archive_Switch
    @ArchiveAfterDays INT = 90    -- ← 3 mois par défaut
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateCoupure  DATE = DATEADD(DAY, -@ArchiveAfterDays, CAST(GETDATE() AS DATE));
    DECLARE @PartitionNum INT;
    DECLARE @SQL          NVARCHAR(MAX);

    -- Trouver le numéro de partition à archiver
    SELECT @PartitionNum = $PARTITION.pf_Weekly(@DateCoupure);  -- ← bon nom

    PRINT '===== ARCHIVAGE PAR SWITCH =====';
    PRINT 'Date coupure    : ' + CAST(@DateCoupure  AS NVARCHAR(20));
    PRINT 'Numéro partition: ' + CAST(@PartitionNum AS NVARCHAR(10));

    -- ⚠️ Vérification — si partition = 0 ou NULL → rien à archiver
    IF @PartitionNum IS NULL OR @PartitionNum = 0
    BEGIN
        PRINT '[SKIP] Aucune partition à archiver.';
        RETURN;
    END

    -- --------------------------------------------------------
    -- SWITCH Machine → Certiq_Archive.dbo.Machine_Archive
    -- --------------------------------------------------------
    BEGIN TRY
        SET @SQL = N'
        ALTER TABLE [Certiq].[dbo].[Machine]
            SWITCH PARTITION ' + CAST(@PartitionNum AS NVARCHAR(10)) + N'
            TO [Certiq_Archive].[dbo].[Machine_Archive];
        ';
        EXEC sp_executesql @SQL;
        PRINT '[OK] Machine — partition ' + CAST(@PartitionNum AS NVARCHAR(10)) + ' archivée.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] Machine — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- SWITCH MachineEventHistory → Certiq_Archive
    -- --------------------------------------------------------
    BEGIN TRY
        SET @SQL = N'
        ALTER TABLE [Certiq].[dbo].[MachineEventHistory]
            SWITCH PARTITION ' + CAST(@PartitionNum AS NVARCHAR(10)) + N'
            TO [Certiq_Archive].[dbo].[MachineEventHistory_Archive];
        ';
        EXEC sp_executesql @SQL;
        PRINT '[OK] MachineEventHistory — partition ' + CAST(@PartitionNum AS NVARCHAR(10)) + ' archivée.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] MachineEventHistory — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- SWITCH MachineRegisterHistory → Certiq_Archive
    -- --------------------------------------------------------
    BEGIN TRY
        SET @SQL = N'
        ALTER TABLE [Certiq].[dbo].[MachineRegisterHistory]
            SWITCH PARTITION ' + CAST(@PartitionNum AS NVARCHAR(10)) + N'
            TO [Certiq_Archive].[dbo].[MachineRegisterHistory_Archive];
        ';
        EXEC sp_executesql @SQL;
        PRINT '[OK] MachineRegisterHistory — partition ' + CAST(@PartitionNum AS NVARCHAR(10)) + ' archivée.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] MachineRegisterHistory — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- SWITCH MachineEventDefinition → Certiq_Archive
    -- --------------------------------------------------------
    BEGIN TRY
        SET @SQL = N'
        ALTER TABLE [Certiq].[dbo].[MachineEventDefinition]
            SWITCH PARTITION ' + CAST(@PartitionNum AS NVARCHAR(10)) + N'
            TO [Certiq_Archive].[dbo].[MachineEventDefinition_Archive];
        ';
        EXEC sp_executesql @SQL;
        PRINT '[OK] MachineEventDefinition — partition ' + CAST(@PartitionNum AS NVARCHAR(10)) + ' archivée.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] MachineEventDefinition — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- SWITCH MachineRegisterDefinition → Certiq_Archive
    -- --------------------------------------------------------
    BEGIN TRY
        SET @SQL = N'
        ALTER TABLE [Certiq].[dbo].[MachineRegisterDefinition]
            SWITCH PARTITION ' + CAST(@PartitionNum AS NVARCHAR(10)) + N'
            TO [Certiq_Archive].[dbo].[MachineRegisterDefinition_Archive];
        ';
        EXEC sp_executesql @SQL;
        PRINT '[OK] MachineRegisterDefinition — partition ' + CAST(@PartitionNum AS NVARCHAR(10)) + ' archivée.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] MachineRegisterDefinition — ' + ERROR_MESSAGE();
    END CATCH

    PRINT '===== FIN ARCHIVAGE =====';
END;
GO

-- Exécution
EXEC dbo.usp_Archive_Switch;                        -- 90 jours par défaut (3 mois)
EXEC dbo.usp_Archive_Switch @ArchiveAfterDays = 90; -- explicite