require 'rails_helper'

describe StudentTaskController do

	describe "#list" do
    it "Instructor can visit student_task/list" do
      user = build(:instructor)
      stub_current_user(user, user.role.name, user.role)
      get "list"
      expect(response).to render_template("list")
    end

    it "Student can visit student_task/list" do
      user = build(:student)
      stub_current_user(user, user.role.name, user.role)
      get "list"
      expect(response).to render_template("list")
    end

    it "should redirect to login page if current user is nil" do
      get "list"
      expect(response).to redirect_to('/')
    end
  end
end