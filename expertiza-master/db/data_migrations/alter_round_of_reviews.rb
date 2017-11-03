class AlterRoundOfReviews
  def self.run!
    puts 'AlterRoundOfReviews.run!'
    assignments = Assignment.all
    i =0
    while i < assignments.length
      submissions = assignments[i].find_due_dates('submission') + assignments[i].find_due_dates('resubmission')
      reviews = assignments[i].find_due_dates('review') + assignments[i].find_due_dates('rereview')
      assignments[i].rounds_of_reviews = [assignments[i].rounds_of_reviews, submissions.count, reviews.count].max
      assignments[i].save
      i=i+1;
    end
  end
end
