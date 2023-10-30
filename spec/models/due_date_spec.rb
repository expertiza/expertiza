describe 'due_date_functions' do
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

  it 'due date factory created successfully' do
    expect(@assignment_due_date).to be_valid
  end

  it 'due dates created correctly' do
    expect(@due_dates.length).to be == 10
  end

  it 'due date flag is set' do
    expect(@assignment_due_date.flag).to be false
    @assignment_due_date.flag = true
    @assignment_due_date.save
    expect(@assignment_due_date.flag).to be true
  end

  it 'due at is valid datetime' do
    expect(@assignment_due_date.due_at_is_valid_datetime).to be nil
  end
end
