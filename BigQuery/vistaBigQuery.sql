--Create flights view for flights

CREATE OR REPLACE VIEW ds_flights.flights AS

SELECT
  FlightDate AS FL_DATE,
  Reporting_Airline AS UNIQUE_CARRIER,
  OriginAirportSeqID AS ORIGIN_AIRPORT_SEQ_ID,
  Origin AS ORIGIN,
  DestAirportSeqID AS DEST_AIRPORT_SEQ_ID,
  Dest AS DEST,
  CRSDepTime AS CRS_DEP_TIME,
  DepTime AS DEP_TIME,
  CAST(DepDelay AS FLOAT64) AS DEP_DELAY,
  CAST(TaxiOut AS FLOAT64) AS TAXI_OUT,
  WheelsOff AS WHEELS_OFF,
  WheelsOn AS WHEELS_ON,
  CAST(TaxiIn AS FLOAT64) AS TAXI_IN,
  CRSArrTime AS CRS_ARR_TIME,
  ArrTime AS ARR_TIME,
  CAST(ArrDelay AS FLOAT64) AS ARR_DELAY,
  IF(Cancelled = '1.00', True, False) AS CANCELLED,
  IF(Diverted = '1.00', True, False) AS DIVERTED,
  DISTANCE
FROM ds_flights.flights_raw;


--
SELECT 
  ORIGIN,
  COUNT(*) AS num_flights
FROM ds_flights.flights
GROUP BY ORIGIN
ORDER BY num_flights DESC
LIMIT 5

SELECT 
    COUNTIF(dep_delay < 15 AND arr_delay < 15) AS true_positives,
    COUNTIF(dep_delay < 15 AND arr_delay >= 15) AS false_positives,
    COUNTIF(dep_delay >= 15 AND arr_delay < 15) AS false_negatives,
    COUNTIF(dep_delay >= 15 AND arr_delay >= 15) AS true_negatives,
    COUNT(*) AS total
FROM dsongcp.flights
WHERE arr_delay IS NOT NULL AND dep_delay IS NOT NULL


DECLARE THRESH INT64;
SET THRESH = 15;
DECLARE THRESH INT64;
SET THRESH = 15;

SELECT 
    COUNTIF(dep_delay < THRESH AND arr_delay < 15) AS true_positives,
    COUNTIF(dep_delay < THRESH AND arr_delay >= 15) AS false_positives,
    COUNTIF(dep_delay >= THRESH AND arr_delay < 15) AS false_negatives,
    COUNTIF(dep_delay >= THRESH AND arr_delay >= 15) AS true_negatives,
    COUNT(*) AS total
FROM dsongcp.flights
WHERE arr_delay IS NOT NULL AND dep_delay IS NOT NULL

DECLARE THRESH INT64;
SELECT 
    THRESH,
    COUNTIF(dep_delay < THRESH AND arr_delay < 15) AS true_positives,
    COUNTIF(dep_delay < THRESH AND arr_delay >= 15) AS false_positives,
    COUNTIF(dep_delay >= THRESH AND arr_delay < 15) AS false_negatives,
    COUNTIF(dep_delay >= THRESH AND arr_delay >= 15) AS true_negatives,
    COUNT(*) AS total
FROM dsongcp.flights, UNNEST([5, 10, 11, 12, 13, 15, 20]) AS THRESH
WHERE arr_delay IS NOT NULL AND dep_delay IS NOT NULL
GROUP BY THRESH



WITH contingency_table AS (
 SELECT 
   THRESH,
   COUNTIF(dep_delay < THRESH AND arr_delay < 15) AS true_positives,
   COUNTIF(dep_delay < THRESH AND arr_delay >= 15) AS false_positives,
   COUNTIF(dep_delay >= THRESH AND arr_delay < 15) AS false_negatives,
   COUNTIF(dep_delay >= THRESH AND arr_delay >= 15) AS true_negatives,
   COUNT(*) AS total
 FROM dsongcp.flights, UNNEST([5, 10, 11, 12, 13, 15, 20]) AS THRESH
 WHERE arr_delay IS NOT NULL AND dep_delay IS NOT NULL
 GROUP BY THRESH
)

SELECT
   ROUND((true_positives + true_negatives)/total, 2) AS accuracy,
   ROUND(false_positives/(true_positives+false_positives), 2) AS fpr,
   ROUND(false_negatives/(false_negatives+true_negatives), 2) AS fnr,
   *
FROM contingency_table ORDER BY accuracy ASC


CASE WHEN
(ARR_DELAY < 15)
THEN
"ON TIME"
ELSE
"LATE"
END