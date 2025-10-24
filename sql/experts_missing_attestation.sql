-- List experts missing an attestation date.
-- Returns expert_id along with name components; name fields may be NULL when no details exist.
SELECT DISTINCT
       es.expert_id,
       e.family_name,
       e.name,
       e.middle_name
FROM r_expert_specialization AS es
LEFT JOIN r_expert AS e ON e.id = es.expert_id
WHERE es.attestation_date IS NULL;
