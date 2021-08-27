describe Permission do
    
    it "should have a valid name" do
        perm = Permission.new(:name => "TestPermission")
        expect(perm).to be_valid
    end
        
    it "should have a unique name" do
        Permission.create!(:name => "TestPermission")
        perm = Permission.new(:name => "TestPermission")
        expect(perm).not_to be_valid
    end

end