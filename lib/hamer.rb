module Hamer
  def self.calculate_weighted_scores_and_reputation(submissions, reviewers)

    # Initialize weights
    submissions.each {|s| s.reviews.each {|review| review.weight = 1}}

    # Iterate until convergence
    iterations = 0
    begin
      # Store previous weights to determine convergence
      previous_weights = submissions.map{|s|s.reviews.map(&:weight)}
      # Reset reviewer inaccuracy
      reviewers.each {|reviewer| reviewer.inaccuracy = 0 }

      # Pass 1: Calculate reviewer distance from average (inaccuracy)
      submissions.each do |submission|
        # Find current weighted average
        reviews = submission.reviews
        weighted_scores = reviews.map{|r|r.score * r.weight}
        total_weight = reviews.map(&:weight).sum.to_f
        weighted_average = weighted_scores.sum.to_f/total_weight

        # Add to the reviewers' inaccuracy average
        reviews.each do |review|
          reviewer = review.reviewer
          review_inaccuracy = (review.score - weighted_average) ** 2
          reviewer.inaccuracy += review_inaccuracy / reviewer.reviews.count
        end
      end

      average_inaccuracy = reviewers.map(&:inaccuracy).sum / reviewers.size
      # Pass 2: Use reviewer inaccuracy to calculate new review score weights
      submissions.each do |submission|
        submission.reviews.each do |review|
          weight = 1
          weight = average_inaccuracy / review.reviewer.inaccuracy unless review.reviewer.inaccuracy == 0
          if weight > 2
            weight = 2 + Math.log10(weight - 1)
          end
          review.weight = weight
        end
      end
      iterations += 1
    end while !converged?(previous_weights, submissions.map{|s|s.reviews.map(&:weight)})

    #puts "Weighted Scores : #{submissions.map(&:weighted_score)}"
    #puts "Weights : #{reviewers.map(&:weight)}"
    submissions_map = Hash.new
    submissions.each do |submission|
      submissions_map[submission.id] = submission
    end
    return {:iterations => iterations, :submissions => submissions_map, :reviewers => reviewers}
  end


  def self.calculate_weighted_scores_and_reputation_for_a_submission(submissions, reviewers, submission)
    weighted_scores = calculate_weighted_scores_and_reputation(submissions, reviewers)
    weighted_submissions = weighted_scores[:submissions]
    return weighted_submissions[submission.id]
=begin
    weighted_submissions.each do |weighted_submission|
      return weighted_submission if weighted_submission.id == submission.id
    end
=end
  end


  # Ensure all numbers in lists a and b are equal
  # Options: :precision => Number of digits to round to
  def self.converged?(a, b, options={:precision => 2})
    raise "a and b must be the same size" unless a.size == b.size
    a.flatten!
    b.flatten!

    p = options[:precision]
    a.each_with_index do |num, i|
      return false unless num.to_f.round(p) == b[i].to_f.round(p)
    end
    return true
  end

  #Convert submissions from the active record format to the format required by our(Hamer's) algorithm
  def get_submission_objects(submissions)
    return @submission_objects if @submission_objects
    @submission_objects = []
    submissions.each do |submission|
      @submission_objects << Submission.new do |s|
        s.id = submission.id
        s.submission = submission
        s.reviews = submission.get_reviews.map do |review|
          Review.new do |r|
            r.id = review.id
            r.submission = s
            r.reviewer = @reviewers_map[review.map.reviewer.user.name]
            r.reviewer.reviews ||= []
            r.reviewer.reviews << r
            r.score = review.get_total_score.to_f/ review.scores.length
          end
        end
      end
    end
    return @submission_objects
  end

  #Convert reviewers from the active record format to the format required by our(Hamer's) algorithm
  def get_reviewer_objects(reviewers)
    return @reviewer_objects if @reviewer_objects
    @reviewer_objects = []
    @reviewers_map = {}
    reviewers.each do |reviewer|
      r = Reviewer.new(reviewer.name)
      @reviewers_map[reviewer.name] = r
      @reviewer_objects << r
    end
    return @reviewer_objects
  end

  module Mock
    def initialize(&block)
      block.call(self) if block
    end
  end

  class Submission
    include Mock
    attr_accessor :reviews
    attr_accessor :id
    attr_accessor :submission
    def weighted_score
      total_weight = 0.to_f

      points = reviews.map do |review|


        total_weight += review.weight
        review.weight * review.score
      end
      total_points = points.sum
      total_points / total_weight
    end
  end

  class Review
    include Mock
    attr_accessor :id
    attr_accessor :submission
    attr_accessor :reviewer
    attr_accessor :score
    attr_accessor :weight
  end

  class Reviewer
    include Mock
    attr_accessor :name
    attr_accessor :reviews
    attr_accessor :inaccuracy

    def inspect
      "#<#{self.class.name} name=\"#{name}\">"
    end

    def initialize(name)
      self.name = name
      self.inaccuracy = 0
    end

    def weight
      reviews.first.weight
    end
  end
end