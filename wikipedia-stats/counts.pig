SET default_parallel 10;
register ./PigStorageWithInputPath.jar;
DATA = LOAD 's3://wikipedia-stats/*.gz' USING PigStorageWithInputPath(' ') AS (lang, name, count:int, other, filename:chararray);
ENDATA = FILTER DATA BY lang=='en';
FEATURES = LOAD 's3://wikipedia-stats/features.txt' USING PigStorage(' ') AS (feature);

FEATURE_CO = COGROUP ENDATA BY name, FEATURES BY feature;
FEATURE_FILTERED = FILTER FEATURE_CO BY NOT IsEmpty(FEATURES) AND NOT IsEmpty(ENDATA);
FEATURE_DATA = FOREACH FEATURE_FILTERED GENERATE FLATTEN(ENDATA);

NAMES = GROUP FEATURE_DATA BY name;
COUNTS = FOREACH NAMES GENERATE group, SUM(FEATURE_DATA.count) as c;
FCOUNT = FILTER COUNTS BY c > 500;
SORTED = ORDER FCOUNT BY c DESC;
STORE SORTED INTO 's3://wikipedia-stats/features_out.gz' USING PigStorage('\t');
