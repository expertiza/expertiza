class ChoiceQuestion < Question
  attr_accessible :id, :txt, :weight, :questionnaire_id, :seq, :size,
                  :alternatives, :break_before, :max_label, :min_label, :questionnaire, :type
end
