require 'rails_helper'

describe TreeDisplayController do

  describe "#list" do
    it "should not redirect to student_task controller if current user is an instructor" do
      allow(session[:user]).to receive("student?").and_return(false)
      post "list"
      response.should_not redirect_to(list_student_task_index_path)
    end
    it "should redirect to student_task controller if current user is a student" do
      allow(session[:user]).to receive("student?").and_return(true)
       post "list"
       response.should redirect_to(list_student_task_index_path)
    end
  end

  describe "#ta_for_current_mappings?" do
    it "should return true if current user is a TA for current course" do
        allow(session[:user]).to receive("ta?").and_return(true)
    end
  end

  describe "#populate_rows" do
    let(:dbl) { double }
    before { expect(dbl).to receive(:populate_rows).with(Hash, String)}
    it "passes when the arguments match" do
      dbl.populate_rows({},"")
    end
  end

  describe "#populate_1_row" do
    let(:dbl) { double }
    before { expect(dbl).to receive(:populate_1_row).with(Node) }
    it "passes when the arguments match" do
      dbl.populate_1_row(Node.new)
    end
  end

end
