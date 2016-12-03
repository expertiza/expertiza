require 'rails_helper'
include LogInHelper


RSpec.describe ResponseTimeController, type: :controller do

context 'checking that the user creates valid post request' do

  date1 = DateTime.parse("2011-05-19 10:30:14")
  date2 = DateTime.parse("2011-05-19 11:30:14")
  date3 = DateTime.parse("2011-05-19 13:30:14")

  let!(:responsetime) {ResponseTime.create(map_id: 1, link: 'hello', round: 1, start: date1)}
  let!(:first_review) { Response.create(map_id: 1, additional_comment: 'hello', round: 1) }
  let!(:response_time) {ResponseTime.create(map_id: 2, link: 'hello2', round: 2, start: date2, end: nil)}

  before(:each) do
    student.save
    @user = User.find_by_name('student14')
    @role = double('role', super_admin?: false)
    stub_current_user(@user, 'student14', @role)
  end

  describe 'POST #record_start_time' do

  it 'returns with an HTTP status of 200' do

    allow(ResponseTime).to receive(:where).and_return(responsetime)
    allow(responsetime).to receive(:each).and_return(1)
    allow_any_instance_of(ResponseTime).to receive_message_chain(:new).and_return(1)
    allow(responsetime).to receive(:save).and_return(true)

    post "record_start_time", :response_time => {map_id: 1, round: 1, link: 'hello' , start: date3}
    expect(response).to have_http_status(200)

  end

  describe 'POST #record_end_time' do

  it 'respond with an HTTP status of 200 and render json'  do
    allow(ResponseTime).to receive(:where).and_return(response_time)
    allow(response_time).to receive(:each).and_return(1)
    post "record_end_time", :response_time => {map_id: 2, round: 2, end: date3}, format: :json
    @expected = Array.new
    expect(response.body).to eq(@expected.to_json)
    expect(response).to have_http_status(200)

  end
  end

end
end
end
