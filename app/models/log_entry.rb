#E1703 Change
#Newly added model, this does not have Active Record linking
class LogEntry

	attr_accessor :userid,:time,:event_type,:user_type,:desc

	def initialize(userid,time,e_type,u_type,desc)  
	    @userid = userid
	    @time = time  
	    @event_type = e_type
	    @user_type = u_type 
	    @desc = desc 
  	end


end