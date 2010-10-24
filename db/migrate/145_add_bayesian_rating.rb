class AddBayesianRating< ActiveRecord::Migration
	def self.up
		add_column :bookmarks, :bayesian_rating, :float, :default => 0	
	end
	
	def self.down
		remove_column :bookmarks, :bayesian_rating
	end
end