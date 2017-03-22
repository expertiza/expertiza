require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
	def setup
		@assignment = Assignment.new(name: "Test_Assignment", directory_path: "New_path")
	end
	test "valid check" do
		assert @assignment.valid?
	end
	
	test "Default value check for num_reviews_required" do
		assert @assignment.num_reviews_required == @assignment.num_reviews
	end
	
	test "valid entry for num_reviews_required" do
		@assignment.num_reviews_required = 5;
		assert @assignment.valid?
	end
end