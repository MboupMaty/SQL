USE [Certiq]
GO

IF OBJECT_ID('dbo.usp_Sync_MachineRegisterHistory', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Sync_MachineRegisterHistory;
GO

CREATE PROCEDURE dbo.usp_Sync_MachineRegisterHistory
    @DeltaDays  INT = 7
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateCoupure NVARCHAR(30) =
        CONVERT(NVARCHAR(30), DATEADD(DAY, -@DeltaDays, GETDATE()), 120);

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
    MERGE [Certiq].[dbo].[MachineRegisterHistory] AS target
    USING (
        SELECT
            MachineRegisterHistoryId,
            MachineRegisterId,
            MachineId,
            MachineEventHistoryId,
            NodeIndex,
            ArraySize,
            CAST(Value AS NVARCHAR(MAX)) AS Value,
            UtcTime,
            Quality,
            Invalid
        FROM OPENQUERY([LMQ-Certiq-01],
            ''SELECT
                MachineRegisterHistoryId,
                MachineRegisterId,
                MachineId,
                MachineEventHistoryId,
                NodeIndex,
                ArraySize,
                CONVERT(NVARCHAR(MAX), Value) AS Value,
                UtcTime,
                Quality,
                Invalid
              FROM promine_db.dbo.vw_MachineRegisterHistory
              WHERE UtcTime >= ''''' + @DateCoupure + ''''')
    ) AS source
    ON target.MachineRegisterHistoryId = source.MachineRegisterHistoryId

    WHEN MATCHED AND (
        target.MachineRegisterId     != source.MachineRegisterId     OR
        target.MachineId             != source.MachineId             OR
        target.MachineEventHistoryId != source.MachineEventHistoryId OR
        target.NodeIndex             != source.NodeIndex             OR
        target.ArraySize             != source.ArraySize             OR
        CAST(target.Value AS NVARCHAR(MAX)) != source.Value          OR
        target.Quality               != source.Quality               OR
        target.Invalid               != source.Invalid
    )
    THEN UPDATE SET
        target.MachineRegisterId        = source.MachineRegisterId,
        target.MachineId                = source.MachineId,
        target.MachineEventHistoryId    = source.MachineEventHistoryId,
        target.NodeIndex                = source.NodeIndex,
        target.ArraySize                = source.ArraySize,
        target.Value                    = CAST(source.Value AS SQL_VARIANT),
        target.UtcTime                  = source.UtcTime,
        target.Quality                  = source.Quality,
        target.Invalid                  = source.Invalid

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            MachineRegisterHistoryId,
            MachineRegisterId,
            MachineId,
            MachineEventHistoryId,
            NodeIndex,
            ArraySize,
            Value,
            UtcTime,
            Quality,
            Invalid
        )
        VALUES (
            source.MachineRegisterHistoryId,
            source.MachineRegisterId,
            source.MachineId,
            source.MachineEventHistoryId,
            source.NodeIndex,
            source.ArraySize,
            CAST(source.Value AS SQL_VARIANT),
            source.UtcTime,
            source.Quality,
            source.Invalid
        )

    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;
    ';

    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT '[OK] Sync MachineRegisterHistory terminé.';
    END TRY
    BEGIN CATCH
        PRINT '[ERREUR] ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- Exécution
EXEC dbo.usp_Sync_MachineRegisterHistory;           -- 7 jours par défaut
EXEC dbo.usp_Sync_MachineRegisterHistory @DeltaDays = 30;  -- 30 jours
EXEC dbo.usp_Sync_MachineRegisterHistory @DeltaDays = 3650; -- sync complète avec DELETE sécurisé