class Badge < ActiveRecord::Base
  has_many :assignment_badges, dependent: :destroy
  has_many :assignments, through: :assignment_badges
  has_many :awarded_badges, dependent: :destroy
  has_many :participants, through: :awarded_badges
  has_many :nominations, through: :assignment_badges
  # adding validations for Badge table entries as part of project E1822
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :description, presence: true
  validates :image_url, presence: true

  def used_in_course(course_id)
    CourseBadge.exists?(badge_id: self.id, course_id: course_id)
  end

  def self.get_id_from_name(badge_name)
    Badge.find_by(name: badge_name).try(:id)
  end

  def self.get_image_url_from_name(badge_name)
    Badge.find_by(name: badge_name).try(:image_url)
  end
end
