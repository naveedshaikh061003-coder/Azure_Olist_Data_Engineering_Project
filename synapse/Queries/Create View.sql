create schema gold

CREATE VIEW gold.final
AS
SELECT
  *

FROM 
  OPENROWSET(
    BULK '######',
    FORMAT = 'PARQUET'
  ) AS result1


  select * from gold.final