module QuestionHelper
  # factory method to create the appropriate question based on the type
  def question_factory(type, questionnaire_id, seq)
    if type == 'Criterion'
      return Criterion.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'Scale'
      return Scale.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'Cake'
      return Cake.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'Dropdown'
      return Dropdown.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'Checkbox'
      return Checkbox.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'TextArea'
      return TextArea.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'TextField'
      return TextField.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'UploadFile'
      return UploadFile.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'SectionHeader'
      return SectionHeader.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'TableHeader'
      return TableHeader.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    elsif type == 'ColumnHeader'
      return ColumnHeader.create(txt: '', questionnaire_id: questionnaire_id, seq: seq, type: type, break_before: true)
    end
  end
end
