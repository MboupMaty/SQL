USE [Certiq];
GO

IF OBJECT_ID('dbo.usp_Archive_TruncatePartition', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Archive_TruncatePartition;
GO

CREATE PROCEDURE dbo.usp_Archive_TruncatePartition
    @PartitionNum INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL           NVARCHAR(MAX);
    DECLARE @RowsInserted  INT;

    PRINT '===========================================';
    PRINT ' DÉBUT ARCHIVAGE PAR INSERT + TRUNCATE ';
    PRINT ' Partition : ' + CAST(@PartitionNum AS VARCHAR(10));
    PRINT '===========================================';

    BEGIN TRY
        BEGIN TRAN;

        -- ====================================================
        -- MACHINE
        -- ====================================================

        PRINT '--- Archivage Machine ---';

        INSERT INTO Certiq_Archive.dbo.Machine_Archive
        SELECT *
        FROM dbo.Machine
        WHERE $PARTITION.pf_Weekly(EventDate) = @PartitionNum;

        SET @RowsInserted = @@ROWCOUNT;

        PRINT 'Rows copiées : ' + CAST(@RowsInserted AS VARCHAR(20));

        IF @RowsInserted > 0
        BEGIN
            SET @SQL = '
            TRUNCATE TABLE dbo.Machine
            WITH (PARTITIONS (' + CAST(@PartitionNum AS VARCHAR(10)) + '));
            ';

            EXEC(@SQL);

            PRINT '[OK] Partition supprimée : Machine';
        END
        ELSE
        BEGIN
            PRINT '[SKIP] Aucune donnée à archiver : Machine';
        END


        -- ====================================================
        -- MACHINE EVENT HISTORY
        -- ====================================================

        PRINT '--- Archivage MachineEventHistory ---';

        INSERT INTO Certiq_Archive.dbo.MachineEventHistory_Archive
        SELECT *
        FROM dbo.MachineEventHistory
        WHERE $PARTITION.pf_Weekly(EventDate) = @PartitionNum;

        SET @RowsInserted = @@ROWCOUNT;

        PRINT 'Rows copiées : ' + CAST(@RowsInserted AS VARCHAR(20));

        IF @RowsInserted > 0
        BEGIN
            SET @SQL = '
            TRUNCATE TABLE dbo.MachineEventHistory
            WITH (PARTITIONS (' + CAST(@PartitionNum AS VARCHAR(10)) + '));
            ';

            EXEC(@SQL);

            PRINT '[OK] Partition supprimée : MachineEventHistory';
        END
        ELSE
        BEGIN
            PRINT '[SKIP] Aucune donnée à archiver : MachineEventHistory';
        END


        -- ====================================================
        -- MACHINE REGISTER HISTORY
        -- ====================================================

        PRINT '--- Archivage MachineRegisterHistory ---';

        INSERT INTO Certiq_Archive.dbo.MachineRegisterHistory_Archive
        SELECT *
        FROM dbo.MachineRegisterHistory
        WHERE $PARTITION.pf_Weekly(EventDate) = @PartitionNum;

        SET @RowsInserted = @@ROWCOUNT;

        PRINT 'Rows copiées : ' + CAST(@RowsInserted AS VARCHAR(20));

        IF @RowsInserted > 0
        BEGIN
            SET @SQL = '
            TRUNCATE TABLE dbo.MachineRegisterHistory
            WITH (PARTITIONS (' + CAST(@PartitionNum AS VARCHAR(10)) + '));
            ';

            EXEC(@SQL);

            PRINT '[OK] Partition supprimée : MachineRegisterHistory';
        END
        ELSE
        BEGIN
            PRINT '[SKIP] Aucune donnée à archiver : MachineRegisterHistory';
        END


        COMMIT TRAN;

        PRINT '===========================================';
        PRINT ' ARCHIVAGE TERMINÉ AVEC SUCCÈS ';
        PRINT '===========================================';
    END TRY

    BEGIN CATCH

        ROLLBACK TRAN;

        PRINT '===========================================';
        PRINT ' ERREUR DURANT L''ARCHIVAGE ';
        PRINT '===========================================';

        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO