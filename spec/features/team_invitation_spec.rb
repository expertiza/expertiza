require 'rspec'

describe 'Team invitation testing' do
  before(:each) do
    # create assignment
    # add student to assignment
  end
  it 'should verify that list of students displayed does not have a team or has a single member team only' do
    # specify assignment team size to be greater than 1
    # create team for assignment and keep number of team members less than allowed
    # add few participants with no team to the assignment
    # add few participants with single member team to the assignment
    # verify number of rows are equal to valid participants size
    true.should == false
  end
  it 'should not display any invitation link if user does not have a team' do
    # make sure student doesn't have a team
    # verify no invitation links
    true.should == false
  end
  it 'should not display any invitation link if user\'s team is full' do
    # specify any assignment team size
    # create team for assignment and keep number of team members equal to allowed
    # verify no invitation links
    true.should == false
  end
  it 'should not display any invitation link if assignment deadline is over' do
    # change deadline of assignment to be in past
    # verify no invitation links
    true.should == false
  end
end