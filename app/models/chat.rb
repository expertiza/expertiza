class Chat < ActiveRecord::Base
  belongs_to :team
  has_many :messages , :dependent => :delete_all
  validates :assignment_team_id, uniqueness: true
end
