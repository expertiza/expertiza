describe MissingObjectIDError do
  describe 'missing_object_id_error' do
  	it 'raises an error' do
      expect{raise MissingObjectIDError.new}.to raise_error(PathError)
      expect{raise MissingObjectIDError.new.exception}.to eq('No object ID was provided to the import process. Please contact the system administrator. Model Name: Course')
    end
  end
end