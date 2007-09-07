class Pgmailer < ActionMailer::Base
 
#Creates message content
  def message(recip,object,location,type,review_scores,ror_review_scores)
     @subject = "An new "+type+" is available for "+object.name
     @recipients = recip.email
     @from = "pg-server@ncsu.edu"
     @body["assignment"] = assignment;
     @body["type"] = type
     @body["location"] = location 
     @body["review_scores"] = review_scores
     @body["ror_review_scores"] = ror_review_scores
     if recip.fullname.index(",")
        start_ss = recip.fullname.index(",")+2
     else
        start_ss = 0
     end
     @body["user"] = recip.fullname[start_ss, recip.fullname.length]
     @sent_on = Time.now 
  end
end
