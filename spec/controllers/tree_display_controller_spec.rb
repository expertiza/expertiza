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

  describe "#go_to_menu_items" do
    before do
      allow(nil).to receive(:find_by_node_object_id).and_return(nil)
      allow(nil).to receive(:id).and_return(nil)
      allow(nil).to receive(:name).and_return(true)
    end
    it "should receive Review Rubrics and redirect to list" do
      allow(nil).to receive(:find_by_name).with("Review").and_return(nil)
        get "go_to_menu_items", params1: "Review Rubrics"
        expect(response).to redirect_to(list_tree_display_index_path)
    end
    it "should receive Teammate review rubrics and redirect to list" do
      allow(nil).to receive(:find_by_name).with("Teammate review").and_return(nil)
      get "go_to_menu_items", params1: "Teammate review rubrics"
      expect(response).to redirect_to(list_tree_display_index_path)
    end
    it "should receive Metareview rubrics and redirect to list" do
      allow(nil).to receive(:find_by_name).with("Metareview").and_return(nil)
      get "go_to_menu_items", params1: "Metareview rubrics"
      expect(response).to redirect_to(list_tree_display_index_path)
    end

    it "should receive Author feedbacks and redirect to list" do
      allow(nil).to receive(:find_by_name).with("Author feedbacks").and_return(nil)
      get "go_to_menu_items", params1: "Author Feedback"
      expect(response).to redirect_to(list_tree_display_index_path)
    end
    it "should receive Global surveys and redirect to list" do
      allow(nil).to receive(:find_by_name).with("Global surveys").and_return(nil)
      get "go_to_menu_items", params1: "Global Survey"
      expect(response).to redirect_to(list_tree_display_index_path)
    end
    it "should receive Course evaluations and redirect to list" do
      allow(nil).to receive(:find_by_name).with("Course evaluations").and_return(nil)
      get "go_to_menu_items", params1: "Course Evaluation"
      expect(response).to redirect_to(list_tree_display_index_path)
    end
    it "should receive Surveys and redirect to list" do
      allow(nil).to receive(:find_by_name).with("Surveys").and_return(nil)
      get "go_to_menu_items", params1: "Survey"
      expect(response).to redirect_to(list_tree_display_index_path)
    end
    it "should redirect to root_url if request parameter is invalid" do
      allow(nil).to receive(:find_by_name).with(nil).and_return(nil)
      get "go_to_menu_items"
      expect(response).to redirect_to(root_path)
    end
  end



end
