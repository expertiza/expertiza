describe MentorManagement do
  describe '#select_mentor' do
    context 'it returns selected mentor' do
      allow(zip_mentors_with_team_count).to receive(assignment_id).and_return([user_id])
      expect(user_id).to eq(1)
    end
  end

  describe '#update_mentor_state' do

  end

  describe '#notify_team_of_mentor_assignment' do
    it 'should send email to required email address with proper content ' do
      # Send the email, then test that it got queued
      email = Mailer.delayed_message(bcc: 'bwanza@ncsu.edu',
                             subject: '[Expertiza]: New Mentor Assignment',
                             body: 'test message').deliver_now

      expect(email.from[0]).to eq('expertiza.development@gmail.com')
      expect(email.to[0]).to eq('expertiza.development@gmail.com')
      expect(email.body).to eq('test message')
      expect(email.subject).to eq('[Expertiza]: New Mentor Assignment')
    end
  end

  describe '#user_a_mentor?' do
    context 'it returns false if user is not mentor' do
      it 'should return true if user is a mentor' do
        non_mentor = FactoryBot.create(:participant)
        expect(MentorManagement.user_a_mentor?(non_mentor)).to be false
        mentor = FactoryBot.create(:participant, duty: Participant::DUTY_MENTOR)
        user = FactoryBot.build(:teaching_assistant, id: mentor.user_id)
        expect(MentorManagement.user_a_mentor?(user)).to be true
      end
    end
  end

  describe '#get_mentors_for_assignment' do
    context 'it returns the mentor for assignment' do
      allow(Participant).to receive(find_by).with(assignment_id: 1, duty: 'mentor').and_return(participant)
    end
  end

  describe '#zip_mentors_with_team_count' do

  end
end
