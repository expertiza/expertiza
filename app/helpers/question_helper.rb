module QuestionHelper

  # Maps type to question
  QUESTION_MAP = {
    'Criterion' => Criterion,
    'Scale' => Scale,
    'Cake' => Cake,
    'Dropdown' => Dropdown,
    'Checkbox' => Checkbox,
    'TextArea' => TextArea,
    'TextField' => TextField,
    'UploadFile' => UploadFile,
    'SectionHeader' => SectionHeader,
    'TableHeader' => TableHeader,
    'ColumnHeader' => ColumnHeader
  }.freeze

  # factory method to create the appropriate question based on the type
  def question_factory(type, questionnaire_id, seq)
    question_class = QUESTION_MAP[type]

    if question_class.nil?
      flash[:error] = 'Error: Undefined Question'
    else
      question_class.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    end
  end
end
