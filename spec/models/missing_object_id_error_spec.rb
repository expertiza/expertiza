describe MissingObjectIDError do
  describe 'missing_object_id_error' do
    it 'raises an error' do
      expect { raise MissingObjectIDError }.to raise_error(StandardError)
    end
    it 'gives an exception message' do
      expect(MissingObjectIDError.new.exception).to eq('No object ID was provided to the import process. Please contact the system administrator. Model Name: Course')
    end
  end
end
