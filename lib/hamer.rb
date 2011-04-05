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
     
      # Pass 2: Use reviewer inaccuracy to calculate new review score weights
      average_inaccuracy = reviewers.map(&:inaccuracy).sum / reviewers.size
      submissions.each do |submission|
        submission.reviews.each do |review|
          weight = average_inaccuracy / review.reviewer.inaccuracy
          if weight > 2
            weight = 2 + Math.log10(weight - 1)
          end
          review.weight = weight
        end
      end
      iterations += 1
    end while !converged?(previous_weights, 
                          submissions.map{|s|s.reviews.map(&:weight)})

    return :iterations => iterations
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
end

module Hamer
  module Test
    module Mock
      def initialize(&block)
        block.call(self) if block
      end
    end

    class Submission
      include Mock
      attr_accessor :reviews

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
      end
      
      def weight
        reviews.first.weight
      end
    end

    def reviewers
      return @reviewers if @reviewers

      @reviewers = []
      @reviewers << Reviewer.new('A')
      @reviewers << Reviewer.new('B')
      @reviewers << Reviewer.new('C')
      @reviewers << Reviewer.new('D')
    end

    def submissions(rogue_score=5)
      return @submissions if @submissions

      @submissions = []

      scores = [[10,10,9,rogue_score],
                [3,2,4,rogue_score],
                [7,4,5,rogue_score],
                [6,4,5,rogue_score]]
      scores.each do |submission_scores|
        @submissions << Submission.new do |s|
          i = -1
          s.reviews = reviewers.map do |reviewer|
            Review.new do |r|
              r.submission = s
              r.reviewer = reviewer
              r.reviewer.reviews ||= []
              r.reviewer.reviews << r
              r.score = submission_scores[i += 1]
            end
          end
        end
      end

      return @submissions
    end
  end
end
