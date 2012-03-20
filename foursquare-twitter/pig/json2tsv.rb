#!/usr/bin/env ruby
`tar xf json.tar`
require './json'
while (line = $stdin.gets) != nil
  data = JSON.parse(line)
  if data['4sq'].nil? or data['twitter'].nil?
    next
  end
  fsq = data['4sq']
  tw = data['twitter']
  columns = [
    fsq['venue']['location']['lat'], 
    fsq['venue']['location']['lng'], 
    fsq['venue']['name'],
    tw['user']['screen_name'],
    tw['created_at'],
    tw['text'],
  ]
  puts columns.join("\t")
end
