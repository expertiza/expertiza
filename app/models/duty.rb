class Duty < ActiveRecord::Base

  def self.get_unmapped_duties
    Duty.where("questionnaires_id is null")
  end

  def self.update_questionnaireID (duty_id, questionnaires_id)
    Duty.update(duty_id, :questionnaires_id=>questionnaires_id)
  end
end
