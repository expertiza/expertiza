describe SignUpTopic do
  let(:topic) { build(:topic) }
  describe ".import" do
    context 'when record is empty' do
      it 'raises an ArgumentError' do
        expect { SignUpTopic.import({}, nil, nil) }.to raise_error(ArgumentError, 'The CSV File expects the format: Topic identifier, Topic name, Max choosers, Topic Category (optional), Topic Description (Optional), Topic Link (optional).')
      end
    end

    context 'when the topic is not found' do
      it 'creates a new sign up topic' do
        row = {topic_name: 'name'}
        session = {assignment_id: 1}
        attributes = {topic_identifier: "identifier", topic_name: "name", max_choosers: "chooser", category: "category", description: "description", link: "link"}
        allow(SignUpTopic).to receive_message_chain(:where, :first).with(topic_name: row[:topic_name], assignment_id: session[:assignment_id]).with(no_args).and_return(nil)
        allow(ImportTopicsHelper).to receive(:define_attributes).with(row).and_return(attributes)
        allow(ImportTopicsHelper).to receive(:create_new_sign_up_topic).with(attributes, session).and_return(true)
        expect(ImportTopicsHelper).to receive(:create_new_sign_up_topic).with(attributes, session)
        SignUpTopic.import(row, session, nil)
      end
    end

    context 'when the topic is found' do
      it 'changes the max_chooser and topic_identifier of the existing topic' do
        row = {topic_name: 'name'}
        session = {assignment_id: 1}
        attributes = {topic_identifier: "identifier", topic_name: "name", max_choosers: "chooser", category: "category", description: "description", link: "link"}
        allow(SignUpTopic).to receive_message_chain(:where, :first).with(topic_name: row[:topic_name], assignment_id: session[:assignment_id]).with(no_args).and_return(topic)
        allow(topic).to receive(:save).with(no_args).and_return(true)
        expect(topic).to receive(:save).with(no_args)
        SignUpTopic.import(row, session, nil)
      end
    end

    context 'when the record has more than 4 items' do
      let(:row) do
        {name: 'no one', fullname: 'no one', email: 'name@email.com', role:'user_role_name', parent: 'user_parent_name'}
      end
      let(:attributes) do
        {role_id: 1, name: 'no one', fullname: 'no one', email: '', email_on_submission: 'name@email.com',
         email_on_review: 'name@email.com', email_on_review_of_review: 'name@email.com'}
      end
      before(:each) do
        allow(ImportFileHelper).to receive(:define_attributes).with(row).and_return(attributes)
        allow(ImportFileHelper).to receive(:create_new_user).with(attributes, {}).and_return(double('User', id: 1))
      end
    end
  end
end