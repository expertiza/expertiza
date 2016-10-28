require 'rails_helper'

describe TeamsController do
  describe "POST #create" do
    context "with an assignment team" do
      it "increases count by 1" do	
        expect{create :assignment_team, assignment: @assignment}.to change(Team,:count).by(1)
      end
      it "saves in database" do
        assignment_team = create(:assignment_team)
        post :create, :team=>assignment_team
        
      end
      it "redirects to the list page" do
      end
    end
    
    context "with a course team" do
      it "increases the count by 1" do
        expect{create :course_team, course: @course}.to change(Team,:count).by(1)
      end
      it "saves the new team in the database" do
      end
      it "redirects to the new page" do
      end
    end
  end
end
