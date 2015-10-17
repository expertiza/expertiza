require 'factory_girl_rails'

FactoryGirl.define do
    factory :assignment do
          name 'OSS'
          submitter_count 3
          course_id 1
          instructor_id 2
          private false
          num_reviews 2

    end
end
