-- Query to display unique car names for which there exists another
-- offer with the same maximum speed but a lower cost.
-- Rows with NULL or zero values in name, speed or cost are ignored.

SELECT DISTINCT P1.name
FROM P AS P1
WHERE P1.name IS NOT NULL
  AND P1.name NOT IN ('', '0')
  AND P1.speed IS NOT NULL AND P1.speed <> 0
  AND P1.cost IS NOT NULL  AND P1.cost <> 0
  AND EXISTS (
      SELECT 1
      FROM P AS P2
      WHERE P2.id <> P1.id
        AND P2.speed = P1.speed
        AND P2.cost < P1.cost
        AND P2.name IS NOT NULL AND P2.name NOT IN ('', '0')
        AND P2.speed IS NOT NULL AND P2.speed <> 0
        AND P2.cost IS NOT NULL  AND P2.cost <> 0
  );
