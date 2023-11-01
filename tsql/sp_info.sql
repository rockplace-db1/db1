-- 
-- 17 Oct 2023 Updated, default values
-- 05 Oct 2023 Created
-- 
SELECT c.name
, c.value_in_use, c.value
, d.pvalue AS "Default value"
, c.is_dynamic, c.is_advanced
, c.description
FROM 
(VALUES (-100, 518, '1')  -- show advanced options
, (-99, 16384, '0')  -- Agent XPs
, (-59, 109, '0')  -- fill factor (%)
, (-49, 1127, '2049')  -- two digit year cutoff
, (-48, 1536, '65536')  -- max text repl size (B)
, (-39, 116, '1')  -- server trigger recursion
, (-38, 115, '')  -- nested triggers
, (-37, 16390, '0')  -- xp_cmdshell
, (-36, 16387, '1')  -- SMO and DMO XPs
, (-35, 16388, '0')  -- Ole Automation Procedures
, (-34, 1547, '0')  -- scan for startup procs
, (-2, 101, '0')  -- recovery interval (min)
, (-1, 1537, '0')  -- media retention
, (11, 1543, '0')  -- min server memory (MB)
, (12, 1544, '0')  -- max server memory (MB)
, (21, 1540, '1024')  -- min memory per query (KB)
, (31, 103, '0')  -- user connections
, (32, 1534, '0')  -- user options
, (41, 1517, '0')  -- priority boost
, (42, 503, '0')  -- max worker threads
, (43, 1538, '5')  -- cost threshold for parallelism
, (44, 1539, '?')  -- max degree of parallelism
, (51, 505, '')  -- network packet size (B)
, (61, 542, '0')  -- remote proc trans
, (62, 1576, '0')  -- remote admin connections
, (63, 1519, '600')  -- remote login timeout (s)
, (64, 1520, '600')  -- remote query timeout (s)
, (65, 117, '600')  -- remote access
, (71, 1555, '0')  -- transform noise words
, (72, 1557, '60')  -- PH timeout (s)
, (81, 1541, '-1')   -- query wait (s)
, (91, 1545, '0')  -- query governor cost limit
, (92, 1581, '0')  -- optimize for ad hoc workloads
) AS d (linenum, pnum, pvalue)  -- d(efault)
INNER JOIN sys.configurations c
ON d.pnum = c.configuration_id
ORDER BY d.linenum
