require 'rubygems'
require 'multi_json'
require 'cgi'
require 'zlib'
require 'tire'

id = 0
Tire.index 'wikipedia' do
  delete
  create :mappings => {"document"=>{"properties"=>{"id"=>{"type"=>"string", "index"=>"not_analyzed", "include_in_all"=>false}, "score"=>{"type"=>"long"}, "term"=>{"type"=>"multi_field", "fields"=>{"sort"=>{"type"=>"string", "analyzer"=>"my_sort", "include_in_all"=>false}, "start"=>{"type"=>"string", "analyzer"=>"my_start", "include_in_all"=>false}}}}}}, :settings => {"index.analysis.filter.my_edge.side"=>"front", "index.analysis.filter.my_edge.max_gram"=>"10", "index.analysis.analyzer.my_sort.tokenizer"=>"keyword", "index.analysis.analyzer.my_sort.filter.0"=>"asciifolding", "index.analysis.analyzer.my_start.tokenizer"=>"whitespace", "index.analysis.analyzer.my_start.filter.0"=>"asciifolding", "index.analysis.filter.my_edge.type"=>"edgeNGram", "index.analysis.analyzer.my_sort.filter.1"=>"lowercase", "index.analysis.analyzer.my_start.filter.2"=>"my_edge", "index.analysis.analyzer.my_start.filter.1"=>"lowercase", "index.analysis.filter.my_edge.min_gram"=>"1"}
end
for filename in Dir.glob("out/*gz")
  puts filename
  file = Zlib::GzipReader.open(filename)

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
      Tire.index 'wikipedia' do
        store data
      end
    rescue
      # pass on UTF-8 errors
    end
    line = file.gets
    id += 1
  end
end
