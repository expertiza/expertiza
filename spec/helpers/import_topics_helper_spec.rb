describe "ImportTopicsHelper" do
    describe "#define_attributes" do
      before(:each) do
        @row_hash = {};
        @row_hash[:description] = 'This text contains ascii characters 8⁠–⁠12'
        @row_hash[:topic_identifier] = ' Identifier '
        @row_hash[:topic_name] = 'Name'
        @row_hash[:max_choosers] = '24'
        @row_hash[:category] = 'Category'
        @row_hash[:link] = 'https://expertiza.ncsu.edu'
      end
      
      it "The define_attributes should return the hash and also by trimming the ascci chracters" do
        attributes = ImportTopicsHelper.define_attributes(@row_hash)
        expect(attributes).not_to be_empty
      end
    end
  end
  