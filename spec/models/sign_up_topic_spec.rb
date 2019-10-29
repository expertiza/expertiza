describe SignUpTopic do
  let(:topic) { build(:topic) }
  describe '.import' do
    context 'when record is empty' do
      it 'raises an ArgumentError' do
        expect { SignUpTopic.import({}, nil, nil) }.to raise_error(ArgumentError, 'The CSV File expects the format: Topic identifier, Topic name, Max choosers, Topic Category (optional), Topic Description (Optional), Topic Link (optional).')
      end
    end

    context 'when record is not empty' do
      let(:row) do
        {topic_identifier: 'identifier', topic_name: 'name', max_choosers: 'chooser', category: 'category', description: 'description', link: 'link'}
      end
      let(:session) do
        {assignment_id: 1}
      end
      let(:attributes) do
        {topic_identifier: 'identifier', topic_name: 'name', max_choosers: 'chooser', category: 'category', description: 'description', link: 'link'}
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
end