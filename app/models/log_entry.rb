class LogEntry < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user'
end
