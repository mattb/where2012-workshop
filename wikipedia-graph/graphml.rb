# for jruby with jung2
require 'rubygems'
require 'java'
require 'cgi'
require 'bundler'
Bundler.require
require 'jbundler'

java_import Java::edu.uci.ics.jung.algorithms.filters.VertexPredicateFilter
java_import Java::edu.uci.ics.jung.graph.DirectedSparseGraph
java_import Java::edu.uci.ics.jung.io.GraphMLWriter
java_import Java::org.apache.commons.collections15.Predicate

def url_to_id(url)
  if url.match(/.*\/([^\/]+)>$/)
    i = CGI.unescape($1)
    return i.gsub(/"/,'`').gsub(/&/,'and')
  else
    throw url
  end
end

G = DirectedSparseGraph.new

pred=Predicate.new
class << pred
  def evaluate(v)
    G.inDegree(v) > 5
  end
end

e = 0
while !(line=$stdin.gets).nil?
  line.chomp!
  s, p, o, dot = line.split(/ /)
  G.addEdge(e, url_to_id(s), url_to_id(o))
  e += 1
end
w = GraphMLWriter.new
filter = VertexPredicateFilter.new(pred)
w.save(filter.transform(G), java.io.FileWriter.new("out.graphml"))
