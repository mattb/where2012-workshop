SET default_parallel 10;
register ./PigStorageWithInputPath.jar;
DATA = LOAD 'wikipedia-stats/pagecounts-*.gz' USING PigStorageWithInputPath(' ') AS (lang, name, count:int, other, filename:chararray);
ENDATA = FILTER DATA BY lang=='en';
FEATURES = LOAD 'wikipedia-stats/features.txt' USING PigStorage(' ') AS (feature);

FEATURE_CO = COGROUP ENDATA BY name, FEATURES BY feature;
FEATURE_FILTERED = FILTER FEATURE_CO BY NOT IsEmpty(FEATURES) AND NOT IsEmpty(ENDATA);
FEATURE_DATA = FOREACH FEATURE_FILTERED GENERATE FLATTEN(ENDATA);

HOURDATA = FOREACH FEATURE_DATA GENERATE lang, name, count, ((int)REGEX_EXTRACT(filename, '.*pagecounts-[0-9]+-([0-9][0-9]).*', 1))/4 AS hour;
NAMES = GROUP HOURDATA BY (hour, name);
COUNTS = FOREACH NAMES GENERATE group.hour, group.name, SUM(HOURDATA.count) as c;
FCOUNT = FILTER COUNTS BY c > 500;
SORTED = ORDER FCOUNT BY hour, c DESC;
STORE SORTED INTO 'wikipedia-stats/features_by_time.gz' USING PigStorage('\t');
