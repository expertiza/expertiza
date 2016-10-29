require 'rails_helper'

describe TeamsController do

    describe "POST #create" do
    context "with an assignment team" do
      it "increases count by 1" do	
        expect{create :assignment_team, assignment: @assignment}.to change(Team,:count).by(1)
      end

      it "redirects to the list page" do
      end
    end
    
    context "with a course team" do
      it "increases the count by 1" do
        expect{create :course_team, course: @course}.to change(Team,:count).by(1)
      end

    end


    context "with an assignment team " do
      it "deletes an assignment team" do
        @assignment = create(:assignment)
        @a_team = create(:assignment_team)

        expect{ @a_team.delete }.to change(Team, :count).by(-1)
      end
    end

    context "with a course team " do
      it "deletes a course team" do
        @course = create(:course)
        @c_team = create(:course_team)

        expect{ @c_team.delete }.to change(Team, :count).by(-1)
      end
    end
    

  end
end
