load 'test/test_helper.rb'
require 'ffi/aspell'
require 'automated_metareview/degree_of_relevance'
require 'automated_metareview/text_preprocessing'
require 'automated_metareview/graph_generator'

load 'features/lib/Deg_rel_setup.rb'

Before ('@one') do
  set= Deg_rel_setup.new
  set.setup
end