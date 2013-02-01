describe Raketab do
  it "should have defaults (0 for hour, minutes and * for days and months)" do
   Raketab.schedule { run 'test' }.tabs.should == '0 0 * * * test'
  end
  
  it "should set all the fields by name" do
    Raketab.schedule { run 'test', :min => 1 }.tabs.should     == "1 0 * * * test"
    Raketab.schedule { run 'test', :minute => 1 }.tabs.should  == "1 0 * * * test"
    Raketab.schedule { run 'test', :hour => 1 }.tabs.should    == "0 1 * * * test"
    Raketab.schedule { run 'test', :day => 1 }.tabs.should     == "0 0 1 * * test"
    Raketab.schedule { run 'test', :mday => 1 }.tabs.should    == "0 0 1 * * test"
    Raketab.schedule { run 'test', :month => 1 }.tabs.should   == "0 0 * 1 * test"
    Raketab.schedule { run 'test', :mon => 1 }.tabs.should     == "0 0 * 1 * test"
    Raketab.schedule { run 'test', :wday => 1 }.tabs.should    == "0 0 * * 1 test"
    Raketab.schedule { run 'test', :weekday => 1 }.tabs.should == "0 0 * * 1 test"
  end
  
  it "should set month and weekday fields by method name" do
    Raketab.schedule { run 'test', :month => january }.tabs.should == "0 0 * 1 * test"
    Raketab.schedule { run 'test', :mon => jan }.tabs.should       == "0 0 * 1 * test"
    Raketab.schedule { run 'test', :wday => monday }.tabs.should   == "0 0 * * 1 test"
    Raketab.schedule { run 'test', :weekday => mon }.tabs.should   == "0 0 * * 1 test"
  end

  it "should set the fields by comma string" do
    Raketab.schedule { run 'test', :minutes => '1,2,3' }.tabs.should  == "1,2,3 0 * * * test"
    Raketab.schedule { run 'test', :hours => '1,2,3' }.tabs.should    == "0 1,2,3 * * * test"
    Raketab.schedule { run 'test', :days => '1,2,3' }.tabs.should     == "0 0 1,2,3 * * test"
    Raketab.schedule { run 'test', :months => '1,2,3' }.tabs.should   == "0 0 * 1,2,3 * test"
    Raketab.schedule { run 'test', :weekdays => '1,2,3' }.tabs.should == "0 0 * * 1,2,3 test"
  end
  
  it "should set the fields by array populated by method names" do
    Raketab.schedule { run 'test', :months => [jan,feb,mar] }.tabs.should   == "0 0 * 1,2,3 * test"
    Raketab.schedule { run 'test', :weekdays => [mon,tue,wed] }.tabs.should == "0 0 * * 1,2,3 test"
  end
  
  it "should set the fields by array" do
    Raketab.schedule { run 'test', :minutes => [1,2,3] }.tabs.should  == "1,2,3 0 * * * test"
    Raketab.schedule { run 'test', :hours => [1,2,3] }.tabs.should    == "0 1,2,3 * * * test"
    Raketab.schedule { run 'test', :days => [1,2,3] }.tabs.should     == "0 0 1,2,3 * * test"
    Raketab.schedule { run 'test', :months => [1,2,3] }.tabs.should   == "0 0 * 1,2,3 * test"
    Raketab.schedule { run 'test', :weekdays => [1,2,3] }.tabs.should == "0 0 * * 1,2,3 test"
  end
  
  it "should set the fields by inclusive ranges" do
    Raketab.schedule { run 'test', :minutes => 1..3 }.tabs.should  == "1,2,3 0 * * * test"
    Raketab.schedule { run 'test', :hours => 1..3 }.tabs.should    == "0 1,2,3 * * * test"
    Raketab.schedule { run 'test', :days => 1..3 }.tabs.should     == "0 0 1,2,3 * * test"
    Raketab.schedule { run 'test', :months => 1..3 }.tabs.should   == "0 0 * 1,2,3 * test"
    Raketab.schedule { run 'test', :weekdays => 1..3 }.tabs.should == "0 0 * * 1,2,3 test"
  end
  
  it "should set the fields by exclusive ranges" do
    Raketab.schedule { run 'test', :minutes => 1...4 }.tabs.should  == "1,2,3 0 * * * test"
    Raketab.schedule { run 'test', :hours => 1...4 }.tabs.should    == "0 1,2,3 * * * test"
    Raketab.schedule { run 'test', :days => 1...4 }.tabs.should     == "0 0 1,2,3 * * test"
    Raketab.schedule { run 'test', :months => 1...4 }.tabs.should   == "0 0 * 1,2,3 * test"
    Raketab.schedule { run 'test', :weekdays => 1...4 }.tabs.should == "0 0 * * 1,2,3 test"
  end
  
  it "should set weekday with symbol or string of the day name or abbreviation" do
    Raketab.schedule { run 'test', :on => :thursday }.tabs.should  == '0 0 * * 4 test'
    Raketab.schedule { run 'test', :on => 'Thursday' }.tabs.should == '0 0 * * 4 test'
    Raketab.schedule { run 'test', :on => :thu }.tabs.should       == '0 0 * * 4 test'
    Raketab.schedule { run 'test', :on => 'Thurs' }.tabs.should    == '0 0 * * 4 test'
  end
  
  
  it "should set month with symbol or string of the month name or abbreviation" do
    Raketab.schedule { run 'test', :on => :september }.tabs.should  == '0 0 * 9 * test'
    Raketab.schedule { run 'test', :on => 'September' }.tabs.should == '0 0 * 9 * test'
    Raketab.schedule { run 'test', :on => :sep }.tabs.should        == '0 0 * 9 * test'
    Raketab.schedule { run 'test', :on => 'Sep' }.tabs.should       == '0 0 * 9 * test'
  end
  
  it "should set month with any syntactic sugar" do
    Raketab.schedule { run 'test', :every => :september }.tabs.should == '0 0 * 9 * test'
    Raketab.schedule { run 'test', :each => :september }.tabs.should  == '0 0 * 9 * test'
    Raketab.schedule { run 'test', :on => :september }.tabs.should    == '0 0 * 9 * test'
    Raketab.schedule { run 'test', :in => :september }.tabs.should    == '0 0 * 9 * test'
  end
  
  it "should set day with any syntactic sugar" do
    Raketab.schedule { run 'test', :every => '1st' }.tabs.should == '0 0 1 * * test'
    Raketab.schedule { run 'test', :each => '2nd' }.tabs.should  == '0 0 2 * * test'
    Raketab.schedule { run 'test', :the => '3rd' }.tabs.should   == '0 0 3 * * test'
  end
  
  it "should set the time of day, with AM/PM or military time" do
    Raketab.schedule { run 'no meridiem', :at => '12:30' }.tabs.should   == '30 12 * * * no meridiem'
    Raketab.schedule { run 'am meridiem', :at => '12:30AM' }.tabs.should == '30 0 * * * am meridiem'
    Raketab.schedule { run 'pm meridiem', :at => '12:30PM' }.tabs.should == '30 12 * * * pm meridiem'
    Raketab.schedule { run 'military',    :at => '23:30' }.tabs.should   == '30 23 * * * military'
  end
  
  it "should set all the fields if they are all provided" do
    Raketab.schedule do |t| 
      t.run 'test', :every => :sep, :the => '1st', :on => :thursdays, :at => "12:30" 
    end.tabs.should == "30 12 1 9 4 test"
  end
  
  it "should set the range of months" do
    Raketab.schedule { run 'inclusive full', :in => 'September..November' }.tabs.should  == '0 0 * 9,10,11 * inclusive full'
    Raketab.schedule { run 'exclusive full', :in => 'September...December' }.tabs.should == '0 0 * 9,10,11 * exclusive full'
    Raketab.schedule { run 'inclusive abbr', :in => 'Sep..Nov' }.tabs.should             == '0 0 * 9,10,11 * inclusive abbr'
    Raketab.schedule { run 'exclusive abbr', :in => 'Sep...Dec' }.tabs.should            == '0 0 * 9,10,11 * exclusive abbr'
  end
  
  it "should set the range of months across year boundry" do
    Raketab.schedule { run 'inclusive full reverse', :in => 'November..January' }.tabs.should    == '0 0 * 1,11,12 * inclusive full reverse'
    Raketab.schedule { run 'exclusive full reverse', :in => 'November...February' }.tabs.should  == '0 0 * 1,11,12 * exclusive full reverse'
    Raketab.schedule { run 'inclusive abbr reverse', :in => 'Nov..Jan' }.tabs.should             == '0 0 * 1,11,12 * inclusive abbr reverse'
    Raketab.schedule { run 'exclusive abbr reverse', :in => 'Nov...Feb' }.tabs.should            == '0 0 * 1,11,12 * exclusive abbr reverse'
  end
  
  it "should set the range of days" do
    Raketab.schedule { run 'inclusive full', :on => 'Monday..Thursday' }.tabs.should == '0 0 * * 1,2,3,4 inclusive full'
    Raketab.schedule { run 'exclusive full', :on => 'Monday...Friday' }.tabs.should  == '0 0 * * 1,2,3,4 exclusive full'
    Raketab.schedule { run 'inclusive abbr', :on => 'Mon..Thur' }.tabs.should        == '0 0 * * 1,2,3,4 inclusive abbr'
    Raketab.schedule { run 'exclusive abbr', :on => 'Mon...Fri' }.tabs.should        == '0 0 * * 1,2,3,4 exclusive abbr'
  end
  
  it "should set the range of days across week boundry" do
    Raketab.schedule { run 'inclusive full', :on => 'Thursday..Monday' }.tabs.should  == '0 0 * * 0,1,4,5,6 inclusive full'
    Raketab.schedule { run 'exclusive full', :on => 'Thursday...Monday' }.tabs.should == '0 0 * * 0,4,5,6 exclusive full'
    Raketab.schedule { run 'inclusive abbr', :on => 'Thu..Mon' }.tabs.should         == '0 0 * * 0,1,4,5,6 inclusive abbr'
    Raketab.schedule { run 'exclusive abbr', :on => 'Thu...Mon' }.tabs.should        == '0 0 * * 0,4,5,6 exclusive abbr'
  end
  
  it "should set the range of months using month name methods" do
    Raketab.schedule { run 'inclusive full', :in => september..november }.tabs.should  == '0 0 * 9,10,11 * inclusive full'
    Raketab.schedule { run 'exclusive full', :in => september...december }.tabs.should == '0 0 * 9,10,11 * exclusive full'
    Raketab.schedule { run 'inclusive abbr', :in => sep..nov }.tabs.should             == '0 0 * 9,10,11 * inclusive abbr'
    Raketab.schedule { run 'exclusive abbr', :in => sep...dec }.tabs.should            == '0 0 * 9,10,11 * exclusive abbr'
  end
  
  it "should set the range of months across year boundry using month name methods" do
    Raketab.schedule { run 'inclusive full reverse', :in => november..january }.tabs.should    == '0 0 * 1,11,12 * inclusive full reverse'
    Raketab.schedule { run 'exclusive full reverse', :in => november...february }.tabs.should  == '0 0 * 1,11,12 * exclusive full reverse'
    Raketab.schedule { run 'inclusive abbr reverse', :in => nov..jan }.tabs.should             == '0 0 * 1,11,12 * inclusive abbr reverse'
    Raketab.schedule { run 'exclusive abbr reverse', :in => nov...feb }.tabs.should            == '0 0 * 1,11,12 * exclusive abbr reverse'
  end
  
  it "should set the range of days using weekday name methods" do
    Raketab.schedule { run 'inclusive full', :on => monday..thursday }.tabs.should == '0 0 * * 1,2,3,4 inclusive full'
    Raketab.schedule { run 'exclusive full', :on => monday...friday }.tabs.should  == '0 0 * * 1,2,3,4 exclusive full'
    Raketab.schedule { run 'inclusive abbr', :on => mon..thu }.tabs.should         == '0 0 * * 1,2,3,4 inclusive abbr'
    Raketab.schedule { run 'exclusive abbr', :on => mon...fri }.tabs.should        == '0 0 * * 1,2,3,4 exclusive abbr'
  end
  
  it "should set the range of days across week boundry using weekday name methods" do
    Raketab.schedule { run 'inclusive full', :on => thursday..monday }.tabs.should  == '0 0 * * 0,1,4,5,6 inclusive full'
    Raketab.schedule { run 'exclusive full', :on => thursday...monday }.tabs.should == '0 0 * * 0,4,5,6 exclusive full'
    Raketab.schedule { run 'inclusive abbr', :on => thu..mon }.tabs.should          == '0 0 * * 0,1,4,5,6 inclusive abbr'
    Raketab.schedule { run 'exclusive abbr', :on => thu...mon }.tabs.should         == '0 0 * * 0,4,5,6 exclusive abbr'
  end
  
  it "should set the time with just a number on at" do
    Raketab.schedule { run 'test', :at => "5 o'clock" }.tabs.should == '0 5 * * * test'
    Raketab.schedule { run 'test', :at => "5" }.tabs.should         == '0 5 * * * test'
    Raketab.schedule { run 'test', :at => 5 }.tabs.should           == '0 5 * * * test'
  end
  
  it "should handle multiple cron jobs" do
    Raketab.schedule do
       run '1st', :at => "5 o'clock" 
       run '2nd', :on => :thursday
    end.tabs.should == "0 5 * * * 1st\n0 0 * * 4 2nd"
  end
end
