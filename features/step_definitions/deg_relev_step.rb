load 'test/test_helper.rb'
load 'features/lib/Deg_rel_setup.rb'

Given /^Instance of the class is created$/ do
  @inst=DegreeOfRelevance.new
end

When /^I compare (\d+) and "(\S+)"$/ do |qty,m_name|
  actual=qty
  #assumption @num_rev_vert=0
  if(m_name.equal? "compare_vertices")
  assert_equal(6,@inst.compare_vertices(@vertex_match,@pos_tagger, @review_vertices, @subm_vertices, @num_rev_vert, @num_sub_vert, @speller) )
=begin

  elsif(m_name=="compare_edges_non_syntax_diff")
    @inst.compare_vertices(@pos_tagger, @review_vertices, @subm_vertices, 0, @num_sub_vert, @speller)
    assert_equal(0, @inst.compare_edges_non_syntax_diff(@review_edges, @subm_edges, 0, @num_sub_edg))

=end
    step("It will return true")
    end
end

Then /^It will return true$/  do

end


When /^I check for (\d+) and compare_edges_non_syntax_diff$/ do |q|
  actual=q
#assumption @num_rev_vert=0
#assumption @num_rev_edg=0
  @inst.compare_vertices(@vertex_match,@pos_tagger, @review_vertices, @subm_vertices, 0, @num_sub_vert, @speller)
  assert_equal(0, @inst.compare_edges_non_syntax_diff(@review_edges, @subm_edges, 0, @num_sub_edg))
  step("It will return true")
end

When /^I check for (\d+) and compare_edges_syntax_diff$/ do |q|
  actual=q
#assumption @num_rev_vert=0
#assumption @num_rev_edg=0
  @inst.compare_vertices(@vertex_match,@pos_tagger, @review_vertices, @subm_vertices, 0, @num_sub_vert, @speller)
  assert(@inst.compare_edges_syntax_diff(@vertex_match,@review_edges, @subm_edges, 0, @num_sub_edg)<=3)
  step("It will return true")
end

When /^I check for (\d+) and compare_edges_diff_type$/ do |q|
  actual=q
  #assumption @num_rev_vert=0
  #assumption @num_rev_edg=0

  @inst.compare_vertices(@vertex_match,@pos_tagger, @review_vertices, @subm_vertices, 0, @num_sub_vert, @speller)
  assert(@inst.compare_edges_diff_types(@review_edges, @subm_edges, 0, @num_sub_edg)<=3)
  step("It will return true")
end

When /^I check for (\d+) and compare_SVO_edges$/ do |q|
  actual=q
  #assumption @num_rev_vert=0
  #assumption @num_rev_edg=0

  @inst.compare_vertices(@vertex_match,@pos_tagger, @review_vertices, @subm_vertices, 0, @num_sub_vert, @speller)
  assert_equal(0, @inst.compare_SVO_edges(@review_edges, @subm_edges, 0, @num_sub_edg))
  step("It will return true")
end

When /^I check for (\d+) and compare_SVO_diff_syntax$/ do |q|
  actual=q
  #assumption @num_rev_vert=0
  #assumption @num_rev_edg=0

  @inst.compare_vertices(@vertex_match,@pos_tagger, @review_vertices, @subm_vertices,0, @num_sub_vert, @speller)
  assert_equal(0, @inst.compare_SVO_diff_syntax(@review_edges, @subm_edges, 0, @num_sub_edg))
  step("It will return true")
end