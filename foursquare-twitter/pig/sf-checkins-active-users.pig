DEFINE json2tsv `json2tsv.rb` SHIP('/home/hadoop/pig/json2tsv.rb','/home/hadoop/pig/json.tar');
A = LOAD 's3://mattb-4sq';
B = STREAM A THROUGH json2tsv AS (lat:float, lng:float, venue, nick, created_at, tweet);
SF = FILTER B BY lat > 37.604031 AND lat < 37.832371 AND lng > -123.013657 AND lng < -122.355301;
PEOPLE = GROUP SF BY nick;
PEOPLE_COUNTED = FOREACH PEOPLE GENERATE COUNT(SF) AS c, group, SF;
ACTIVE = FILTER PEOPLE_COUNTED BY c >= 5;
STORE ACTIVE INTO 's3://mattb-4sq/active-sf';
