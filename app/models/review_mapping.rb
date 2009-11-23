class ReviewMapping < ActiveRecord::Base
  belongs_to :assignment, :class_name => "Assignment", :foreign_key => "reviewed_object_id" 
  belongs_to :reviewer, :class_name => "Participant", :foreign_key => "reviewer_id"
  has_one :review, :class_name => "Review", :foreign_key => "mapping_id" 
  has_many :review_of_review_mappings, :class_name => "ReviewOfReviewMapping", :foreign_key => "reviewed_object_id"
   
  def delete(force = nil)
    if self.review != nil and !force
      raise "A review exists for this mapping."
    elsif self.review != nil
      self.review.delete
    end
    
    rmappings = self.review_of_review_mappings
    rmappings.each{
      |rmapping|
      rmapping.delete(force)
    }
    self.destroy
  end    
  
  # Removed round information until fully implemented
  def self.assign_reviewers(assignment_id, num_reviews, num_review_of_reviews, mapping_strategy)  
      assignment = Assignment.find_by_id(assignment_id)
      #round = max_review_round_allowed(assignment_id) 
      #for round_num in 1..round
      
        if (assignment.team_assignment)      
          #assign_reviewers_for_team(assignment_id, num_reviews, round_num)
          assign_reviewers_for_team(assignment_id, num_reviews, 1)
        else          
          #assign_individual_reviewer(assignment_id, num_reviews, round_num) 
          assign_individual_reviewer(assignment_id, num_reviews, 1) 
        end
      #end   
  end
  
  def self.import(row,session,id)    
    if row.length < 2
       raise ArgumentError, "Not enough items" 
    end
    
    assignment = Assignment.find(id)
    if assignment == nil
      raise ImportError, "The assignment with id \"#{id}\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
    end
    index = 1
    while index < row.length
      user = User.find_by_name(row[index].to_s.strip)      
      if user == nil
        raise ImportError, "The user account for the reviewer \"#{row[index]}\" was not found. <a href='/users/new'>Create</a> this user?"
      end
      reviewer = AssignmentParticipant.find_by_user_id(user.id)
      if reviewer == nil
        raise ImportError, "The reviewer \"#{row[index]}\" is not a participant in this assignment. <a href='/users/new'>Register</a> this user as a participant?"
      end           
      if assignment.team_assignment
         reviewee = AssignmentTeam.find_by_name_and_parent_id(row[0].to_s.strip, assignment.id)
         if reviewee == nil
           raise ImportError, "The author \"#{row[0].to_s.strip}\" was not found. <a href='/users/new'>Create</a> this user?"                   
         end
         existing = TeamReviewMapping.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?',reviewee.id, reviewer.id]) 
         if existing.nil?
           TeamReviewMapping.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => assignment.id)
         end
      else
         puser = User.find_by_name(row[0].to_s.strip)
         if user == nil
           raise ImportError, "The user account for the reviewee \"#{row[0]}\" was not found. <a href='/users/new'>Create</a> this user?"
         end
         reviewee = AssignmentParticipant.find_by_user_id_and_parent_id(puser.id, assignment.id)
         if reviewee == nil
           raise ImportError, "The author \"#{row[0].to_s.strip}\" was not found. <a href='/users/new'>Create</a> this user?"                   
         end  
         existing = ParticipantReviewMapping.find(:first, :conditions => ['reviewee_id = ? and reviewer_id = ?',reviewee.id, reviewer.id])
         if existing.nil?
           ParticipantReviewMapping.create(:reviewer_id => reviewer.id, :reviewee_id => reviewee.id, :reviewed_object_id => assignment.id)
         end         
      end
      index += 1
    end 
  end  
  
  # provide export functionality for Review Mappings
  def self.export(csv,parent_id)
    mappings = find(:all, :conditions => ['reviewed_object_id=?',parent_id])
    mappings.sort!{|a,b| a.reviewee.name <=> b.reviewee.name} 
    mappings.each{
          |map|          
          csv << [
            map.reviewee.name,
            map.reviewer.name
          ]
      } 
  end
  
  def self.get_export_fields
    fields = ["contributor","reviewed by"]
    return fields            
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
    @teams = Team.find(:all, :conditions=>['parent_id = ?', assignment_id])
    @t = @teams.size if @teams != nil # indicates the num of teams
    @students = AssignmentParticipant.find_all_by_parent_id(assignment_id)
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
  end
  
  def assign_reviewers_of_review (assignment_id, num_review_of_reviews)
    
  end
  
  def self.save_mapping (assignment_id, round_num)
    i = 0
    j = 0
    for student in @students do
      for team in @teams do
        if (@team_review[i][j] == 1)
          TeamReviewMapping.create(:reviewer_id => student.id, :reviewed_object_id => assignment_id, :reviewee_id =>team.id)     
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
      if student.team != nil    
        for team in @teams do
          if (student.team.id == team.id)
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
        ParticipantReviewMapping.create(:reviewee_id => authors[current_author_candidate].id, :reviewer_id => reviewers[i].id, :reviewed_object_id => assignment_id)
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
    @rows_zeros = Array.new(@n, 0) # keeps the track of zeros in each row
    @rows_ones = Array.new(@n, 0) # keeps the track of ones in each row
    @columns_zeros = Array.new(@t, 0)# keeps the track of zeros in each column
    @columns_ones = Array.new(@t, 0) # keeps the track of ones in each column
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
