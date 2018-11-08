require 'rspec'

describe SuggestionController do

  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true,
          participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  let(:suggestion) do
    build(:suggestion, id:1, name:'test suggestion', assignment: assignment)

  end

  describe 'create suggestion' do
    it 'calls mail_instructor if the suggestion is saved' do
      expect(suggestion).to receive(:mail_instructor)
    end

  end

  describe 'mail_instructor' do

    it 'call mailer to send mail' do
      suggestion_params= FactoryGirl.attributes_for(:to, :subject, :body, :suggestion_title, :proposer)
      mailer = mock(Mailer)
      mailer.should_receive(:deliver).with(suggestion_params)
    end
  end

end