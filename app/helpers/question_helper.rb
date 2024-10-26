module QuestionHelper

  # Maps type to item
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

  # factory method to create the appropriate item based on the type
  def item_factory(type, itemnaire_id, seq)
    item_class = QUESTION_MAP[type]

    if item_class.nil?
      flash[:error] = 'Error: Undefined Question'
    else
      item_class.create(txt: '', itemnaire_id: itemnaire_id, seq: seq, type: type, break_before: true)
    end
  end
end
