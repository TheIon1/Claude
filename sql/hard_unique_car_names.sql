-- Query to display unique car names where another offer exists with the
-- same maximum speed but a lower cost. The P table stores only ids
-- for name, speed and cost values. Values in those lookup tables may be
-- empty, differ only by case or contain leading zeros.

SELECT DISTINCT LOWER(n1.name) AS car_name
FROM P AS P1
JOIN CarName   AS n1 ON P1.name  = n1.id
JOIN MaxSpeed  AS s1 ON P1.speed = s1.id
JOIN CarCost   AS c1 ON P1.cost  = c1.id
WHERE n1.name  IS NOT NULL AND n1.name  NOT IN ('', '0')
  AND s1.speed IS NOT NULL AND s1.speed NOT IN ('', '0')
  AND c1.cost  IS NOT NULL AND c1.cost  NOT IN ('', '0')
  AND EXISTS (
      SELECT 1
      FROM P AS P2
      JOIN CarName  AS n2 ON P2.name  = n2.id
      JOIN MaxSpeed AS s2 ON P2.speed = s2.id
      JOIN CarCost  AS c2 ON P2.cost  = c2.id
      WHERE P2.id <> P1.id
        AND n2.name  IS NOT NULL AND n2.name  NOT IN ('', '0')
        AND s2.speed IS NOT NULL AND s2.speed NOT IN ('', '0')
        AND c2.cost  IS NOT NULL AND c2.cost  NOT IN ('', '0')
        AND CAST(s2.speed AS INTEGER) = CAST(s1.speed AS INTEGER)
        AND CAST(c2.cost  AS INTEGER) < CAST(c1.cost  AS INTEGER)
  );
