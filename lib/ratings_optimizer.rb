module RatingsOptimizer   
      # this is the max number of votes needed before the rating of any item be considered as believable
      # We use avg_num_votes if they are less than maxAverageNumVotes, otherwise use this value
  MaxAverageNumVotes = 5
   
  def optimize_ratings (entity)   
    @this_num_votes = entity.ratings.size  ##number of votes for a given entity
    @this_rating = entity.rating  ##average rating of an entity
   
    @avg_num_votes = calculate_avg_num_votes
    if(@avg_num_votes > MaxAverageNumVotes)
        @avg_num_votes = MaxAverageNumVotes
    end
   
    ##calculate average rating of all items
    @avg_rating = Rating.average(:rating)
   
    #now find Bayesian Rating
    br = 0
    if(@avg_num_votes!=nil && @avg_rating!=nil && @this_num_votes!=nil && @this_rating && ((@avg_num_votes + @this_num_votes)!=0))
        br = ( (@avg_num_votes * @avg_rating) + (@this_num_votes * @this_rating) ) / (@avg_num_votes + @this_num_votes)
    end
    return br
  end
 
      def calculate_avg_num_votes
        total_num_votes = Rating.count(:all)
        total_unique_entities = Rating.count(:rateable_id, :distinct=>true)
        avg_num_votes = 0
        if(total_unique_entities != 0)
            avg_num_votes= total_num_votes.to_f / total_unique_entities.to_i
        end
        return avg_num_votes
    end
 
end