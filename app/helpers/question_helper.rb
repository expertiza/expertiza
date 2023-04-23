module QuestionHelper
  # factory method to create the appropriate question based on the type
  def question_factory(type, questionnaire_id, seq)
    case type
    when 'Criterion'
      return Criterion.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when type == 'Scale'
      return Scale.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when 'Cake'
      return Cake.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when 'Dropdown'
      return Dropdown.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when 'Checkbox'
      return Checkbox.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when 'TextArea'
      return TextArea.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when  'TextField'
      return TextField.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when 'UploadFile'
      return UploadFile.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when 'SectionHeader'
      return SectionHeader.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when 'TableHeader'
      return TableHeader.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    when 'ColumnHeader'
      return ColumnHeader.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    else
      flash[:error] = "Error: Undefined Question"
    end

  end
end
