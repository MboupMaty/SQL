SELECT 
    p.partition_number,
    p.rows,
    prv.value AS limite
FROM sys.partitions p
JOIN sys.indexes i 
    ON p.object_id = i.object_id AND p.index_id = i.index_id
LEFT JOIN sys.partition_range_values prv 
    ON prv.function_id = (
        SELECT ps.function_id 
        FROM sys.partition_schemes ps
        JOIN sys.indexes i2 ON i2.data_space_id = ps.data_space_id
        WHERE i2.object_id = OBJECT_ID('ma_table') AND i2.index_id = 1
    )
    AND prv.boundary_id = p.partition_number
WHERE i.object_id = OBJECT_ID('ma_table')
  AND i.index_id = 1
ORDER BY p.partition_number;
