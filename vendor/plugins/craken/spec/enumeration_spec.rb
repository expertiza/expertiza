describe Enumeration do
  Weekday = enum %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]

  describe 'creation' do
    it "should create an enumeration by Enumeration.generate, Enumeration(), or enum" do
      ABC1 = Enumeration.generate(%w[a b c])
      ABC1.units.should == [ABC1::A, ABC1::B, ABC1::C]

      ABC2 = Enumeration(%w[a b c])
      ABC2.units.should == [ABC1::A, ABC1::B, ABC1::C]

      ABC3 = enum %w[a b c]
      ABC3.units.should == [ABC1::A, ABC1::B, ABC1::C]
    end

    it "should not generate an enumeration itself" do
      ABC4 = enum %w[a b c]
      ABC4.methods.grep(/generate/).should be_empty
      lambda{ ABC4.generate(%w[a b c]) }.should raise_error(NoMethodError)
    end

    it "should allow an offset from zero to be specified" do
      ABC = enum %w[a b c], 1
      ABC.offset.should == 1
      ABC.size.should == 3
      ABC.units.map { |l| l.to_i }.should == [1,2,3]
    end
  end
  
  describe 'properties' do
    it "should generate the right size of elements" do
      Weekday.units.size.should == 7
      Weekday.size.should == Weekday.units.size      
    end

    it "should generate an enumeration based on an collection of names" do
      # full names
      Weekday.names.should == %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]    
      Weekday.units.should == 
        [Weekday::SUNDAY, Weekday::MONDAY, Weekday::TUESDAY, Weekday::WEDNESDAY, Weekday::THURSDAY, Weekday::FRIDAY, Weekday::SATURDAY]

      # abbreviationss
      Weekday.abbrs.should == %w[Sun Mon Tue Wed Thu Fri Sat]
      Weekday.units.should == 
        [Weekday::SUN, Weekday::MON, Weekday::TUE, Weekday::WED, Weekday::THU, Weekday::FRI, Weekday::SAT]
      Weekday.units.map { |w| w.to_i }.should == (0..6).map
    end
    
    it "should get units based on integer value" do
      (0..6).each do |value|
        Weekday.for(value).should == Weekday.units[value]
      end
      
      # and respect offsets
      (1..3).each do |value|
        ABC.for(value).should == ABC.units[value - ABC.offset]
      end        
    end
    
    it "should be enumerable on the units" do
      Weekday.methods.grep(/^each$/).should == %w[each]
      Weekday.is_a?(Enumerable)
      Weekday.map {|x| x.to_i }.should == Weekday.units.map {|x| x.to_i }
    end

    it "should not be able to create new units" do
      lambda { Weekday.new(7) }.should raise_error(NoMethodError)
    end
  end
  
  describe 'units' do
    it "should be comparable" do
      Weekday::SUN.methods.grep(/^succ$/).should == %w[succ]
      Weekday::SUN.is_a?(Comparable)
      Weekday::SUN.should < Weekday::MON
      Weekday::SUN.should <= Weekday::MON
      Weekday::MON.should > Weekday::SUN
      Weekday::MON.should >= Weekday::SUN
      Weekday::SUN.should == Weekday::SUN
      Weekday::WED.between?(Weekday::MON, Weekday::FRI).should be_true
      Weekday::FRI.between?(Weekday::THU, Weekday::SUN).should be_true # if a ring
      
    end
    
    # this should be configurable!? is true for now!
    it "should be a ring of values (cross boundries)" do 
      Weekday::SAT.succ.should == Weekday::SUN      
      Weekday::SUN.succ.should == Weekday::MON
    end
    
    it "should work in a range" do
      (Weekday::MON..Weekday::FRI).map.should == Weekday.units[1..5]
    end
    
    it "should have to_s be it's name" do
      %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].each do |name|
        Weekday.for(name).to_s.should == name
      end
    end
    
    it "should have to_abbr to get it's three letter abbreviation" do
      %w[Sun Mon Tue Wed Thu Fri Sat].each do |abbr|
        Weekday.for(abbr).to_abbr.should == abbr
      end
    end
    
    it "should show the enumerable name and unit name in inspect" do
      %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].each do |name|
        Weekday.for(name).inspect.should == "#<Weekday:#{name}>"
      end
    end
    
    it "should use integer values in arithmatic (+/-) and return another unit" do
      Weekday.each_with_index do |w,i|
        (Weekday::SUN + i).should == w
      end
      Weekday.map.reverse.each_with_index do |w,i|
        (Weekday::SUN - i - 1).should == w
      end
      # ring / identity
      (Weekday::SUN + 7).should == Weekday::SUN 
      (Weekday::SUN - 7).should == Weekday::SUN 
    end

    it "should use integer values in arithmatic (+/-) and return another unit with coersion to weekday on integer" do
      Weekday.each_with_index do |w,i|
        (1 + w).should == Weekday.map[(i+1) % Weekday.size]
      end
      Weekday.each_with_index do |w,i|
        (i - w).should == Weekday::SUN
      end      
      (0 + Weekday::MON).should == Weekday::MON
      (2 - Weekday::MON).should == Weekday::MON 
    end
  end
end