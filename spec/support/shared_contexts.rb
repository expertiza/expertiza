RSpec.shared_context 'with_deadline_setup' do
  before(:each) do
    @deadline_type = build(:deadline_type)
    @deadline_right = build(:deadline_right)
    @assignment_due_date = build(
      :assignment_due_date,
      deadline_type: @deadline_type,
      submission_allowed_id: @deadline_right.id,
      review_allowed_id: @deadline_right.id,
      review_of_review_allowed_id: @deadline_right.id,
      due_at: '2015-12-30 23:30:12'
    )

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
end
