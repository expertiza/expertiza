class Delayedjob < ActiveRecord::Base
  has_paper_trail
  include Delayed::Backend::ActiveRecord
  # self.table_name = 'delayed_jobs'
end
