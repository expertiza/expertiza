require File.dirname(__FILE__) + '/../test_helper'

class Interaction_weight_test < ActiveSupport::TestCase
  # To change this template use File | Settings | File Templates.
 fixtures :assignments

 # 101 add a new interaction_weight
  def test_add_interaction_weight
    interaction_weight = InteractionWeight.new
    interaction_weight.max_score = 15
    interaction_weight.weight = 15
    interaction_weight.assignment_id=assignments(:assignment0).id
    interaction_weight.save! # an exception is thrown if the user is invalid
   end

 # 102 add a new interaction_weight
  def test_add_interaction_weight_without_maxscore
    interaction_weight = InteractionWeight.new
    interaction_weight.weight = 15
    interaction_weight.assignment_id=assignments(:assignment0).id
    assert !interaction_weight.save # an exception is thrown if the user is invalid
    assert_equal 'Maximum score cant be blank', interaction_weight.errors.on(:max_score)
   end

 # 103 add a new interaction_weight
  def test_add_interaction_weight_without_weight
    interaction_weight = InteractionWeight.new
    interaction_weight.max_score = 15
    interaction_weight.assignment_id=assignments(:assignment0).id
    assert !interaction_weight.save # an exception is thrown if the user is invalid
    assert_equal 'Weight cant be blank', interaction_weight.errors.on(:weight)
  end
end