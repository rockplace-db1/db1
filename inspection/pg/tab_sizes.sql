--\set VC_DB_NAME 'pgbench'
--\set VC_DB_NAME 'imdb'
--\set VC_DB_NAME 'birthnames'
\set N_BINS 10

--\c :VC_DB_NAME
SELECT COUNT(relid) AS n_tables
FROM pg_stat_user_tables
\gset
--\echo :n_tables

WITH t AS
( SELECT pg_relation_size(relid, 'main') AS rel_size
  FROM pg_stat_user_tables
)
SELECT MAX(rel_size) AS n_max_size
, MIN(rel_size) AS n_min_size
, div(MAX(rel_size) - MIN(rel_size), :'N_BINS') AS n_bin_size
, (MAX(rel_size) - MIN(rel_size)) % :'N_BINS' AS n_remainder
FROM t
\gset
SELECT :n_tables AS n_tables
, :n_max_size AS n_max_size
, :n_min_size AS n_min_size
, :N_BINS AS n_bins
, :n_bin_size AS n_bin_size
, :n_remainder AS n_remainder
;
\echo ************************************************************
\echo * Height balanced histogram with NTILE() function
\echo ************************************************************
WITH t AS
( SELECT relid
  , pg_relation_size(relid, 'main') AS rel_size
  FROM pg_stat_user_tables
)
,v AS
( SELECT relid
  , rel_size
  , NTILE(:N_BINS) OVER (ORDER BY rel_size) AS bin_num
  FROM t
)
SELECT v.bin_num
, MIN(v.rel_size)
, MAX(v.rel_size)
, COUNT(v.relid)
FROM v
GROUP BY v.bin_num
ORDER BY v.bin_num
;

\echo ************************************************************
\echo * Frequency histogram with function width_bucket()
\echo ************************************************************
--\pset fieldsep ','
--\pset format unaligned
WITH b1 AS
( SELECT generate_series(1, :N_BINS + 1) AS bin_num
)
, b2 AS
( SELECT b1.bin_num
  , :n_min_size + :n_bin_size::numeric * (b1.bin_num - 1) AS lower_bound
  , (:n_min_size + :n_bin_size::numeric * b1.bin_num) - 1 AS upper_bound
  FROM b1
)
, t AS
( SELECT relid
  , pg_relation_size(relid, 'main') AS rel_size
  FROM pg_stat_user_tables
)
, b3 AS
( SELECT width_bucket(rel_size, :n_min_size, :n_max_size, :N_BINS) AS bin_num
  , COUNT(relid) AS frequency
  FROM t
  GROUP BY bin_num
)
SELECT b2.bin_num
, b2.lower_bound
, b2.upper_bound
, COALESCE(b3.frequency, 0) AS frequency
FROM b2
LEFT OUTER JOIN b3
ON b2.bin_num = b3.bin_num
ORDER BY 1
;
--\pset fieldsep '|'
--\pset format aligned

