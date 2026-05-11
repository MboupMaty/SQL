-- Voir la distribution des données par partition

USE [Certiq]

Go

SELECT
    p.partition_number,
    prv.value           AS DebutSemaine,
    p.rows              AS NbLignes
FROM sys.partitions p
JOIN sys.indexes i
    ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps
    ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf
    ON pf.function_id = ps.function_id
LEFT JOIN sys.partition_range_values prv
    ON prv.function_id = pf.function_id
    AND prv.boundary_id = p.partition_number - 1
WHERE OBJECT_NAME(p.object_id) = 'Machine'
ORDER BY p.partition_number;

Go 