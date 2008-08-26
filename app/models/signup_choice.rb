class SignupChoice < ActiveRecord::Base

  validates_presence_of :text
  validates_presence_of :total_slots
  validates_presence_of :slots_occupied
  
  validates_numericality_of :total_slots
  validates_numericality_of :slots_occupied
  
  
  
end
