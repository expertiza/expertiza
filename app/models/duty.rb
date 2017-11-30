class Duty < ActiveRecord::Base

  def self.get_unmapped_duties
    Duty.where("questionnaires_id is null")
  end

  def self.update_questionnaireID (duty_id, questionnaires_id)
    Duty.update(duty_id, :questionnaires_id=>questionnaires_id)
  end

  def self.get_questionnaireID(duty_id)
    duty = Duty.find_by_id(duty_id)
    if !duty.nil?
      return duty.questionnaires_id
    else
      return nil
    end
  end

end
