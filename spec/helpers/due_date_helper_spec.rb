describe DueDateHelper do
	before(:each) do
	  @deadline_type = build(:deadline_type)
	  @deadline_right = build(:deadline_right)
	  @assignment_due_date = build(:assignment_due_date, deadline_type: @deadline_type,
														 submission_allowed_id: @deadline_right.id, review_allowed_id: @deadline_right.id,
														 review_of_review_allowed_id: @deadline_right.id, due_at: '2015-12-30 23:30:12')
  
	  @due_dates = []
	  10.times.each do |n|
		date = if n == 1 || n == 9
				 nil
			   else
				 Time.zone.now - 60 * n
			   end
		@due_dates << build(:assignment_due_date, due_at: date)
	  end
	end
  
	it 'sort duedate records' do
	  sorted_due_dates = @due_dates
	  expect(sorted_due_dates.each_cons(2).all? { |m1, m2| (m1.due_at <=> m2.due_at) != 1 }).to eql false
  
	  sorted_due_dates = DueDateHelper.deadline_sort(@due_dates)
	  expect(sorted_due_dates.each_cons(2).all? { |m1, m2| (m1.due_at <=> m2.due_at) != 1 }).to eql true
	end
  
	describe '#done_in_assignment_round' do
	  it 'return 0 when no response map' do
		response = ReviewResponseMap.create
		response.type = 'ResponseMap'
		response.save
		expect(DueDateHelper.done_in_assignment_round(1, response)).to eql 0
	  end
  
	  it 'return round 1 for single round' do
		response = ReviewResponseMap.create
		expect(DueDateHelper.done_in_assignment_round(@assignment_due_date.parent_id, response)).to eql 1
	  end
	end
  end
  