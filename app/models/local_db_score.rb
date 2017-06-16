class LocalDbScore < ActiveRecord::Base
    belongs_to :response_map
    attr_accessible :score_type, :round, :score, :response_map_id
end