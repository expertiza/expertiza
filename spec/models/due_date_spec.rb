# frozen_string_literal: true

require 'support/shared_contexts'

describe 'due_date_functions' do
  include_context 'with_deadline_setup'

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
