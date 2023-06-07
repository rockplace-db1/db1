--
-- Rockplace, internal use only
--

--select version() ;
select split_part(version(), ',', 1) ;

-- Read-only parameters
show data_checksums ;