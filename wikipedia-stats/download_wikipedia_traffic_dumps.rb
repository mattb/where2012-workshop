require 'rubygems'
require 'em-http-request'
require 'happening'
require 'yajl'

CONFIG = Yajl::Parser.parse(open("../config.js").read)
in_flight = 0
uploading = 0
files = open("files").readlines.map { |f| f.chomp }
EventMachine.run {
  on_error = Proc.new {|response| puts "An error occured: #{response.response_header.status}"; EM.stop }
  EventMachine::PeriodicTimer.new(5) do
    if in_flight < 2 and files.size > 0
      in_flight += 1
      url = files.shift
      p "#{url} downloading."
      http = EventMachine::HttpRequest.new(url).get :head => { "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.21 (KHTML, like Gecko) Chrome/19.0.1042.0 Safari/535.21" }

      http.callback {
        p "#{url} downloaded, #{http.response.size} bytes, starting S3 upload."
        in_flight -= 1
        item = Happening::S3::Item.new('wikipedia-stats', URI.parse(url).path.split("/").last, :aws_access_key_id => CONFIG['aws_access_key_id'], :aws_secret_access_key => CONFIG['aws_secret_access_key'], :permissions => 'public-read', :protocol => "http")
        uploading += 1
        item.put(http.response, :on_error => on_error) do |r|
          puts "#{url} uploaded."
          uploading -= 1
        end
      }
    end
    if in_flight == 0 and uploading == 0
      puts "Done"
      EventMachine.stop
    end
    puts "#{in_flight} in flight, #{uploading} uploading."
  end
}
