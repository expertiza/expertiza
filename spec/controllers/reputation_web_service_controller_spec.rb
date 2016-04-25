require 'rspec'
require 'rails_helper'
include ParticipantsHelper

describe 'update_reputation' do
  before(:each) do
    @participant = Participant.find_by[:id]
  end

  it 'should update reputation' do
    expect{
      post :send_post_request, Hamer,Lauw: Participant.attributes_for(:Hamer, :Lauw)
    }.to change(Hamer.value)
     .and change(Lauw.value)

  end
end