SELECT 
  u.ugyfel_pk as 'Azonosító',
  IIF(GROUPING(CONCAT(u.vezeteknev,' ',u.keresztnev)) = 1,'Összesen',CAST(CONCAT(u.vezeteknev,' ',u.keresztnev) as nvarchar(50))) as 'Név',
  SUM(i.fizetendo) AS 'Kifizetett összeg'
FROM Ugyfel u  
JOIN Idopont i ON u.ugyfel_pk = i.ugyfel_fk
WHERE i.statusz='completed'
GROUP BY ROLLUP (CONCAT(u.vezeteknev,' ',u.keresztnev), u.ugyfel_pk)
HAVING 
  (GROUPING(CONCAT(u.vezeteknev,' ',u.keresztnev)) = 0 AND GROUPING(u.ugyfel_pk) = 0)
  OR 
  (GROUPING(CONCAT(u.vezeteknev,' ',u.keresztnev)) = 1 AND GROUPING(u.ugyfel_pk) = 1);

SELECT 
  u.ugyfel_pk as 'Azonosító',
  CONCAT(u.vezeteknev, ' ', u.keresztnev) AS 'Név',
  COUNT(i.idopont_pk) AS 'Lemondások száma',
  DENSE_RANK() OVER (ORDER BY COUNT(i.idopont_pk) DESC) AS 'Rangsor'
FROM Ugyfel u
LEFT JOIN Idopont i 
  ON u.ugyfel_pk = i.ugyfel_fk AND i.statusz = 'cancelled'
GROUP BY u.ugyfel_pk, u.vezeteknev, u.keresztnev;


SELECT 
  CONCAT(D.keresztnev, ' ',D.vezeteknev) as 'Név',
  SUM(I.fizetendo) AS 'Bevétel',
  DENSE_RANK() OVER (ORDER BY SUM(I.fizetendo) DESC) AS 'Rangsor'
FROM Dolgozo D
JOIN Idopont I ON D.dolgozo_pk = I.dolgozo_fk
WHERE I.statusz = 'completed'
GROUP BY D.dolgozo_pk, CONCAT(D.keresztnev, ' ',D.vezeteknev);



SELECT 
  CASE GROUPING_ID(i.datum)
  WHEN 0 THEN CAST(i.datum as nvarchar(50))
  WHEN 1 THEN ''
  END as 'Dátum',
  CASE GROUPING_ID(i.datum,CONCAT(d.vezeteknev,' ', d.keresztnev))
  WHEN 0 then CAST(CONCAT(d.vezeteknev,' ', d.keresztnev) as nvarchar(50))
  WHEN 1 THEN 'Napi bevétel'
  WHEN 3 THEN 'Összesen'
  END as 'Név',
  SUM(i.fizetendo) AS 'Bevétel'
FROM Idopont i join Dolgozo d on i.dolgozo_fk=d.dolgozo_pk
WHERE i.statusz = 'completed'
GROUP BY ROLLUP (i.datum, CONCAT(d.vezeteknev,' ', d.keresztnev));


SELECT
  CONCAT(d.vezeteknev, ' ', d.keresztnev) AS 'Dolgozó neve',
  sz.szolgaltatas as 'Szolgáltatás',
  sz.ar as 'Ár',
  RANK() OVER (PARTITION BY d.dolgozo_pk ORDER BY sz.ar DESC) AS 'Rangsor'
FROM Szolgaltatas sz
JOIN Munkakor m ON sz.szolgaltatas_pk = m.szolgaltatas_fk
JOIN Dolgozo d ON m.dolgozo_fk = d.dolgozo_pk;



SELECT 
  CONCAT(d.vezeteknev, ' ', d.keresztnev) AS 'Név',
  (
    SELECT COUNT(*) 
    FROM Idopont i
    JOIN Ugyfel u ON i.ugyfel_fk = u.ugyfel_pk
    WHERE i.dolgozo_fk = d.dolgozo_pk
      AND DATEDIFF(year, u.szulido, GETDATE()) < 25
  ) AS 'Fiatal ügyfelek száma'
FROM Dolgozo d
ORDER BY 'Fiatal ügyfelek száma' desc;





