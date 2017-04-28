require 'rails_helper'

describe StudentTaskController do
  describe "#list" do
    it "Instructor visiting student_task/list page" do
      user = build(:instructor)
      stub_current_user(user, user.role.name, user.role)
      get "list"
      expect(response).to render_template("list")
    end

    it "Student visiting student_task/list page" do
      user = build(:student)
      stub_current_user(user, user.role.name, user.role)
      get "list"
      expect(response).to render_template("list")
    end

    it "Unknown assigned user trying to access the student_task/list page" do
      get "list"
      expect(response).to redirect_to("/")
    end
  end
end
