class RatingsControllerPermission < ActiveRecord::Migration

    def self.up
	    # get Permission entry
	    permission = Permission.find(:first, :conditions=>["name = ?",'public actions - execute']);
	    
	    # is there already a Ratingscontroller for bookmarks?
	    ratings_controller = RatingsController.find_by_name(:first,:conditions=>["name = ?",'bookmarks'])
	    # if not, create a bookmark
	    if ratings_controller == nil
	      ratings_controller = RatingsController.create(:name => 'bookmarks', :permission_id => permission.id, :builtin => 0)
	    end

	  	# is there a view bookmarks action ?
  	  	action1 = ControllerAction.find(:first, :conditions => ['name = "view_bookmarks" and ratings_controller_id = ?',ratings_controller.id])
    	  # if not, create an index action for leaderboard
    	  if action1 == nil
      	     action1 = ControllerAction.create(:name => 'view_bookmarks', :ratings_controller_id => ratings_controller.id)
     	  end
   	  
	  	action2 = ControllerAction.find(:first, :conditions => ['name = "manage_bookmarks" and ratings_controller_id = ?',ratings_controller.id])
    		# if not, create an index action for leaderboard
    	 
	  	 if action2 == nil
      		action2 = ControllerAction.create(:name => 'manage_bookmarks', :ratings_controller_id => ratings_controller.id)
    	  end

	 Role.rebuild_cache
   end

   def self.down	
    ratings_controller = RatingsController.find_by_name('bookmarks')
    if ratings_controller 
      ratings_controller.destroy
    end
     Role.rebuild_cache
   end

end 