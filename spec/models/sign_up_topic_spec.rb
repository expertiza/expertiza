describe SignUpTopic do
  let(:topic) { build(:topic) }
  let(:suggestion) { build(:suggestion, id: 1, assignment_id: 1) }
  let(:signed_up_team) { build(:signed_up_team) }
  let(:team) { create(:assignment_team, id: 1, name: 'team 1', users: [user, user2]) }
  let(:user) { create(:student) }
  let(:user2) { create(:student, name: 'qwertyui', id: 5) }

  describe '.import' do
    context 'does not include required fields' do
      it 'raises ArgumentError' do
        expect { SignUpTopic.import({key: 'val'}, nil, 1) }.to raise_error(ArgumentError)
      end
    end

    context 'required fields provided' do
      let (:row) do
        { topic_identifier: 'idn', topic_name: 'my_topic', max_choosers: "3" }
      end

      context 'no existing signup topic' do
        it 'creates a new signup topic' do
          allow(SignUpTopic).to receive_message_chain(:where, :first).and_return(nil)
          expect(SignUpTopic).to receive(:get_new_sign_up_topic).with(any_args)
          SignUpTopic.import(row, nil, 1)
        end
      end

      context 'has existing signup topic' do
        it 'overwrites previous values' do
          allow(SignUpTopic).to receive(:where).with(any_args).and_return(topic)
          allow(topic).to receive(:first).and_return(topic)
          # Expect values to be changed and persisted
          expect(topic).to receive(:topic_identifier=).with('idn')
          expect(topic).to receive(:max_choosers=).with('3')
          expect(topic).to receive(:save)
          SignUpTopic.import(row, nil, 1)
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
end
