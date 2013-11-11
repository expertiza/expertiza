require 'spec_helper'

class StoryReader
  def read(story)
    "Epilog: #{story.tell}"
  end
end

describe Delayed::PerformableMethod do
  
  it "should ignore ActiveRecord::RecordNotFound errors because they are permanent" do
    story = Story.create :text => 'Once upon...'
    p = Delayed::PerformableMethod.new(story, :tell, [])
    story.destroy
    lambda { p.perform }.should_not raise_error
  end
  
  it "should store the object as string if its an active record" do
    story = Story.create :text => 'Once upon...'
    p = Delayed::PerformableMethod.new(story, :tell, [])
    p.class.should   == Delayed::PerformableMethod
    p.object.should  == "LOAD;Story;#{story.id}"
    p.method.should  == :tell
    p.args.should    == []
    p.perform.should == 'Once upon...'
  end
  
  it "should allow class methods to be called on ActiveRecord models" do
    p = Delayed::PerformableMethod.new(Story, :count, [])
    lambda { p.send(:load, p.object) }.should_not raise_error
  end
  
  it "should store arguments as string if they are active record objects" do
    story = Story.create :text => 'Once upon...'
    reader = StoryReader.new
    p = Delayed::PerformableMethod.new(reader, :read, [story])
    p.class.should   == Delayed::PerformableMethod
    p.method.should  == :read
    p.args.should    == ["LOAD;Story;#{story.id}"]
    p.perform.should == 'Epilog: Once upon...'
  end

  it "should not raise NoMethodError if target method is private" do
    clazz = Class.new do
      def private_method
      end
      private :private_method
    end
    lambda {
      Delayed::PerformableMethod.new(clazz.new, :private_method, [])
    }.should_not raise_error(NoMethodError)
  end
end
