require 'rubygems'
require 'multi_json'
require 'cgi'
require 'zlib'

id = 0
for filename in Dir.glob("out/*gz")
  puts filename
  file = Zlib::GzipReader.open(filename)
  out = File.open(filename + ".json","w")

  line = file.gets
  while !line.nil?
    page, count = line.chomp.split(/\t/)
    page.gsub!(/_/," ")
    page = CGI.unescape(page)
    count = count.to_i
    data = {
      'id' => id,
      'term' => page,
      'score' => count
    }
    begin
      out.puts MultiJson.encode(data).tr("\n","")
    rescue
      # pass on UTF-8 errors
    end
    line = file.gets
    id += 1
  end
  out.close
end
