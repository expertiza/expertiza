require 'rspec'

describe 'update_reputation' do

  it 'should update reputation' do
    expect{
      post :update,Lauw: @participants.attributes_for(:Hamer)
    }.to change{[@participant.Hamer]}
     #.and change(Lauw.value)

  end
end