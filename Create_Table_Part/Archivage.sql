USE [Optimine]
GO
/****** Object:  StoredProcedure [dbo].[optimine_Archivage]    Script Date: 6/22/2026 11:49:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER  PROCEDURE [dbo].[optimine_Archivage] 
	-- Add the parameters for the stored procedure here
	@TableName SYSNAME,
    @ArchiveTable SYSNAME,
    @PartitionFunction SYSNAME,
    @PartitionScheme SYSNAME ,
    @PartitionColumn SYSNAME,
    @KeepPartitions INT = 8
AS
BEGIN
	---------------------------------------------------------
-- CONFIGURATION
---------------------------------------------------------
DECLARE @ObjectID INT = OBJECT_ID(@TableName);
DECLARE @PartitionCount INT;

---------------------------------------------------------
-- Vérifier le nombre total de partitions
---------------------------------------------------------
SELECT @PartitionCount = COUNT(*)
FROM sys.partitions
WHERE object_id = @ObjectID
  AND index_id IN (0,1);

IF @PartitionCount <= @KeepPartitions
BEGIN
    PRINT 'Aucune partition à archiver.';
    RETURN;
END;

DECLARE @PartitionsToMove INT = @PartitionCount - @KeepPartitions;
PRINT CONCAT('Nombre de partitions à déplacer : ', @PartitionsToMove);

---------------------------------------------------------
-- Identifier les partitions les plus vieilles
---------------------------------------------------------
DECLARE @Partitions TABLE (
    partition_number INT PRIMARY KEY,
    BoundaryValue SQL_VARIANT
);

INSERT INTO @Partitions (partition_number, BoundaryValue)
SELECT TOP (@PartitionsToMove)
    p.partition_number,
    prv.value
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
LEFT JOIN sys.partition_range_values prv 
    ON pf.function_id = prv.function_id 
    AND prv.boundary_id = p.partition_number - 1
WHERE p.object_id = @ObjectID AND p.index_id = 1
ORDER BY prv.value;

---------------------------------------------------------
-- Boucle sur les partitions à archiver
---------------------------------------------------------
DECLARE @Partition INT;

DECLARE part_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT partition_number FROM @Partitions ORDER BY partition_number;

OPEN part_cursor;
FETCH NEXT FROM part_cursor INTO @Partition;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '---------------------------------------------';
    PRINT CONCAT('Traitement de la partition ', @Partition);

    BEGIN TRY

        ---------------------------------------------------------
        -- Copier vers DB2 (archive)
        ---------------------------------------------------------
        DECLARE @RowsCopied INT;

        --INSERT INTO @ArchiveTable
        --SELECT *
        --FROM @TableName
        --WHERE $PARTITION.@PartitionScheme(@PartitionColumn) = @Partition;

        DECLARE @sqlInsert NVARCHAR(MAX) = '
            INSERT INTO ' + @ArchiveTable + '
            SELECT *,
            GETDATE() AS ArchivedAt   
            FROM ' + @TableName + '
            WHERE $PARTITION.' + @PartitionFunction + '(' + QUOTENAME(@PartitionColumn) + ') = ' + CAST(@Partition AS VARCHAR(10)) + ';
        ';

        EXEC sys.sp_executesql @sqlInsert;

        SET @RowsCopied = @@ROWCOUNT;
        PRINT CONCAT('Lignes copiées : ', @RowsCopied);

        IF @RowsCopied = 0
        BEGIN
            PRINT CONCAT('Partition ', @Partition, ' vide. On passe à la suivante.');
            FETCH NEXT FROM part_cursor INTO @Partition;
            CONTINUE;
        END;

        ---------------------------------------------------------
        -- Truncate de la partition
        ---------------------------------------------------------
        PRINT 'Truncate de la partition ...';

        DECLARE @sqlSwitch NVARCHAR(MAX) = '
            TRUNCATE TABLE ' + @TableName + '
            WITH  (PARTITIONS (' + CAST(@Partition AS VARCHAR(10)) + '));
        ';
        EXEC sys.sp_executesql @sqlSwitch;
        PRINT CONCAT('Partition ', @Partition, ' vidée avec succès.');
       

    END TRY
    BEGIN CATCH
        PRINT 'Erreur détectée, arrêt du traitement.';
        PRINT ERROR_MESSAGE();
        CLOSE part_cursor;
        DEALLOCATE part_cursor;
        RETURN;
    END CATCH;

    FETCH NEXT FROM part_cursor INTO @Partition;
END;

CLOSE part_cursor;
DEALLOCATE part_cursor;

PRINT 'Archivage terminé.';
END
