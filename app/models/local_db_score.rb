# E1731 changes: New table local_db_scores created
class LocalDbScore < ActiveRecord::Base
  belongs_to :response_map
end
