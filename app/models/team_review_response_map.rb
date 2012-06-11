class TeamReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Team', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Team', :foreign_key => 'reviewee_id'
  
  #return all the versions available for a response map.
  #a person who is doing meta review has to be able to see all the versions of review.
  def get_all_versions()
    if self.review_mapping.response
      @sorted_array=Array.new
      @prev=Response.all
      for element in @prev
        if(element.map_id==self.review_mapping.id)
          array_not_empty=1
          @sorted_array << element
        end
      end
      @sorted=@sorted_array.sort { |m1,m2|(m1.version_num and m2.version_num) ? m1.version_num <=> m2.version_num : (m1.version_num ? -1 : 1)}
       #return all the lists in ascending order.
      return @sorted
    else
      return nil #"<I>No review was performed.</I><br/><hr/><br/>"
    end
  end

end
