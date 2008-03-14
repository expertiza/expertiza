class ReviewMapping < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :reviewer, :class_name => "User", :foreign_key => "reviewer_id"
  has_many :reviews
  has_many :review_of_review_mappings
  
  ##feedback added
  def self.assign_reviewers(assignment_id, num_reviews, num_review_of_reviews, mapping_strategy)
    @authors = Participant.find(:all, :conditions => ['assignment_id = ? and submit_allowed=1', assignment_id])
    @reviewers = Participant.find(:all, :conditions => ['assignment_id = ? and review_allowed=1', assignment_id])
    @assignments = Assignment.find_by_id(assignment_id)
    puts 'authors.size = ', @authors.size
    puts 'reviewers.size = ', @reviewers.size
    
    due_date = DueDate.find(:all,:conditions => ["assignment_id = ?",assignment_id], :order => "round DESC", :limit =>1)
    @round = 1
    if (due_date[0] && !due_date[0].round.nil?)
      @round = due_date[0].round - 1
    end
    puts "rounds = ",@round
    for round_num in 1..@round
      puts "round# ",round_num
      stride = 1 # get_rel_prime(num_reviews, @reviewers.size)
      for i in 0 .. @reviewers.size - 1
        current_reviewer_candidate = i
        current_author_candidate = current_reviewer_candidate
        for j in 0 .. (@reviewers.size * num_reviews / @authors.size) - 1  # This method potentially assigns authors different #s of reviews, if limit is non-integer
          current_author_candidate = (current_author_candidate + stride) % @authors.size
            if (@assignments.team_assignment != true)
              ReviewMapping.create(:author_id => @authors[current_author_candidate].user_id, :reviewer_id => @reviewers[i].user_id, :assignment_id => assignment_id, :round => round_num)
            else
              team = TeamsUser.find(:first,:conditions=>["user_id =? and team_id in (select id from teams where assignment_id=?)", @authors[current_author_candidate].user_id, assignment_id]).team_id
              ReviewMapping.create(:author_id => @authors[current_author_candidate].user_id, :reviewer_id => @reviewers[i].user_id, :assignment_id => assignment_id, :round => round_num, :team_id=>team)
            end  
            ##
            puts 'Review Mapping created'
            ##
        end
      end
    end
  end
  ##
  
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
      team_users = TeamsUser.find_by_sql("select * from teams_users where team_id = " + self.team_id.to_s)
      for member in team_users
        author_id << member.user_id
      end
    else
      author_ids << self.author_id
    end
    return author_ids
  end
end