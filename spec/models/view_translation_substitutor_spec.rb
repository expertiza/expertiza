describe ViewTranslationSubstitutor do
  let(:substitutor) { ViewTranslationSubstitutor.new }
  let(:test_directory) { '../../spec/test_folder' }
  let(:test_view) { 'example_view' }
  let(:non_view) { 'nonexistent_file'}
  let(:test_translations) { { 'hello' => 'Hello, world!' } }
  let(:locale) do {
    '../../spec/test_folder' => {
      'example_view' => {
        'hello' => 'Hello, world!'
      }
    }
  }
  end

  let(:nonexistent_locale) do {
    '../../spec/test_folder' => {
      'nonexistent_file' => {
        'hello' => 'Hello, world!'
      }
    }
  }
  end


  describe '#process_translation' do
    let(:contents) { 'This is a test string with some "text" to be replaced.' }
    let(:key) { 'XXXXXXX' }
    let(:val) { 'text' }
    let(:key2) { 'skipped key' }
    let(:val2) { 'string' }
    let(:key3) { 'non-existent key'}
    let(:val3) { 'non-existent val'}

    it 'replaces the correct text with translation keys' do
      replacements, new_contents = substitutor.send(:process_translation, contents, key, val)

      expect(replacements).to include("replacements" => ["\"#{val}\""])
      expect(new_contents).to include("#{key}")
    end

    it 'adds to skip when one value is not found but another value is' do
      skips, new_contents = substitutor.send(:process_translation, contents, key2, val2)

      expect(skips).to include("skips" => ["test string with"])
      expect(new_contents).not_to include("#{key2}")
    end

    it 'adds <unmatched> to translation_stats when there is no match' do
      translation_stats, new_contents = substitutor.send(:process_translation, contents, key3, val3)

      expect(translation_stats).to include("<unmatched>")
      expect(new_contents).not_to include("#{key3}")
    end
  end
end
