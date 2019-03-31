describe 'TrueFalse' do
  let(:tf_text) { 'test text' }
  let(:tf) { TrueFalse.new(txt: tf_text) }
  let(:value1) { {iscorrect: false, txt: 'answer 1'} }
  let(:value2) { {iscorrect: true, txt: 'answer 2'} }
  let(:value3) { {iscorrect: false, txt: ''} }
  let(:valid_choices) { {one: value1, two: value2} }
  let(:invalid_choices) { {one: value1, three: value3} }

  describe '#edit' do
    before(:each) do
      qc = double('QuizQuestionChoice')
      allow(QuizQuestionChoice).to receive(:where).and_return([qc, qc, qc, qc])
      allow(qc).to receive(:iscorrect).and_return(true)
      @tf_edit = tf.edit
    end
    it 'returns an html_safe string' do
      expect(@tf_edit.html_safe?).to be_truthy
    end
    it 'includes a 100 col textarea tag with text' do
      expect(@tf_edit).to match(/<textarea/).and match(/cols="100"/).and include(tf_text)
    end
    it 'includes an input tag of type radio' do
      expect(@tf_edit).to match(/<input/).and match(/type="radio"/)
    end
  end

  describe '#complete' do
    before(:each) do
      qc = double('QuizQuestionChoice')
      allow(QuizQuestionChoice).to receive(:where).and_return([qc, qc, qc, qc])
      allow(qc).to receive(:iscorrect).and_return(true)
      allow(qc).to receive(:txt).and_return('quiz text')
      @tf_comp = tf.complete
    end
    it 'returns an html_safe string' do
      expect(@tf_comp.html_safe?).to be_truthy
    end
    it 'returns an input tag of type radio with text' do
      expect(@tf_comp).to match(/<input/).and match(/type="radio"/).and include(tf_text)
    end
  end

  describe '#view_completed_question' do
    before(:each) do
      @qc = double('QuizQuestionChoice')
      @ua = double('Answer')
      allow(QuizQuestionChoice).to receive(:where).and_return([@qc, @qc, @qc, @qc])
      allow(@qc).to receive(:txt).and_return('quiz text')
      allow(@ua).to receive(:first).and_return(Answer.new)
      allow(Answer).to receive(:answer).and_return('user answer')
    end
    context 'when the choice is correct' do
      before(:each) do
        allow(@qc).to receive(:iscorrect).and_return(true)
        @tf_comp = tf.view_completed_question(@ua)
      end
      it 'returns an html_safe string' do
        expect(@tf_comp.html_safe?).to be_truthy
      end
      it 'returns an image tag' do
        expect(@tf_comp).to match(/<img/)
      end
      it 'returns True in the text' do
        expect(@tf_comp).to include('True')
      end
    end

    context 'when the choice is incorrect' do
      before(:each) do
        allow(@qc).to receive(:iscorrect).and_return(false)
        @tf_comp = tf.view_completed_question(@ua)
      end
      it 'returns False in the text' do
        expect(@tf_comp).to include('False')
      end
    end
  end

  describe '#isvalid' do
    it 'returns valid if all choices are valid' do
      expect(tf.isvalid(valid_choices)).to include('valid')
    end
    it 'returns a string without valid if any choice is invalid' do
      expect(tf.isvalid(invalid_choices)).to_not include('valid')
    end
  end
end
