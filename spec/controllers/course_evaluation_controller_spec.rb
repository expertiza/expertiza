require 'rails_helper'

describe CourseEvaluationController  do
  let (:course_evaluation_controller) { CourseEvaluationController.new }
  describe '#create_response_map' do
    it 'creates response map' do
      allow(course_evaluation_controller).to receive(:current_user_id?)
      allow(course_evaluation_controller).to receive(:parent_id?)
      @res_map=ResponseMap.new(reviewed_object_id: params[:parent_id], reviewee_id: params[:parent_id], reviewer_id:session[:user].id, type: @type )
      @res_map.save!
      expect(response).to redirect_to(controller: "response" , action: "new" , id: @res_map.id, return: @res_map.type)
    end
  end
end
