require File.dirname(__FILE__) + '/../test_helper'

class ReviewResponseMapTest < ActiveSupport::TestCase
	fixtures :response_maps, :questionnaires , :assignments, :responses, :assignment_questionnaires, :users, :participants, :teams

	test "method_export" do
		csv = Array.new()
		ReviewResponseMap.export(csv, 3, nil)
		assert_equal csv.count, 2		
	end

	test "method_get_metareview_response_maps" do
        	review_response_map_test = ReviewResponseMap.new
		review_response_map_test.id = 1
		assert_equal review_response_map_test.get_metareview_response_maps.count, 2
	end

	test "method_get_team_response_for_round" do
		@team = teams('Team_1')
		assert_equal ReviewResponseMap.get_team_responses_for_round(@team,2)[0].id, 1
	end

	test "method_final_versions_from_reviewer" do
		assert_equal ReviewResponseMap.final_versions_from_reviewer(1)[0], 3
	end

	
	test "method_import" do
		assert_difference 'ResponseMap.count' do
			review_response_map_test = ReviewResponseMap.import(['User1','User2'], 2, 1)
    		end
  	end

  	test "method_import_invalid_reviewee" do
    		assert_raise ImportError do
			review_response_map_test = ReviewResponseMap.import(['User3','User2'], 2, 1)
    		end
  	end

	test "method_import_invalid_reviewer" do
    		assert_raise ImportError do
			review_response_map_test = ReviewResponseMap.import(['User1','User3'], 2, 1)
    		end
  	end

  	test "method_import_invalid_assignment" do
    		assert_raise ImportError do
			review_response_map_test = ReviewResponseMap.import(['User1','User2'], 2, 4)
    		end
  	end

  	test "method_delete" do
		@response = responses(:Response_1);
		review_response_map_test = ReviewResponseMap.new
		review_response_map_test.id = 2
		assert_difference 'ResponseMap.count', -2 do
			review_response_map_test.delete(true)
    		end 
  	end

  	test "method_delete_no _force" do
    		review_response_map_test= ReviewResponseMap.new
    		review_response_map_test.id = 2
    		assert_difference 'ResponseMap.count', -2 do
			review_response_map_test.delete(false)
    		end 
  	end

  	test "method_show_feedback" do
    		@responses = responses(:Response_1)
    		review_response_map_test = ReviewResponseMap.new
    		assert_not review_response_map_test.show_feedback(@responses), nil
  	end

  	test "method_get_title" do
    		review_response_map_test = ReviewResponseMap.new
    		assert_equal review_response_map_test.get_title, "Review"
  	end

  	test "method_export_fields" do
    		fields_1 = ["contributor","reviewed by"]
    		fields_2 = ReviewResponseMap.export_fields(1)
    		assert_equal fields_1, fields_2
  	end

  	test "method_questionnaire" do
    		@assignment = assignments(:Assignment_1)
    		review_response_map_test = ReviewResponseMap.new
    		review_response_map_test.assignment = @assignment
    		assert_equal review_response_map_test.questionnaire(2).id, 1
  	end 


  	test "method_add_reviewer" do
    		review_response_map_test = ReviewResponseMap.add_reviewer(1,2,1)
    		assert review_response_map_test.save
  	end
end
