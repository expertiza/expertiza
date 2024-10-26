describe QuizQuestion do
  let(:quiz_item) { QuizQuestion.new }
  let(:quiz_item_choice1) { QuizQuestionChoice.new }
  let(:quiz_item_choice2) { QuizQuestionChoice.new }
  let(:quiz_item_choice3) { QuizQuestionChoice.new }
  let(:quiz_item_choice4) { QuizQuestionChoice.new }
  before(:each) do
    quiz_item.quiz_item_choices = [quiz_item_choice1, quiz_item_choice2, quiz_item_choice3, quiz_item_choice4]
    quiz_item.txt = 'Question Text'
    allow(quiz_item).to receive(:type).and_return('MultipleChoiceRadio')
    allow(quiz_item_choice1).to receive(:txt).and_return('Choice 1')
    allow(quiz_item_choice1).to receive(:iscorrect?).and_return(true)
    allow(quiz_item_choice2).to receive(:txt).and_return('Choice 2')
    allow(quiz_item_choice2).to receive(:iscorrect?).and_return(false)
    allow(quiz_item_choice3).to receive(:txt).and_return('Choice 3')
    allow(quiz_item_choice3).to receive(:iscorrect?).and_return(false)
    allow(quiz_item_choice4).to receive(:txt).and_return('Choice 4')
    allow(quiz_item_choice4).to receive(:iscorrect?).and_return(false)
  end
  describe '#view_item_text' do
    it 'returns the text of the items' do
      expect(quiz_item.view_item_text).to eq('<b>Question Text</b><br />Question Type: MultipleChoiceRadio<br />Question Weight: <br />  - <b>Choice 1</b><br />   - Choice 2<br />   - Choice 3<br />   - Choice 4<br /> <br />')
    end
  end
  describe '#get_formatted_item_type' do
    it 'returns the type' do
      expect(quiz_item.get_formatted_item_type).to eq('Multiple Choice - Radio')
    end
  end
end
