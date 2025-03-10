describe QuizQuestion do
  let(:quiz_question) { QuizQuestion.new }
  let(:quiz_question_choice1) { QuizQuestionChoice.new }
  let(:quiz_question_choice2) { QuizQuestionChoice.new }
  let(:quiz_question_choice3) { QuizQuestionChoice.new }
  let(:quiz_question_choice4) { QuizQuestionChoice.new }
  before(:each) do
    quiz_question.quiz_question_choices = [quiz_question_choice1, quiz_question_choice2, quiz_question_choice3, quiz_question_choice4]
    quiz_question.txt = 'Question Text'
    allow(quiz_question).to receive(:type).and_return('MultipleChoiceRadio')
    allow(quiz_question_choice1).to receive(:txt).and_return('Choice 1')
    allow(quiz_question_choice1).to receive(:iscorrect?).and_return(true)
    allow(quiz_question_choice2).to receive(:txt).and_return('Choice 2')
    allow(quiz_question_choice2).to receive(:iscorrect?).and_return(false)
    allow(quiz_question_choice3).to receive(:txt).and_return('Choice 3')
    allow(quiz_question_choice3).to receive(:iscorrect?).and_return(false)
    allow(quiz_question_choice4).to receive(:txt).and_return('Choice 4')
    allow(quiz_question_choice4).to receive(:iscorrect?).and_return(false)
  end
  describe '#view_question_text' do
    it 'returns the text of the questions' do
      expect(quiz_question.view_question_text).to eq('<b>Question Text</b><br />Question Type: MultipleChoiceRadio<br />Question Weight: <br />  - <b>Choice 1</b><br />   - Choice 2<br />   - Choice 3<br />   - Choice 4<br /> <br />')
    end
  end
  describe '#get_formatted_question_type' do
    it 'returns the type' do
      expect(quiz_question.get_formatted_question_type).to eq('Multiple Choice - Radio')
    end
  end
end
