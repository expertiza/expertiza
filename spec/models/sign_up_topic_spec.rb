describe SignUpTopic do
  let (:topic) { build(:topic) }

  describe '.import' do
    context 'does not include required fields' do
      it 'raises ArgumentError' do
        expect {SignUpTopic.import({key: 'val'}, nil, 1)}.to raise_error(ArgumentError)
      end
    end

    context 'required fields provided' do
      let (:row) do
        {topic_identifier: 'idn', topic_name: 'my_topic', max_choosers: "3"}
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
          expect(topic).to receive(:topic_identifier=).with("idn")
          expect(topic).to receive(:max_choosers=).with("3")
          expect(topic).to receive(:save)
          SignUpTopic.import(row, nil, 1)
        end
      end
    end
  end
end