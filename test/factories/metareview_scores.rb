FactoryGirl.define do
  factory :metareview_score do
    review_id 1
    volume 1
    tone_negative 1.5
    tone_positive 1.5
    tone_neutral 1.5
    advisory 1.5
    problem_identification 1.5
    summative 1.5
    relevance 1.5
    coverage 1.5
    plagiarism ""
    last_updated ""
  end

end
