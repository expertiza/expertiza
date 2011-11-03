class LogEntry < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user'
  validates_presence_of :entry
  validates_presence_of :location
end
