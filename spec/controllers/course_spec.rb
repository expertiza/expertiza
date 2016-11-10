require 'rails_helper'

describe CourseController do
	describe '#add_ta' do
    it "is able to create mapping between TA and the course" do
      ta = build(User)
      ta.save
      course = build(Course)
      course.save
      taMapping = TaMapping.create(ta.id,course.id)
      expect(taMapping).to be_kind_of(TaMapping)
  		end
  	
 	it "displays error message if TA does not exist" do
    	ta = build(User)
      	ta.ta_id=nil
      	ta.save
    	expect(ta.nil?).to be true
  	end
	end

    describe '#remove_ta' do
    it "is able to delete TA from the course" do
      ta = build(User)
      taMapping = TaMapping.find(ta.id)
      taMapping.destroy
      expect(response).to redirect_to action: 'view_teaching_assistants'
  		end
    end
end