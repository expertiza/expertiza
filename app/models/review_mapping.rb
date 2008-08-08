class ReviewMapping < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :team, :class_name => "Team", :foreign_key => "team_id"
  belongs_to :reviewer, :class_name => "User", :foreign_key => "reviewer_id"
  has_many :reviews
  has_many :review_of_review_mappings 
    
  def delete
    review = Review.find(:all, :conditions => ['review_mapping_id = ?',self.id])    
    if review.length > 0
      raise "At least one review has already been performed."
    end  
    mappings = ReviewOfReviewMapping.find(:all, :conditions => ['review_mapping_id = ?',self.id])
    mappings.each { |mapping| mapping.delete  }
    self.destroy
  end
    
  def self.get_mappings(assignment_id,contributor_id)
    assignment = Assignment.find(assignment_id)
    if assignment.team_assignment
      query = 'team_id = ? and assignment_id = ?'      
    else
      query = 'author_id = ? and assignment_id = ?'
    end
    return ReviewMapping.find(:all, :conditions => [query,contributor_id,assignment_id])
  end
  
  def self.assign_reviewers(assignment_id, num_reviews, num_review_of_reviews, mapping_strategy)  
      assignment = Assignment.find_by_id(assignment_id)
      round = max_review_round_allowed(assignment_id) 
      for round_num in 1..round
        if (!assignment.team_assignment)        
          assign_individual_reviewer(assignment_id, num_reviews, round_num) 
        else
          assign_reviewers_for_team(assignment_id, num_reviews, round_num)
        end
      end   
  end
  
  def get_creator_id
    assignment = Assignment.find(self.assignment_id)
    if assignment.team_assignment
      return team_id
    else
      return author_id
    end
  end
  
  def self.import(row,session,id)    
    if row.length < 2
       raise ArgumentError, "Not enough items" 
    end
    
    assignment = Assignment.find(id)
    if assignment == nil
      raise ImportError, "The assignment with id \""+id.to_s+"\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end
    index = 1
    while index < row.length
      reviewer = User.find_by_name(row[index].to_s.strip)  
      if reviewer == nil
        raise ImportError, "The reviewer \""+row[index].to_s+"\" was not found. <a href='/users/new'>Create</a> this user?"
      end
          
      mapping = ReviewMapping.new
      if assignment.team_assignment
         author = Team.find(:first, :conditions => ['name = ? and assignment_id = ?',row[0].to_s.strip, assignment.id])
         if author == nil
           raise ImportError, "The author \""+row[0].to_s.strip+"\" was not found. <a href='/users/new'>Create</a> this user?"                   
         end
         existing = ReviewMapping.find(:all, :conditions => ['assignment_id = ? and team_id = ? and reviewer_id = ?',assignment.id, author.id, reviewer.id])
         mapping.team_id = author.id
      else
         author = User.find_by_name(row[0].to_s.strip)
         if author == nil
           raise ImportError, "The author \""+row[0].to_s.strip+"\" was not found. <a href='/users/new'>Create</a> this user?"                   
         end  
         existing = ReviewMapping.find(:all, :conditions => ['assignment_id = ? and author_id = ? and reviewer_id = ?',assignment.id, author.id, reviewer.id])         
         mapping.author_id = author.id
      end
      mapping.reviewer_id = reviewer.id
      mapping.assignment_id = assignment.id
      if existing.size == 0
        mapping.save
      end
      index += 1
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
  
  private
  class CellDescriptor
    attr_accessor :row
    attr_accessor :column
    attr_accessor :value
    def initialize (row, column, value)
      @row, @column, @value = row, column, value
    end
  end
  
  def self.assign_reviewers_for_team (assignment_id, num_reviews, round_num)
    @r = num_reviews # indicates the num of reviews to be done
    @teams = Team.find(:all, :conditions=>['assignment_id = ?', assignment_id])
    @t = @teams.size if @teams != nil # indicates the num of teams
    @students = TeamsUser.find(:all, :conditions => ['team_id in (select id from teams where assignment_id= ?)', assignment_id])
    @n = @students.size if @students != nil # indicates the num of students participating in the assignment
    @team_review = Array.new(@n).map!{ Array.new(@t)} 
    populate_review_matrix() # the matrix that maps reviewers and teams
    init()
    # calculates the ones and zeros in each row and column
    populate_supporting_matrices() 
    for i in 0..@n-1 do
      if (row_enough_ones(i) == 1)
        break
      end
      for j in 0..@t-1 do
        failed_mapping_col_wise = false;
        successful_mapping_col_wise = false;
        failed_mapping_row_wise = false;
        successful_mapping_row_wise = false;
        if (@team_review[i][j] == -1)
          @team_review[i][j] = 1
          @rows_ones[i] += 1
          @columns_ones[j] += 1
          if (col_enough_ones(j) == 1) # 
            if (toggle_col(j))
              failed_mapping_col_wise = false              
            end
            if (!failed_mapping_col_wise)
             successful_mapping_col_wise = true 
            end
          else 
            successful_mapping_col_wise = true
          end
          # setting flags for checking failed case
          if(failed_mapping_col_wise)
            successful_mapping_col_wise = false
          end
          if (successful_mapping_col_wise)
              failed_mapping_col_wise = false
          end
          
          if ((row_enough_ones(i) == 1))
            # backup the cells which may be needed to restore later if choice is invalid
            for k in 0..@t-1 do # for each remaining -1 in this row
              if (@team_review[i][k]==-1)
                change_cell(i, k, 0); 
                # if we do this assignment, will it force some students to do 1 too many reviews
                if (col_enough_zeros(k) == 1)
                  if (!toggle_zeros_col(k))
                    failed_mapping_row_wise = true
                  end
                end
              end
            end
          else
            successful_mapping_row_wise = true
          end
          # setting flags
          if(failed_mapping_row_wise)
            successful_mapping_row_wise = false
          end
          if (successful_mapping_row_wise)
              failed_mapping_row_wise = false
          end
          
          if (failed_mapping_col_wise || failed_mapping_row_wise)
            restore()
            populate_supporting_matrices()
          end
        end
      end
    end
    save_mapping(assignment_id, round_num)
    print_matrix()
  end
  
  def self.save_mapping (assignment_id, round_num)
    i = 0
    j = 0
    for student in @students do
      for team in @teams do
        if (@team_review[i][j] == 1)
          ReviewMapping.create(:reviewer_id => student.user_id, :assignment_id => assignment_id, :team_id=>team.id, :round => round_num)     
        end
        j += 1  
      end
      j = 0
      i += 1
    end
  end
  
  def self.change_cell (row, column, value)
    old_value = @team_review[row][column]
    @team_review[row][column] = value;
    if (value == 0)
      @rows_zeros[row]+=1;
      @columns_zeros[column]+=1;
    elsif(value == 1)
      @rows_ones[row]+=1;
      @columns_ones[column]+=1;
    end
    cell = CellDescriptor.new(row, column, old_value)
    @changed_cells << cell
  end
  
  def self.populate_review_matrix ()
    i = 0
    j = 0
    for student in @students do
      for team in @teams do
        if (student.team_id == team.id)
          @team_review[i][j] = 0;   
        else
          @team_review[i][j] = -1;
        end
        j += 1  
      end
      j = 0
      i += 1
    end
    
  end
  
  def self.print_matrix()
    for i in 0..@n-1 do
      for j in 0..@t-1 do
        logger.info " Initial @@@@@@@!!!!!!!!!!!!)))))))))))) team_review["+i.to_s+"]["+j.to_s+"] = "+@team_review[i][j].to_s
      end
    end
  end
  
  def self.populate_supporting_matrices ()
    # populating first row wise
    for i in 0..@n-1 do
      for j in 0..@t-1 do
        if (@team_review[i][j] == 0) 
          @rows_zeros[i] += 1
        elsif (@team_review[i][j] == 1)
          @rows_ones[i] += 1
        end
      end
    end    
    # populating column wise
    for j in 0..@t-1 do
      for i in 0..@n-1 do
        if (@team_review[i][j] == 0) 
          @columns_zeros[j] += 1
        elsif (@team_review[i][j] == 1)
          @columns_ones[j] += 1
        end
      end
    end
    for i in 0..@n-1 do
      logger.info "@@@@@@@!!!!!!!!!!!!%%%%%%%%%%%%% ROWS_zeros["+i.to_s+"] = "+@rows_zeros[i].to_s
      logger.info "@@@@@@@!!!!!!!!!!!!%%%%%%%%%%%%% ROWS_ones["+i.to_s+"] = "+@rows_ones[i].to_s
    end
    for i in 0..@t-1 do
      logger.info "@@@@@@@!!!!!!!!!!!!%%%%%%%%%%%%% COLUMNS_zeros["+i.to_s+"] = "+@columns_zeros[i].to_s
      logger.info "@@@@@@@!!!!!!!!!!!!%%%%%%%%%%%%% COLUMNS_ones["+i.to_s+"] = "+@columns_ones[i].to_s
    end
  end
  
  def self.assign_individual_reviewer (assignment_id,num_reviews, round_num)
    stride = 1
    authors = AssignmentParticipant.find(:all, :conditions => ['parent_id = ? and submit_allowed=1', assignment_id])
    reviewers = AssignmentParticipant.find(:all, :conditions => ['parent_id = ? and review_allowed=1', assignment_id])
    if authors.size == 0 or reviewers.size == 0 
      raise "No participants available for assignment"
    end
    for i in 0 .. reviewers.size - 1
      current_reviewer_candidate = i
      current_author_candidate = current_reviewer_candidate
      for j in 0 .. (reviewers.size * num_reviews / authors.size) - 1  # This method potentially assigns authors different #s of reviews, if limit is non-integer
        current_author_candidate = (current_author_candidate + stride) % authors.size   
        ReviewMapping.create(:author_id => authors[current_author_candidate].user_id, :reviewer_id => reviewers[i].user_id, :assignment_id => assignment_id, :round => round_num)
      end
    end
  end
  
  def self.max_review_round_allowed(assignment_id)
    due_date = DueDate.find(:all,:conditions => ["assignment_id = ?",assignment_id], :order => "round DESC", :limit =>1)
    round = 1
    if (due_date[0] && !due_date[0].round.nil?)      
      round = due_date[0].round - 1      
    end
    return round
  end
  
  def self.init()
    # @backup_team_review = Array.new(@n).map!{ Array.new(@t)}
    @rows_zeros = Array.new(@n, 0) # keeps the track of zeros in each row
    # @backup_rows_zeros = Array.new(@n, 0)
    @rows_ones = Array.new(@n, 0) # keeps the track of ones in each row
    # @backup_rows_ones = Array.new(@n, 0)
    @columns_zeros = Array.new(@t, 0)# keeps the track of zeros in each column
    # @backup_columns_zeros = Array.new(@t, 0)
    @columns_ones = Array.new(@t, 0) # keeps the track of ones in each column
    # @backup_columns_ones = Array.new(@t, 0)
    @changed_cells = Array.new 
    @num_max = @r*@n % @t # the number of teams which can have the max. no. of reviewers
    @min = @r*@n/@t # the min # of reviewers a team can have
    # the max # of reviewers a team can have
    if (@num_max == 0) 
      @max = @min
      @num_max = @t
    else
      @max = @min+1
    end
    logger.info "####%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@ num_max = "+@num_max.to_s
    logger.info "####%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@ max = "+@max.to_s
    logger.info "####%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@ min = "+@min.to_s
  end
  def self.num_of_other_cols_with_max_num_of_ones (j)
    count = 0
    for k in 0..@columns_ones.length-1 do
      if (@columns_ones[k] == @max)
        count +=1
      end
    end
    count
  end
  
  def self.num_of_cols_with_max_num_of_zeros (j)
    count = 0
    for k in 0..@columns_ones.length-1 do
      if ((j != k) && @columns_ones[k] == (@n-@min))
        count +=1
      end
    end
    count
  end
  
  def self.restore ()
    for i in 0..@changed_cells.length-1 do
      @team_review[@changed_cells[i].row][@changed_cells[i].column] = @changed_cells[i].value;
    end
    @changed_cells.clear()
  end
  def self.row_enough_ones (i)
    # this function is used to toggle whether the student i has enough valid reviewers
    # returns 1 if # of '1's in row i is enough
    # returns -1 if # of '1's in row i is more than enough
    # returns 0 otherwise
    if (@rows_ones[i] == @r)
      return 1
    elsif (@rows_ones[i] > @r)
      return -1
    else
      return 0
    end
  end
  
  def self.row_enough_zeros (i)
    # this function is used to toggle whether the student i has enough invalid reviewers
    # returns 1 if # of '1's in row i is enough
    # returns -1 if # of '1's in row i is more than enough
    # returns 0 otherwise
    toggle_val = (@t-@r)
    logger.info "hererererererer @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ row_enough_zeros t-r = "+toggle_val.to_s
    logger.info "hererererererer @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ row_enough_zeros i of row_zeros = "+@rows_zeros[i].to_s
    if (@rows_zeros[i] == toggle_val)
      return 1
    elsif (@rows_zeros[i] > toggle_val)
      return -1
    else
      return 0
    end
  end
  
  def self.col_enough_ones (j)
    # this function is used to toggle whether team j has enough valid reviewers
    # returns 1 if # of '1's in column j is enough
    # returns -1 if # of '1's in column j is more than enough
    # returns 0 otherwise
    count =  num_of_other_cols_with_max_num_of_ones(j)
    if (count == @num_max)
      if (@columns_ones[j] == @min)
        return 1
      elsif (@columns_ones[j] > @min)
        return -1
      else
        return 0
      end
    elsif (count < @num_max)
      if (@columns_ones[j] == @max)
        return 1
      elsif (@columns_ones[j] > @max)
        return -1
      else
        return 0
      end
    end
    return -1
  end
  
  def self.col_enough_zeros (j)
    # this function is used to toggle whether team j has enough invalid reviewers
    # returns 1 if # of '1's in column j is enough
    # returns -1 if # of '1's in column j is more than enough
    # returns 0 otherwise
    count = num_of_cols_with_max_num_of_zeros(j)
    max_allowed_to_have_min_reviewers = @t-@num_max
    max_allowed_to_have_min_reviewers = @num_max if (max_allowed_to_have_min_reviewers == 0)
    if (count == max_allowed_to_have_min_reviewers)
      if (@columns_zeros[j] == (@n-@max))
        return 1
      elsif (@columns_zeros[j] > (@n-@max))
        return -1
      else 
        return 0  
      end
    elsif (count < max_allowed_to_have_min_reviewers)
      if (@columns_zeros[j] == (@n-@min))
        return 1
      elsif (@columns_zeros[j] > (@n-@min))
        return -1
      else 
        return 0  
      end
    end
    return -1  
  end
  def self.toggle_row (i)
    # Precondition: This reviewers has enough teams to review. So set remaining "-1"s to "0"s
    # Set remaining -1s to 0s
    for j in 0..@t-1 do
      if (@team_review[i][j]==-1)
        change_cell(i, j, 0)
        if (col_enough_zeros(j) == -1) 
          return false
        elsif (col_enough_zeros(j) == 1)
          val = toggle_zeros_col(j)
          if (!val)
           return false 
          end
        end
      end
    end
    return true
  end
  def self.toggle_zeros_row (i)
    # Precondition: This reviewers has n-r invalid mapping assignments.
    # Set remaining -1s to 1s
    for j in 0..@t-1 do
      if (@team_review[i][j]==-1)
        change_cell(i, j, 1)
        if (col_enough_ones(j) == -1) 
          return false
        elsif (col_enough_ones(j) == 1)
          val = toggle_col(j)
          if (!val)
           return false 
          end
        end
      end
    end
    return true
  end
  def self.toggle_col (j)
    # Precondition: This reviewers has enough teams to review. So set remaining "-1"s to "0"s
    # Set remaining -1s to 0s
    for i in 0..@n-1 do
      if (@team_review[i][j]==-1)
        change_cell(i, j, 0)
        if (row_enough_zeros(j) == -1) 
          return false
        elsif (row_enough_zeros(j) == 1)
          val = toggle_zeros_row(j)
          if (!val)
           return false 
          end
        end
      end
    end
    return true
  end
  def self.toggle_zeros_col (j)
    # Precondition: This reviewers has n-r invalid mapping assignments.
    # Set remaining -1s to 1s
    for i in 0..@n-1 do
      if (@team_review[i][j]==-1)
        change_cell(i, j, 1);
        if (row_enough_ones(j) == -1) 
          return false
        elsif (row_enough_ones(j) == 1)
          val = toggle_row(j)
          if (!val)
           return false 
          end
        end
      end
    end
    return true
  end
end
