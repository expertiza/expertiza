class Institution < ApplicationRecord
  has_many :courses, dependent: :destroy, foreign_key: 'institutions_id'

  validates :name, length: {minimum: 1}
  validates :name, uniqueness: true
end
