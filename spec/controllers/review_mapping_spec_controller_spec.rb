require 'rails_helper'

RSpec.describe ReviewMappingController, type: :controller do
  before(:each) do
    @assignment = Assignment.where(id: '200').first
  end

  it "should use release_mapping to redirect to student_review controller" do
    get :release_mapping, id: @assignment.id
    expect(response).should redirect_to(:controller => 'student_review', :action => 'list', :id=> '828')
  end

  it "should delete outstanding reviewers to redirect to list_mappings" do
    get :delete_outstanding_reviewers, id: @assignment.id, contributor_id: 200
    expect(response).should redirect_to(:action => 'list_mappings', :id => 200)
  end

  it "should render appropritate response report" do
    get :response_report, id: 723
    response.should render_template(:response_report)
  end

  it "should render appropriate response report for the specific user" do
    get :response_report,  id: 723, :user => {:fullname=> '523, student'}
    response.should render_template(:response_report)
  end

  it "should render appropriate respone report for the specific user with type FeedbackResponseMap" do
    get :response_report,  id: 723, :report => {:type=> 'FeedbackResponseMap'}
    response.should render_template(:response_report)
  end

end