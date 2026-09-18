SELECT
  TOP 100*

FROM 
  OPENROWSET(
    BULK '######',
    FORMAT = 'PARQUET'
  ) AS result1