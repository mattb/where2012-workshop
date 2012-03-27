require 'rubygems'
require 'java'
require 'cgi'
Dir.glob("lib/*").each { |j| require j }

def url_to_id(url)
  if url.match(/.*\/([^\/]+)>$/)
    i = CGI.unescape($1)
    return i.gsub(/"/,'`')
  else
    throw url
  end
end

counts = {}
f = open("parts")
while !(line=f.gets).nil?
  line.chomp!
  s, p, o, dot = line.split(/ /)
  counts[s] = counts.fetch(s,0) + 1
  counts[o] = counts.fetch(o,0) + 1
end
selected = {}
counts.select { |k,v| v > 50 }.each { |k,v|
  selected[k] = v
}
f = open("parts")
while !(line=f.gets).nil?
  s, p, o, dot = line.split(/ /)
  if selected.has_key?(s)
    puts line
  end
end
