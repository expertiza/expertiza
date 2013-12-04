require_relative '../spec_helper'

describe ScoreCache do
  it "gets_class_scores" do
    class_statistics=Array.new
    class_statistics[0]=93.41577777777778
    class_statistics[1]=43.0
    class_statistics[2]=100.0
    expect(ScoreCache.get_class_scores(2944)).to eql(class_statistics)
  end

  it "my_reviews" do
    actual_reviews_remaining=[0,2]

    expect(ScoreCache.my_reviews(3223)).to eql(actual_reviews_remaining)

  end

  it "my_metareviews" do
    actual_metareviews_remaining=[0,1]

    expect(ScoreCache.my_metareviews(3223)).to eql(actual_metareviews_remaining)

  end

end