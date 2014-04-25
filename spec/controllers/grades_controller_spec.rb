require 'rspec'
require 'spec_helper'
require 'rspec'

describe 'GradesController' do
  include RSpec::Rails::ControllerExampleGroup
  before :each do
    @fake_assignment = Assignment.new
  end
  def setup
    @controller = GradesController.new
  end
  describe 'GET all scores' do
    it 'should get all scores for a user' do
      get :all_scores
      expect(response).to render_template('all_scores')
    end
  end
  describe 'GET all scores' do
    it 'should get all scores for a particular course' do
      get :view_course_scores
      expect(response).to render_template('view course scores')
    end
  end
  describe 'view score for a assignment' do
    it 'should return the hash of scores for all teams participating in the assignment' do
      post :view, {:assignment => @fake_assignment}
      assigns(:scores).should be_a(Hash)
    end
  end
end