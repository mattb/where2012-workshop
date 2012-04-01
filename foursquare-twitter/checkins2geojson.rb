require 'multi_json'
require 'time'

geo = { 
  "type" =>  "FeatureCollection",
  "features" => []
}
while !(line = gets).nil?
  data = line.chomp.split(/\t/)
  feature = {
    "type" => "feature",
    "geometry" => {
      "type" => "Point",
      "coordinates" => [data[2].to_f, data[1].to_f]
    },
    "properties" => {
      "timestamp" => Time.parse(data[5]).iso8601,
      "name" => data[6]
    }
  }
  geo["features"] << feature
end
geo["features"] = geo["features"].sort_by { |f| f['properties']['timestamp'] }
puts MultiJson.encode(geo)
