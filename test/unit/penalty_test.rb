require 'test_helper'

class PenaltyTest < ActiveSupport::TestCase
  fixtures :penalties

  def setup
    @participant_penalty1 = Penalty.find(penalties(:one))
    @participant_penalty2 = Penalty.find(penalties(:two))
  end

  def test_validate_presence_of_user_id
   # assert !(Penalty.create(:user_id => nil).valid?)
     @participant_penalty1.user_id=nil
     assert  !@participant_penalty1.valid?
  end

   def test_presence_of_assignment_id
    #assert !(Penalty.create(:assignment_id => "assasas").valid?)
     @participant_penalty1.assignment_id=nil
     assert  !@participant_penalty1.valid?
  end

  def test_validate_presence_of_assignment_id
    assert !(Penalty.create(:assignment_id => nil).valid?)
  end

  def test_combined_uniqueness_of_participant_and_assignment
    @participant_penalty1.user_id=1;
    @participant_penalty1.assignment_id=2;
    @participant_penalty1.save
    @participant_penalty2.user_id=1;
    @participant_penalty2.assignment_id=2;
    assert !@participant_penalty2.save
  end

  def test_validate_numericality_of_penalty_mins
      #assert !(Penalty.create(:penalty_mins_accumulated => "assasas").valid?)
       @participant_penalty3=Penalty.new
       @participant_penalty3=@participant_penalty1
       @participant_penalty3.assignment_id=100
      @participant_penalty3.penalty_mins_accumulated="abserser"
     assert  !@participant_penalty3.save
  end

def test_validate_numericality_of_penalty_score
      # assert !(Penalty.create(:penalty_score => "dfhfhg").valid?)
       @participant_penalty3=Penalty.new
       @participant_penalty3=@participant_penalty1
       @participant_penalty3.assignment_id=100
      @participant_penalty3.penalty_score="stupid"
     assert  !@participant_penalty3.save
end

def test_validate_max_penalty_score
      @participant_penalty3=Penalty.new
       @participant_penalty3=@participant_penalty1
       @participant_penalty3.assignment_id=100
     @participant_penalty3.penalty_score=1500
     assert  !@participant_penalty3.save
       #assert !(Penalty.create(:penalty_score => 150).valid?)
end

def test_validate_min_penalty_score
      @participant_penalty3=Penalty.new
       @participant_penalty3=@participant_penalty1
       @participant_penalty3.assignment_id=100
     @participant_penalty3.penalty_score=-1500
     assert  !@participant_penalty3.save
       #assert !(Penalty.create(:penalty_score => 150).valid?)
end

  def test_validate_presence_of_revieweeid_when_reviewed_at_is_present
       @participant_penalty3=Penalty.new
       @participant_penalty3=@participant_penalty1
       @participant_penalty3.assignment_id=100
       @participant_penalty3.reviewee1_id=nil
     assert  !@participant_penalty3.save

end
     def test_validate_presence_of_metarevieweeid_when_metareviewed_at_is_present
       @participant_penalty3=Penalty.new
       @participant_penalty3=@participant_penalty1
       @participant_penalty3.assignment_id=100
       @participant_penalty3.metareviewee1_id=nil
     assert  !@participant_penalty3.save
     end

  def test_validate_presence_of_reviewed1_at_when_reviewed2_at_is_present
       @participant_penalty3=Penalty.new
       @participant_penalty3=@participant_penalty1
       @participant_penalty3.assignment_id=101
       @participant_penalty3.reviewed1_at=nil
     assert  !@participant_penalty3.valid?
  end

  def test_validate_presence_of_metareviewed1_at_when_metareviewed2_at_is_present
       @participant_penalty3=Penalty.new
       @participant_penalty3=@participant_penalty1
       @participant_penalty3.assignment_id=101
       @participant_penalty3.metareviewed1_at=nil
     assert  !@participant_penalty3.valid?
  end

def test_validate_min_value_of_penalty_accumulated_min
      @participant_penalty3=Penalty.new
       @participant_penalty3=@participant_penalty1
       @participant_penalty3.assignment_id=100
     @participant_penalty3.penalty_mins_accumulated=-1000
     assert  !@participant_penalty3.save
       #assert !(Penalty.create(:penalty_score => 150).valid?)
end


  end

