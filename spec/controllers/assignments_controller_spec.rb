require 'spec_helper'
def valid_instructor_user
  users(:instructor1)
end

def instructor_3
  users(:instructor3)
end

def valid_assignment
  assignments(:assignment1)
end

def instructor_1_assignment
  assignments(:assignment_team_count)
end

def valid_questionnaire
  questionnaires(:questionnaire1)
end

def valid_course
  courses(:course1)
end


describe AssignmentsController do
  fixtures :users, :roles, :assignments, :questionnaires, :courses
  describe "GET show :id" do
    it "assigns @assignment" do
      @request.session[:user] = valid_instructor_user
      get :show, {:id=> valid_assignment.id.to_s}
      expect(assigns(:assignment)).to eq(valid_assignment)
    end

    it "renders show" do
      @request.session[:user] = valid_instructor_user
      get :show, {:id=> valid_assignment.id.to_s}
      expect(response).to render_template("show")
    end
  end

  describe "GET new" do
    it "assigns @assignment" do
      @request.session[:user] = valid_instructor_user
      get :new
      expect(assigns(:assignment)).to be_an_instance_of(Assignment)
    end

    it "renders new" do
      @request.session[:user] = valid_instructor_user
      get :new
      expect(response).to render_template("new")
    end
  end

  describe "GET edit" do
    it "assigns @assignment" do
      @request.session[:user] = valid_instructor_user
      get :edit, {:id => instructor_1_assignment.id.to_s}
      expect(assigns(:assignment)).to eq(instructor_1_assignment)
    end

    it "renders edit" do
      @request.session[:user] = valid_instructor_user
      get :edit, {:id => instructor_1_assignment.id.to_s}
      expect(response).to render_template("edit")
    end
  end

  describe "GET associate_assignment_with_course" do
    #this subtest does not work, I suspect problems with my choice of fixtures
    it "assigns the right courses for an assignment and user" do
      @request.session[:user] = valid_instructor_user
      get :associate_assignment_with_course, {:id => instructor_1_assignment.id.to_s}
      expect(assigns(:assignment)).to eq(instructor_1_assignment)
      expect(assigns(:user)).to eq(valid_instructor_user)
      expect(assigns(:courses)).to eq(valid_course)
    end

    it "renders associate_assignment_with_course" do
      @request.session[:user] = valid_instructor_user
      get :associate_assignment_with_course, {:id => instructor_1_assignment.id.to_s}
      expect(response).to render_template("associate_assignment_with_course")
    end
  end

  describe "GET copy" do
    #this subtest does not work, I suspect problems with how I try to find out if Assignment got a save call
    it "saves the copied assignment" do
      @request.session[:user] = valid_instructor_user
      get :copy, {:id=> valid_assignment.id.to_s}
      Assignment.any_instance.should_receive(:save)
    end

    it "redirects to edit" do
      @request.session[:user] = valid_instructor_user
      get :copy, {:id=> valid_assignment.id.to_s}
      expect(response).should be_redirect
    end
  end

  describe "GET toggle_access" do
    #this subtest does not work, I suspect problems with how I try to find out if Assignment got a save call
    it "toggles the private attribute of the assignment" do
      @request.session[:user] = valid_instructor_user
      get :toggle_access, {:id => valid_assignment.id.to_s}
      Assignment.any_instance.should_receive(:save)
    end

    it "redirects to tree_display#list" do
      @request.session[:user] = valid_instructor_user
      get :toggle_access, {:id => valid_assignment.id.to_s}
      expect(response).to redirect_to("/tree_display/list")
    end
  end
end
