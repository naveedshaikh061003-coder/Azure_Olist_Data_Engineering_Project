CREATE VIEW gold.final2
AS 
SELECT
  *

FROM 
  OPENROWSET(
    BULK '#####',
    FORMAT = 'PARQUET'
  ) AS result

WHERE order_status= 'delivered'

SELECT * from gold.final2
