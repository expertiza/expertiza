describe Language do
  describe '#the name of the language' do
    it 'is settable and returnable' do
      language = Language.new
      expect(language.name).to eq(nil)
      language.name = 'English'
      expect(language.name).to eq('English')
    end
  end
end
