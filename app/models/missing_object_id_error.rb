class MissingObjectIDError < StandardError
 def exception
   "No object ID was provided to the import process. Please contact the system administrator. Model Name: Course"
 end
end