require 'rails_helper'

describe ParticipantsController do

	describe "#list" do
    it "Instructor can visit participants/list" do
      user = build(:instructor)
      stub_current_user(user, user.role.name, user.role)
      get "list"
      expect(response).to render_template("list")
    end

    it "Student cannot visit participants/list" do
      user = build(:student)
      stub_current_user(user, user.role.name, user.role)
      get "list"
      expect(response).to redirect_to('/')
    end

    it "should redirect to login page if current user is nil" do
      get "list"
      expect(response).to redirect_to('/')
    end
  end
end