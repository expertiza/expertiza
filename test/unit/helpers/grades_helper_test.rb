require 'test_helper'
require 'grades_helper'
require 'action_view/test_case'
class GradesHelperTest < ActionView::TestCase
  include GradesHelper
  def test_get_accordion
    assert_equal get_accordion_title(nil, "pol"), render(:partial=>'response/accordion',:locals =>{:is_first=>true, :title=>"pol"})
    assert_equal get_accordion_title("politics", "pol"), render(:partial=>'response/accordion',:locals =>{:is_first=>true, :title=>"pol"})
    assert_equal get_accordion_title("politics", "pol"), render(:partial=>'response/accordion',:locals =>{:is_first=>false, :title=>"pol"})
  end
end
