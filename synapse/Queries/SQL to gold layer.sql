IF NOT EXISTS (
    SELECT 1
    FROM sys.external_file_formats
    WHERE name = 'extfileformat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT extfileformat
    WITH (
        FORMAT_TYPE = PARQUET,
        DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
    );
END;


IF NOT EXISTS (
    SELECT 1
    FROM sys.external_data_sources
    WHERE name = 'goldlayer'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE goldlayer
    WITH (
        LOCATION = '#####',
        CREDENTIAL = ###
    );
END;


CREATE EXTERNAL TABLE gold.finaltable
WITH (
    LOCATION = 'Serving',
    DATA_SOURCE = goldlayer,
    FILE_FORMAT = extfileformat
) AS
SELECT *
FROM gold.final2;