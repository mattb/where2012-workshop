require 'bundler'
Bundler.require
require 'tempfile'

CONFIG = Yajl::Parser.parse(open("../config.js").read)
EM.run do
  @@buffer = $stdout
  @@count = 0

  def object_parsed(obj)
    obj['entities']['urls'].map { |ent| ent['expanded_url'] }.grep(/4sq.com\//).each { |url|
      http = EventMachine::HttpRequest.new(url).get :redirects => 5
      http.callback {
        html = http.response.split(/\n/).grep(/options\['venue'\]/).first
        if !html.nil?
          json = html.slice(29,html.size).strip.gsub(/;$/,'')
          @@buffer.puts(Yajl::Encoder.encode({
            'twitter' => obj,
            '4sq' => Yajl::Parser.parse(json)
          }))
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
    :inactivity_timeout => 30)

  http.stream do |chunk|
    parse << chunk
  end
  http.errback do
    puts "HTTP error."
    EM.stop
  end


end
