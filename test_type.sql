-- Voir les types exacts de la view côté source
SELECT
    c.name          AS colonne,
    t.name          AS type,
    c.max_length
FROM [LMQ-CERTIQ-01].[promine_db].sys.columns c
JOIN [LMQ-CERTIQ-01].[promine_db].sys.types   t ON t.user_type_id = c.user_type_id
JOIN [LMQ-CERTIQ-01].[promine_db].sys.objects o ON o.object_id   = c.object_id
WHERE o.name = 'vw_MachineRegisterHistory'
ORDER BY c.column_id;