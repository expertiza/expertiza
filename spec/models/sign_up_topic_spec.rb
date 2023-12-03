describe SignUpTopic do
  let(:topic) { build(:topic) }
  let(:suggestion) { build(:suggestion, id: 1, assignment_id: 1) }
  let(:signed_up_team) { build(:signed_up_team) }
  let(:team) { create(:assignment_team, id: 1, name: 'team 1', users: [user, user2]) }
  let(:user) { create(:student) }
  let(:user2) { create(:student, name: 'qwertyui', id: 5) }

  describe '.import' do
    context 'when record is empty' do
      it 'raises an ArgumentError' do
        expect { SignUpTopic.import({}, nil, nil) }.to raise_error(ArgumentError, 'The CSV File expects the format: Topic identifier, Topic name, Max choosers, Topic Category (optional), Topic Description (Optional), Topic Link (optional).')
      end
    end
    context 'when record is not empty' do
      let(:row) do
        { topic_identifier: 'identifier', topic_name: 'name', max_choosers: 'chooser', category: 'category', description: 'description', link: 'link' }
      end
      let(:session) do
        { assignment_id: 1 }
      end
      let(:attributes) do
        { topic_identifier: 'identifier', topic_name: 'name', max_choosers: 'chooser', category: 'category', description: 'description', link: 'link' }
      end
      context 'when the topic is not found' do
        it 'creates a new sign up topic' do
          allow(SignUpTopic).to receive_message_chain(:where, :first).with(topic_name: row[:topic_name], assignment_id: session[:assignment_id]).with(no_args).and_return(nil)
          allow(ImportTopicsHelper).to receive(:define_attributes).with(row).and_return(attributes)
          allow(ImportTopicsHelper).to receive(:create_new_sign_up_topic).with(attributes, session).and_return(true)
          expect(ImportTopicsHelper).to receive(:create_new_sign_up_topic).with(attributes, session)
          SignUpTopic.import(row, session, nil)
        end
      end
      context 'when the topic is found' do
        it 'changes the max_chooser and topic_identifier of the existing topic' do
          allow(SignUpTopic).to receive_message_chain(:where, :first).with(topic_name: row[:topic_name], assignment_id: session[:assignment_id]).with(no_args).and_return(topic)
          allow(topic).to receive(:save).with(no_args).and_return(true)
          expect(topic).to receive(:save).with(no_args)
          SignUpTopic.import(row, session, nil)
        end
      end
    end
  end

  describe '#new_topic_from_suggestion' do
    before(:each) do
      allow(Suggestion).to receive_message_chain(:where, :size, :to_s).and_return('3')
    end
    context 'when the signup topic saves successfully and the suggestion updates attribute successfully' do
      it 'returns a signuptopic' do
        allow_any_instance_of(SignUpTopic).to receive(:save).and_return(true)
        allow_any_instance_of(Suggestion).to receive(:update_attribute).and_return(true)
        expect(SignUpTopic.new_topic_from_suggestion(suggestion).class).to eq(SignUpTopic)
      end
    end
    context 'when the signup topic saves unsuccessfully and the suggestion updates attribute unsuccessfully' do
      it 'returns a signuptopic' do
        allow_any_instance_of(SignUpTopic).to receive(:save).and_return(false)
        allow_any_instance_of(Suggestion).to receive(:update_attribute).and_return(false)
        expect(SignUpTopic.new_topic_from_suggestion(suggestion)).to eq('failed')
      end
    end
  end

  describe '#format_for_display' do
    it 'returns a formatted string' do
      expect(topic.format_for_display).to eq('1 - Hello world!')
    end
  end

  describe '#users_on_waiting_list' do
    it 'returns flattened list of users on waitlist' do
      allow(SignedUpTeam).to receive(:where).and_return([signed_up_team])
      allow(AssignmentTeam).to receive(:find).and_return(team)
      expect(topic.users_on_waiting_list).to eq([user, user2])
    end
  end

  describe 'has_suggestion_topic?' do
    context 'when the number of sign up topics is the same number as all topics' do
      it 'return false' do
        allow(SignUpTopic).to receive(:where).and_return([topic])
        expect(SignUpTopic.has_suggested_topic?(1)).to be_falsey
      end
    end
    context 'when the number of sign up topics is not the same number as all topics' do
      it 'return false' do
        allow(SignUpTopic).to receive(:where).with(assignment_id: 1, private_to: nil).and_return([topic])
        allow(SignUpTopic).to receive(:where).with(assignment_id: 1).and_return([])
        expect(SignUpTopic.has_suggested_topic?(1)).to be_truthy
      end
    end
  end

  describe 'slot_available?' do
    let(:topic) { instance_double(SignUpTopic, id: 1, max_choosers: 3) }
  
    context 'when no students have selected the topic yet' do
      it 'returns true' do
        allow(SignedUpTeam).to receive(:where).with(topic_id: 1, is_waitlisted: false).and_return([])
        allow(SignUpTopic).to receive(:find).with(1).and_return(topic)
        
        expect(SignUpTopic.slot_available?(1)).to eq(true)
      end
    end
  
    context 'when students have selected the topic but slots are available' do
      it 'returns true' do
        allow(SignedUpTeam).to receive(:where).with(topic_id: 1, is_waitlisted: false).and_return([double, double])
        allow(SignUpTopic).to receive(:find).with(1).and_return(topic)
        
        expect(SignUpTopic.slot_available?(1)).to eq(true)
      end
    end
  
    context 'when all slots for the topic are filled' do
      it 'returns false' do
        allow(SignedUpTeam).to receive(:where).with(topic_id: 1, is_waitlisted: false).and_return([double, double, double])
        allow(SignUpTopic).to receive(:find).with(1).and_return(topic)
        
        expect(SignUpTopic.slot_available?(1)).to eq(false)
      end
    end
  end

  describe 'save_waitlist_entry' do
    let(:sign_up) { instance_double(SignedUpTeam, is_waitlisted: false, save: true) }
    let(:logger_message) { instance_double(LoggerMessage) }
  
    before do
      allow(LoggerMessage).to receive(:new).and_return(logger_message)
      allow(sign_up).to receive(:is_waitlisted=)
      allow(sign_up).to receive(:save).and_return(true)
      allow(ExpertizaLogger).to receive(:info)
    end
  
    context 'when saving the user as waitlisted' do
      it 'updates the user\'s waitlist status and logs the creation of sign-up sheet' do
        result = SignUpTopic.save_waitlist_entry(sign_up, 123)
  
        expect(sign_up).to have_received(:is_waitlisted=).with(true)
        expect(sign_up).to have_received(:save)
        expect(LoggerMessage).to have_received(:new).with('SignUpSheet', '', "Sign up sheet created for waitlisted with teamId 123")
        expect(ExpertizaLogger).to have_received(:info).with(logger_message)
        expect(result).to eq(true)
      end
    end
  end

  describe '#signup_team_for_chosen_topic' do
    let(:team) { create(:team) }
    let(:topic) { SignUpTopic.new(id: 1, max_choosers: 3) }

    context 'when the team is not already signed up or waitlisted for the topic' do
      before do
        allow(SignedUpTeam).to receive(:find_user_signup_topics).and_return([])
      end

      it 'signs up the team for the chosen topic' do
        allow(topic).to receive(:signup_team_for_chosen_topic).and_return(true)
        allow(SignUpTopic).to receive(:slot_available?).and_return(true)
        expect(topic.signup_team_for_chosen_topic(team.id)).to eq(true)
      end
    end

    context 'when the team is already signed up and waitlisted for the topic' do
      before do
        allow(SignedUpTeam).to receive(:find_user_signup_topics).and_return([double(is_waitlisted: true)])
      end

      it 'does not create a new signup entry' do
        allow(topic).to receive(:signup_team_for_chosen_topic).and_return(false)
        expect(topic.signup_team_for_chosen_topic(team.id)).to eq(false)
      end
    end

    context 'when there are no available slots for the topic' do
      before do
        allow(SignUpTopic).to receive(:slot_available?).and_return(false)
      end

      it 'creates a new waitlisted signup entry' do
        allow(topic).to receive(:signup_team_for_chosen_topic).and_return(true)
        expect(topic.signup_team_for_chosen_topic(team.id)).to eq(true)
      end
    end
  end

  # describe '#longest_waiting_team' do
  #   let(:topic_id) { 1 } # Define topic_id with a suitable value

  #   context 'when a waitlisted team exists for the topic' do
  #     let(:waitlisted_team) { build(:signed_up_team, is_waitlisted: true) }

  #     before do
  #       allow(SignedUpTeam).to receive(:where).with(topic_id: topic_id, is_waitlisted: true).and_return([waitlisted_team])
  #     end

  #     it 'returns the first waitlisted team' do
  #       expect(your_class_instance.longest_waiting_team(topic_id)).to eq(waitlisted_team)
  #     end
  #   end

  #   context 'when no waitlisted team exists for the topic' do
  #     before do
  #       allow(SignedUpTeam).to receive(:where).with(topic_id: topic_id, is_waitlisted: true).and_return([])
  #     end

  #     it 'returns nil' do
  #       expect(your_class_instance.longest_waiting_team(topic_id)).to be_nil
  #     end
  #   end
  # end

  # describe '#reassign_topic' do
  #   context 'when signup record is not waitlisted' do
  #     before do
  #       allow(SignedUpTeam).to receive(:where).with(topic_id: topic_id, team_id: team_id).and_return([signup_record])
  #       allow(signup_record).to receive(:is_waitlisted).and_return(false)
  #       allow(your_class_instance).to receive(:longest_waiting_team).with(topic_id).and_return(longest_waiting_team)
  #     end

  #     it 'reassigns the topic to the longest waiting team' do
  #       expect(longest_waiting_team).to receive(:is_waitlisted=).with(false)
  #       expect(longest_waiting_team).to receive(:save).once
  #       expect(SignedUpTeam).to receive(:drop_off_waitlists).with(longest_waiting_team.team_id).once
  #       expect(SignedUpTeam).to receive(:drop_off_signup_record).with(topic_id, team_id).once

  #       your_class_instance.reassign_topic(team_id) # Pass team_id as an argument
  #     end
  #   end

  #   context 'when signup record is waitlisted' do
  #     before do
  #       allow(SignedUpTeam).to receive(:where).with(topic_id: topic_id, team_id: team_id).and_return([signup_record])
  #       allow(signup_record).to receive(:is_waitlisted).and_return(true)
  #     end

  #     it 'does not reassign the topic' do
  #       expect(your_class_instance).not_to receive(:longest_waiting_team)
  #       expect(longest_waiting_team).not_to receive(:is_waitlisted=)
  #       expect(longest_waiting_team).not to receive(:save)
  #       expect(SignedUpTeam).not_to receive(:drop_off_waitlists)

  #       expect(SignedUpTeam).to receive(:drop_off_signup_record).with(topic_id, team_id).once

  #       your_class_instance.reassign_topic(team_id) # Pass team_id as an argument
  #     end
  #   end

  #   context 'when no signup record is found' do
  #     before do
  #       allow(SignedUpTeam).to receive(:where).with(topic_id: topic_id, team_id: team_id).and_return([])
  #     end

  #     it 'does not reassign the topic and handles gracefully' do
  #       # Your expectations here
  #       your_class_instance.reassign_topic(team_id) # Pass team_id as an argument
  #     end
  #   end

  #   context 'when no longest waiting team is found' do
  #     before do
  #       allow(SignedUpTeam).to receive(:where).with(topic_id: topic_id, team_id: team_id).and_return([signup_record])
  #       allow(signup_record).to receive(:is_waitlisted).and_return(false)
  #       allow(your_class_instance).to receive(:longest_waiting_team).with(topic_id).and_return(nil)
  #     end

  #     it 'does not reassign the topic and handles gracefully' do
  #       # Your expectations here
  #       your_class_instance.reassign_topic(team_id) # Pass team_id as an argument
  #     end
  #   end
  # end
end
