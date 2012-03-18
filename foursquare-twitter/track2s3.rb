require 'bundler'
Bundler.require
require 'tempfile'

CONFIG = Yajl::Parser.parse(open("../config.js").read)
EM.run do
  @@buffer = Tempfile.new('4sq')
  @@count = 0

  def object_parsed(obj)
    obj['entities']['urls'].map { |ent| ent['expanded_url'] }.grep(/4sq.com/).each { |url|
      http = EventMachine::HttpRequest.new(url).get :redirects => 5
      http.callback {
        html = http.response.split(/\n/).grep(/options\['venue'\]/).first
        if !html.nil?
          @@buffer.puts(Yajl::Encoder.encode({
            'twitter' => obj,
            '4sq' => Yajl::Parser.parse(html.slice(29,html.size).strip.gsub(/;$/,''))
          }))
          @@count += 1
          if @@count % 1000 == 0
            puts @@count
          end
          if @@count > 5
            filename = "#{Time.now.to_i}"
            puts "#{filename} uploading."

            @@buffer.rewind
            item = Happening::S3::Item.new('mattb-4sq', filename, :aws_access_key_id => CONFIG['aws_access_key_id'], :aws_secret_access_key => CONFIG['aws_secret_access_key'], :protocol => 'http')
            item.put(@@buffer.read) do |response|
              puts "#{filename} finished!"
            end
            @@buffer.close!
            @@buffer = Tempfile.new('4sq')
            @@count = 0
          end
        end
      }
    }
  end

  parse = Yajl::Parser.new
  parse.on_parse_complete = method(:object_parsed)

  user = CONFIG['twitter_username']
  password = CONFIG['twitter_password']
  keywords = '4sq'

  http = EventMachine::HttpRequest.new("https://stream.twitter.com/1/statuses/filter.json",{:port=>443}).post(
    :head =>{ 'Authorization' => [ user, password ] } , 
    :body =>{"track"=>keywords},
    :keepalive=>true,
    :timeout=>-1)

  http.stream do |chunk|
    parse << chunk
  end


end
