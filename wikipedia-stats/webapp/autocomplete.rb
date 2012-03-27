NAMES = {
  1 => "",
  2 => "10s",
  3 => "100s",
  4 => "thousands",
  5 => "10s of thousands",
  6 => "100s of thousands",
  7 => "millions",
  8 => "tens of millions"
}

class Autocomplete < Sinatra::Base
  use Rack::Cache,
    :verbose => true,
    :metastore => "memcached://127.0.0.1",
  :entitystore => "memcached://127.0.0.1"

  get "/" do
    q=params[:term].split(/\W/).map { |t| "term.start:#{t}" }.join(" AND ") 
    data = {
      :results => {
        :event => []
      }
    }
    Tire.search('wikipedia') { 
      query { string q, :analyzer => :simple } 
      sort { by :score, :desc } 
      size 10 
    }.results.each { |r| 
      data[:results][:event] << {
        :data => {
          :url => "",
          :subtitle => "*" * Math.log(r.score)
        },
        :term => "#{"* " * Math.log(r.score, 5)} #{r.term} (#{r.score})",
        :id => 1,
        :score => r.score
      }
    }
    content_type "application/javascript"
    expires 60
    params[:callback] + "(" + data.to_json + ")"
  end
end
