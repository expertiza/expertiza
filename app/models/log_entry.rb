#E1703 Change
#Newly added model, this does not have Active Record linking
class LogEntry

	attr_accessor :userid,:time,:type

	def initialize(userid,time, type)  
	    @userid = userid
	    @time = time  
	    @type = type  
  	end


end