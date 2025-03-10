class Permission < ApplicationRecord
  # attr_accessible :name

  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :content_pages, dependent: :nullify
  has_many :controller_actions, dependent: :nullify
end
