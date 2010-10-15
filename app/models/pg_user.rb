class User < ActiveRecord::Base
   # This extra User class is defined so that we can add
   # initialization code that is called whenever any kind
   # of user is created ... without having to modify the
   # Goldberg code.
   def initialize
    super
    @email_on_review = true
    @email_on_submission = true
    @email_on_review_of_review = true
   end
end