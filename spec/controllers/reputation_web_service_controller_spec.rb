require 'rspec'
require 'rails_helper'
include ParticipantsHelper

describe 'update_reputation' do
  before(:each) do
    @participant = Participant.all
  end

  #it 'should update reputation' do
    #expect{
      #post :update, :Hamer => @participant.Hamer
    #}.to change

  #end

  #it 'should exist' do

    #post :update, { :format => 'json'}
   # expect(response.body).to exist

  #end
end