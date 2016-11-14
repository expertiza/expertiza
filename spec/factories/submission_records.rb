FactoryGirl.define do
  factory :submission_record do |record|
    record.team_id 666
    record.operation 'create'
    record.user 'student1234'
    record.content 'www.wolfware.edu'
    record.created_at Time.now
  end
end
