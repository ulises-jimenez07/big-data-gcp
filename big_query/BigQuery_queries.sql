SELECT
  tripduration/60 as duration_trip_minutes
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
where tripduration is not null
LIMIT 200;
 
SELECT
  * except(stoptime,end_station_id)
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
where tripduration is not null
LIMIT 200;
 
 
with all_data as(
 
SELECT
  * except(stoptime,end_station_id)
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
where tripduration is not null
LIMIT 200)
select * from all_data where gender='male';
 
 
select count(*) from bigquery-public-data.new_york_citibike.citibike_trips;
 

 
select  gender, count(*) from bigquery-public-data.new_york_citibike.citibike_trips
group by gender;
 
 
 
select replace(name, ' at ', ' ')
from bigquery-public-data.san_francisco.bikeshare_stations
 
select split (replace(name, ' at ', ' '),' ')
from bigquery-public-data.san_francisco.bikeshare_stations
 
 
select installation_date,
extract(year from installation_date)
from bigquery-public-data.san_francisco.bikeshare_stations;

bq query \
 --use_legacy_sql=false \
 --destination_table partition_ds.crime_partition \
 --time_partitioning_field date \
 --time_partitioning_type MONTH \
 'Select * from `bigquery-public-data.chicago_crime.crime`'
 
 
 
 select * from `bigquery-public-data.chicago_crime.crime` 
where date='2006-02-14 04:15:00 UTC';


 
select * from `testup-gcp.partition_ds.crime_partition` 
where date='2006-02-14 04:15:00 UTC';

select *
from `testup-gcp.partition_ds.INFORMATION_SCHEMA.PARTITIONS`
where table_name='crime_partition';

 select * from `bigquery-public-data.chicago_crime.crime` 
where date='2006-02-14 04:15:00 UTC'
and primary_type='INTIMIDATION';


bq query \
 --use_legacy_sql=false \
 --clustering_fields primary_type \
 --destination_table partition_ds.crime_partition_cluster \
 --time_partitioning_field date \
 --time_partitioning_type MONTH \
 'Select * from `bigquery-public-data.chicago_crime.crime`'
 