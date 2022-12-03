module AssignmentHelper
  def assignment1
    Assignment.where(name: 'assignment1').first || Assignment.new('id' => '101',
                                                                  'name' => 'My assignment',
                                                                  'bid_for_topics' => 1)
  end
end
