-- Query to display unique car names for which there exists another
-- offer with the same maximum speed but a lower cost.
-- Assumes all rows have valid values.

SELECT DISTINCT P1.name
FROM P AS P1
WHERE EXISTS (
    SELECT 1
    FROM P AS P2
    WHERE P2.id <> P1.id
      AND P2.speed = P1.speed
      AND P2.cost < P1.cost
);
