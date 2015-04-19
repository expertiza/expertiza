class Delayedjob < ActiveRecord::Base
has_paper_trail
  set_table_name 'delayed_jobs'
end
