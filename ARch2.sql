CREATE PROCEDURE dbo.usp_Archive_Switch
    @ArchiveAfterDays INT = 90
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateCoupure  DATE = DATEADD(DAY, -@ArchiveAfterDays, CAST(GETDATE() AS DATE));
    DECLARE @PartitionNum INT  = $PARTITION.pf_Weekly(@DateCoupure);

    DECLARE @CntSource    INT;
    DECLARE @CntArchive   INT;
    DECLARE @CntAvant     INT;

    IF @PartitionNum IS NULL OR @PartitionNum = 0
    BEGIN
        PRINT '[SKIP] Aucune partition à archiver.';
        RETURN;
    END

    PRINT '===== ARCHIVAGE AVEC VALIDATION =====';
    PRINT 'Date coupure     : ' + CAST(@DateCoupure  AS NVARCHAR(20));
    PRINT 'Partition ciblée : ' + CAST(@PartitionNum AS NVARCHAR(10));

    -- --------------------------------------------------------
    -- Machine
    -- --------------------------------------------------------
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Compter les lignes SOURCE à archiver
        SELECT @CntSource = COUNT(*)
        FROM [Certiq].[dbo].[Machine]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        -- 2. Compter ce qui existe déjà dans l'archive (évite doublons)
        SELECT @CntAvant = COUNT(*)
        FROM [Certiq_Archive].[dbo].[Machine_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        -- 3. INSERT
        INSERT INTO [Certiq_Archive].[dbo].[Machine_Archive]
        SELECT * FROM [Certiq].[dbo].[Machine]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        -- 4. Valider que tout est bien arrivé dans l'archive
        SELECT @CntArchive = COUNT(*)
        FROM [Certiq_Archive].[dbo].[Machine_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        IF @CntArchive <> (@CntAvant + @CntSource)
        BEGIN
            ROLLBACK;
            PRINT '[ERREUR] Machine — validation échouée. Attendu: '
                + CAST(@CntAvant + @CntSource AS NVARCHAR(10))
                + ' | Trouvé: ' + CAST(@CntArchive AS NVARCHAR(10));
            RETURN;
        END

        -- 5. DELETE seulement si validation OK
        DELETE FROM [Certiq].[dbo].[Machine]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        COMMIT;
        PRINT '[OK] Machine — ' + CAST(@CntSource AS NVARCHAR(10))
            + ' lignes archivées et supprimées.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT '[ERREUR] Machine — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- MachineEventHistory
    -- --------------------------------------------------------
    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @CntSource = COUNT(*)
        FROM [Certiq].[dbo].[MachineEventHistory]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        SELECT @CntAvant = COUNT(*)
        FROM [Certiq_Archive].[dbo].[MachineEventHistory_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        INSERT INTO [Certiq_Archive].[dbo].[MachineEventHistory_Archive]
        SELECT * FROM [Certiq].[dbo].[MachineEventHistory]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        SELECT @CntArchive = COUNT(*)
        FROM [Certiq_Archive].[dbo].[MachineEventHistory_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        IF @CntArchive <> (@CntAvant + @CntSource)
        BEGIN
            ROLLBACK;
            PRINT '[ERREUR] MachineEventHistory — validation échouée. Attendu: '
                + CAST(@CntAvant + @CntSource AS NVARCHAR(10))
                + ' | Trouvé: ' + CAST(@CntArchive AS NVARCHAR(10));
            RETURN;
        END

        DELETE FROM [Certiq].[dbo].[MachineEventHistory]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        COMMIT;
        PRINT '[OK] MachineEventHistory — ' + CAST(@CntSource AS NVARCHAR(10))
            + ' lignes archivées et supprimées.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT '[ERREUR] MachineEventHistory — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- MachineRegisterHistory
    -- --------------------------------------------------------
    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @CntSource = COUNT(*)
        FROM [Certiq].[dbo].[MachineRegisterHistory]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        SELECT @CntAvant = COUNT(*)
        FROM [Certiq_Archive].[dbo].[MachineRegisterHistory_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        INSERT INTO [Certiq_Archive].[dbo].[MachineRegisterHistory_Archive]
        SELECT * FROM [Certiq].[dbo].[MachineRegisterHistory]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        SELECT @CntArchive = COUNT(*)
        FROM [Certiq_Archive].[dbo].[MachineRegisterHistory_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        IF @CntArchive <> (@CntAvant + @CntSource)
        BEGIN
            ROLLBACK;
            PRINT '[ERREUR] MachineRegisterHistory — validation échouée. Attendu: '
                + CAST(@CntAvant + @CntSource AS NVARCHAR(10))
                + ' | Trouvé: ' + CAST(@CntArchive AS NVARCHAR(10));
            RETURN;
        END

        DELETE FROM [Certiq].[dbo].[MachineRegisterHistory]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        COMMIT;
        PRINT '[OK] MachineRegisterHistory — ' + CAST(@CntSource AS NVARCHAR(10))
            + ' lignes archivées et supprimées.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT '[ERREUR] MachineRegisterHistory — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- MachineEventDefinition
    -- --------------------------------------------------------
    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @CntSource = COUNT(*)
        FROM [Certiq].[dbo].[MachineEventDefinition]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        SELECT @CntAvant = COUNT(*)
        FROM [Certiq_Archive].[dbo].[MachineEventDefinition_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        INSERT INTO [Certiq_Archive].[dbo].[MachineEventDefinition_Archive]
        SELECT * FROM [Certiq].[dbo].[MachineEventDefinition]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        SELECT @CntArchive = COUNT(*)
        FROM [Certiq_Archive].[dbo].[MachineEventDefinition_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        IF @CntArchive <> (@CntAvant + @CntSource)
        BEGIN
            ROLLBACK;
            PRINT '[ERREUR] MachineEventDefinition — validation échouée. Attendu: '
                + CAST(@CntAvant + @CntSource AS NVARCHAR(10))
                + ' | Trouvé: ' + CAST(@CntArchive AS NVARCHAR(10));
            RETURN;
        END

        DELETE FROM [Certiq].[dbo].[MachineEventDefinition]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        COMMIT;
        PRINT '[OK] MachineEventDefinition — ' + CAST(@CntSource AS NVARCHAR(10))
            + ' lignes archivées et supprimées.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT '[ERREUR] MachineEventDefinition — ' + ERROR_MESSAGE();
    END CATCH

    -- --------------------------------------------------------
    -- MachineRegisterDefinition
    -- --------------------------------------------------------
    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @CntSource = COUNT(*)
        FROM [Certiq].[dbo].[MachineRegisterDefinition]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        SELECT @CntAvant = COUNT(*)
        FROM [Certiq_Archive].[dbo].[MachineRegisterDefinition_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        INSERT INTO [Certiq_Archive].[dbo].[MachineRegisterDefinition_Archive]
        SELECT * FROM [Certiq].[dbo].[MachineRegisterDefinition]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        SELECT @CntArchive = COUNT(*)
        FROM [Certiq_Archive].[dbo].[MachineRegisterDefinition_Archive]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        IF @CntArchive <> (@CntAvant + @CntSource)
        BEGIN
            ROLLBACK;
            PRINT '[ERREUR] MachineRegisterDefinition — validation échouée. Attendu: '
                + CAST(@CntAvant + @CntSource AS NVARCHAR(10))
                + ' | Trouvé: ' + CAST(@CntArchive AS NVARCHAR(10));
            RETURN;
        END

        DELETE FROM [Certiq].[dbo].[MachineRegisterDefinition]
        WHERE $PARTITION.pf_Weekly(CreatedDate) = @PartitionNum;

        COMMIT;
        PRINT '[OK] MachineRegisterDefinition — ' + CAST(@CntSource AS NVARCHAR(10))
            + ' lignes archivées et supprimées.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT '[ERREUR] MachineRegisterDefinition — ' + ERROR_MESSAGE();
    END CATCH

    PRINT '===== FIN ARCHIVAGE =====';
END;
GO