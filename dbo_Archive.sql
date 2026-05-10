USE [Certiq_Archive]


IF OBJECT_ID('dbo.usp_Archive_Switch', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Archive_Switch;
GO

CREATE PROCEDURE dbo.usp_Archive_Switch
    @ArchiveAfterDays INT = 7
AS
BEGIN
    SET NOCOUNT ON;

    -- Numéro de partition à archiver
    -- = partition dont la semaine est > @ArchiveAfterDays jours
    DECLARE @DateCoupure    DATE = DATEADD(DAY, -@ArchiveAfterDays, CAST(GETDATE() AS DATE));
    DECLARE @PartitionNum   INT;
    DECLARE @SQL            NVARCHAR(MAX);

    -- Trouver le numéro de partition correspondant à la semaine à archiver
    SELECT @PartitionNum = $PARTITION.pf_Weekly(@DateCoupure);

    PRINT '===== ARCHIVAGE PAR SWITCH =====';
    PRINT 'Date coupure    : ' + CAST(@DateCoupure AS NVARCHAR(20));
    PRINT 'Numéro partition: ' + CAST(@PartitionNum AS NVARCHAR(10));

    -- --------------------------------------------------------
    -- SWITCH Machine → Machine_Archive
    -- --------------------------------------------------------
    BEGIN TRY
        SET @SQL = N'
        ALTER TABLE [dbo].[Machine]
            SWITCH PARTITION ' + CAST(@PartitionNum AS NVARCHAR(10)) + N'
            TO [dbo].[Machine_Archive];
        ';
        EXEC sp_executesql @SQL;
        PRINT '[OK] Machine — partition ' + CAST(@PartitionNum AS NVARCHAR(10)) + ' archivée.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] Machine — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- SWITCH MachineEventHistory → MachineEventHistory_Archive
    -- --------------------------------------------------------
    BEGIN TRY
        SET @SQL = N'
        ALTER TABLE [dbo].[MachineEventHistory]
            SWITCH PARTITION ' + CAST(@PartitionNum AS NVARCHAR(10)) + N'
            TO [dbo].[MachineEventHistory_Archive];
        ';
        EXEC sp_executesql @SQL;
        PRINT '[OK] MachineEventHistory — partition ' + CAST(@PartitionNum AS NVARCHAR(10)) + ' archivée.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] MachineEventHistory — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- SWITCH MachineRegisterHistory → MachineRegisterHistory_Archive
    -- --------------------------------------------------------
    BEGIN TRY
        SET @SQL = N'
        ALTER TABLE [dbo].[MachineRegisterHistory]
            SWITCH PARTITION ' + CAST(@PartitionNum AS NVARCHAR(10)) + N'
            TO [dbo].[MachineRegisterHistory_Archive];
        ';
        EXEC sp_executesql @SQL;
        PRINT '[OK] MachineRegisterHistory — partition ' + CAST(@PartitionNum AS NVARCHAR(10)) + ' archivée.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] MachineRegisterHistory — ' + ERROR_MESSAGE();
    END CATCH

    PRINT '===== FIN ARCHIVAGE =====';
END;
GO