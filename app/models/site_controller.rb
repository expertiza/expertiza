class SiteController < ApplicationRecord
  has_many :controller_actions
  belongs_to :permission

  validates :name, presence: true
  validates :name, uniqueness: true

  scope :builtin, -> { where(builtin: 1).order(:name) }
  scope :application, -> { where('builtin is null or builtin = 0').order(:name) }

  def actions
    @actions ||= controller_actions.order(:name)
  end

  def self.find_or_create_by_name(params)
    SiteController.find_or_create_by(name: params)
  end

  def self.classes
    classes = {}

    ObjectSpace.each_object(Class) do |klass|
      if klass < ApplicationController
        classes[klass.controller_name] = klass if klass.respond_to?(:controller_name)
      end
    end
    classes
  end
end
