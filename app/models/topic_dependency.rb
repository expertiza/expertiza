class TopicDependency < ActiveRecord::Base
  serialize :dependent_on

  def self.save_dependency(topics)
    topics.each {|topic|
      #topic[0] => topic_id and topic[1] => dependent_on
      topic_dependency = TopicDependency.find_by_topic_id(topic[0])
      if topic_dependency == nil
        topic_dependency = TopicDependency.new
        topic_dependency.topic_id = topic[0]
      end      
      dependency_list = topic[1].collect{|i| i.to_i}
      topic_dependency.dependent_on = dependency_list
      topic_dependency.save
    }
  end

end
