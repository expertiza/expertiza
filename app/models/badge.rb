class Badge < ActiveRecord::Base
  has_many :assignment_badges, dependent: :destroy
  has_many :assignments, through: :assignment_badges
  has_many :awarded_badges
  validates :name, presence: true
  validates :description, presence: true

  def self.get_id_from_name(badge_name)
    Badge.find_by(name: badge_name).try(:id)
  end

  def self.get_image_name_frrom_name(badge_name)
    Badge.find_by(name: badge_name).try(:image_name)
  end

end
