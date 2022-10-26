describe PathError do
  describe 'path_error' do
    it 'raises an error' do
      expect { raise PathError }.to raise_error(PathError)
    end
  end
end
