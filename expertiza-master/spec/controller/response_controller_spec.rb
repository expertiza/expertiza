require 'spec_helper'

describe 'ResponseController', :type => controller do
  #method to create an instance of user
 # def score_create
  #  score = Score.create(:question_id => "1", :response_id => "10", :comments => "random comments", :score => "4")
 # end

  def response_create
    response2 = Response.create(:map_id => "1", :additional_comments => "", :version_num => "10")
  end

  def multipart_response_create
    response3 =  Response.create(:map_id => "1", :additional_comments => "Comments exists", :version_num => "10")
  end

 describe 'GET new' do
  it "renders the response template" do
    get :new
  expect(response).to render_template("response")
  end
  it "renders the custom response template" do
    get :new
    expect(response).to render_template("custom_response")
  end
  it "should not be a failed request" do
    get :new
    expect( response).should be_success
  end
 end

 describe 'POST create' do

  it "increments the response count of the table by 1 for a rating rubric " do
  lambda do
     response_create
   end.should change(Response, :count).by(1)
 end

  it "increments the response count of the table by 1 for a multipart rubric " do
  lambda do
    multipart_response_create
  end.should change(Response, :count).by(1)
end
end

   describe 'GET edit' do
     it "renders the edit template for rating rubric" do
       response1 = Response.create(:map_id => "2", :additional_comments => "", :version_num => "20")
       get :response, {:id => response1.to_param}
       assigns(:response).should eq(response1)
     end

     it "renders the edit template for multipart rubric" do
       response4 = Response.create(:map_id => "4", :additional_comments => "new comments added", :version_num => "40")
       get :response, {:id => response4.to_param}
       assigns(:response).should eq(response4)
     end
   end

# review or rereview are same as creating any other response. hence the same test functionality.
  describe 'GET rereview' do
    it "renders the rereview template" do
      response3 = Response.create(:map_id => "3", :additional_comments => "", :version_num => "30")
      get :response, {:id => response3.to_param}
      assigns(:response).should eq(response3)
    end
  end

  describe 'GET delete' do
    it "deletes the response for a particular response id"  do
    expect( response).should be_success
  end
end

end
