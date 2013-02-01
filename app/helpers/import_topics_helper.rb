require 'csv'

module ImportTopicsHelper
 
  def self.define_attributes(row)
    attributes = {}
    attributes["topic_identifier"] = row[0].strip
    attributes["topic_name"] = row[1].strip
    attributes["max_choosers"] = row[2]
    attributes["category"] = row[3].strip
    attributes
  end

  def self.create_new_sign_up_topic(attributes, session)
    sign_up_topic = SignUpTopic.new(attributes)
    sign_up_topic.assignment_id = session[:assignment_id]
    sign_up_topic.save   
    #sign_up_topic 
  end
end


