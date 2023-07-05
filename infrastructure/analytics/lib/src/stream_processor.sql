--Creates a temporary stream.
CREATE OR REPLACE STREAM "LOCATION_STREAM" (
    "client_id"                 varchar(20),
    "latitude"                 	DOUBLE,
    "longitude"        			DOUBLE,
    "ANOMALY_SCORE"             DOUBLE);

--Creates another stream for application output.	        
CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (
    "client_id"                 varchar(20),
    "latitude"                 	DOUBLE,
    "longitude"        			DOUBLE,
    "ANOMALY_SCORE"             DOUBLE);



--Creates another stream for application output.	        
CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM_GREATER_2" (
    "client_id"                 varchar(20),
    "latitude"                 	DOUBLE,
    "longitude"        			DOUBLE,
    "ANOMALY_SCORE"             DOUBLE);

-- Compute an anomaly score for each record in the input stream
-- using Random Cut Forest
CREATE OR REPLACE PUMP "STREAM_PUMP" AS 
INSERT INTO "LOCATION_STREAM"
SELECT STREAM "client_id", "latitude", "longitude", ANOMALY_SCORE 
FROM TABLE(
    RANDOM_CUT_FOREST(
        CURSOR(
            SELECT STREAM * FROM "SOURCE_SQL_STREAM_001"
            )
        )
    );

-- Sort records by descending anomaly score, insert into output stream
CREATE OR REPLACE PUMP "OUTPUT_PUMP" AS 
INSERT INTO "DESTINATION_SQL_STREAM"
SELECT STREAM * FROM "LOCATION_STREAM"
WHERE ANOMALY_SCORE > 2 
ORDER BY FLOOR("LOCATION_STREAM".ROWTIME TO SECOND), ANOMALY_SCORE DESC;



-- Sort records by descending anomaly score, insert into output stream
CREATE OR REPLACE PUMP "OUTPUT_PUMP" AS 
INSERT INTO "DESTINATION_SQL_STREAM_GREATER_2"
SELECT STREAM * FROM "LOCATION_STREAM"
WHERE ANOMALY_SCORE > 2 
ORDER BY FLOOR("LOCATION_STREAM".ROWTIME TO SECOND), ANOMALY_SCORE DESC;