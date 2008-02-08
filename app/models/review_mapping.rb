class ReviewMapping < ActiveRecord::Base
  belongs_to :assignment
  has_many :reviews
  has_many :review_of_review_mappings
  
  def self.assign_reviewers(assignment_id, num_reviews, num_review_of_reviews)
    @authors = Participant.find(:all, :conditions => ['assignment_id = ? and submit_allowed=1', assignment_id])
    @reviewers = Participant.find(:all, :conditions => ['assignment_id = ? and review_allowed=1', assignment_id])
    puts 'authors.size = ', @authors.size
    puts 'reviewers.size = ', @reviewers.size
    
    stride = 1 # get_rel_prime(num_reviews, @reviewers.size)
    for i in 0 .. @reviewers.size - 1
      current_reviewer_candidate = i
      current_author_candidate = current_reviewer_candidate
      for j in 0 .. (@reviewers.size * num_reviews / @authors.size) - 1  # This method potentially assigns authors different #s of reviews, if limit is non-integer
        current_author_candidate = (current_author_candidate + stride) % @authors.size
        ReviewMapping.create(:author_id => @authors[current_author_candidate].user_id, :reviewer_id => @reviewers[i].user_id, :assignment_id => assignment_id)
      end
    end
  end
  
  def self.import_reviewers(file,assignment)
    File.open(file, "r") do |infile|
        while (rline = infile.gets)
          line_split = rline.split(",")
          author = User.find_by_name(line_split[0].strip)
          if (Participant.find(:all,{:conditions => ['user_id=? AND assignment_id=?', author.id, assignment.id]}).size > 0)
            for i in 1 .. line_split.size - 1              
              reviewer = User.find_by_name(line_split[i].strip)
              if (Participant.find(:all,{:conditions => ['user_id=? AND assignment_id=?', reviewer.id, assignment.id]}).size > 0)
                ReviewMapping.create(:author_id => author.id, :reviewer_id => reviewer.id, :assignment_id => assignment.id)
              end
            end
          end
        end
    end
  end
  
  #return an array of authors for this mapping
  #ajbudlon, sept 07, 2007  
  def get_author_ids
    author_ids = Array.new
    if (self.team_id)
      team_users = TeamUser.find_by_sql("select * from team_users where team_id = " + self.team_id.to_s)
      for member in team_users
        author_id << member.user_id
      end
    else
      author_ids << self.author_id
    end
    return author_ids
  end
end