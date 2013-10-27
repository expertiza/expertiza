class SiteController < ActiveRecord::Base
  has_many :controller_actions
  belongs_to :permission

  validates_presence_of :name
  validates_uniqueness_of :name

  scope :builtin, -> { where(builtin: 1).order(:name) }
  scope :application, -> { where('builtin is null or builtin = 0').order(:name) }

  def actions
    @actions ||= controller_actions.order(:name)
  end


  def self.classes
    classes = Hash.new

    ObjectSpace.each_object(Class) do |klass|
      if klass.respond_to?(:controller_name) && klass.superclass.to_s == ApplicationController.to_s
          classes[klass.controller_name] = klass
      end
    end

    classes
  end
end
