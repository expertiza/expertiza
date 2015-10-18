require 'factory_girl_rails'

FactoryGirl.define do
  #instructor for assignment
  factory :user do
    name "test"
    fullname "test_user"
    email "sjolly@ncsu.edu"
    parent_id =1
    is_new_user=true
  end

  #team for assignment
  
  factory :team do
      name 'Team1'
      parent_id 2
      type 'g'
      comments_for_advertisement 'good'
      advertise_for_partner true
  end

  factory :wiki_type do
      name 'wiki_1a'
  end
  factory :assignment do
          name 'OSS'
          submitter_count 3
          course_id 1
          private false
          num_reviews 2
          association :instructor, factory: :user
          association :wiki_type, factory: :wiki_type
          #after(:create) {|assignment| assignment.add_user(:user)}
          #after(:create) {|assignment| assignment.add_team(:team)}¬    end
  end
  end
