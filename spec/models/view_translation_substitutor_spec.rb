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

  describe '#process_view' do
    let(:substitutor) { ViewTranslationSubstitutor.new }
    let(:directory_name) { 'test_folder' }
    let(:view_name) { 'example_view' }
    let(:translations) { { 'key1' => 'value1', 'key2' => 'value2' } }

    context 'when the view file exists' do
      before do
        allow(File).to receive(:exist?).with("./#{directory_name}/#{view_name}.html.erb").and_return(true)
        allow(File).to receive(:open).with("./#{directory_name}/#{view_name}.html.erb", 'w').and_yield(StringIO.new("Existing content"))
      end

      it 'reads the file, processes translations, and writes back the contents' do
        expect(substitutor).to receive(:process_translation).with("Existing content", 'key1', 'value1').and_return(['stats1', 'new_content1'])
        expect(substitutor).to receive(:process_translation).with('new_content1', 'key2', 'value2').and_return(['stats2', 'new_content2'])

        view_stats = substitutor.send(:process_view, directory_name, view_name, translations)

        expect(view_stats).to eq({ 'key1' => 'stats1', 'key2' => 'stats2' })
        expect(File).to have_received(:open).with("./#{directory_name}/#{view_name}.html.erb", 'w').twice
      end
    end

    context 'when the view file does not exist' do
      it 'returns "<file not found>"' do
        view_stats = substitutor.send(:process_view, test_directory, test_view, test_translations)
        expect(view_stats).to eq('<file not found>')
      end
    end

    context 'when the alternate view file exists' do
      before do
        allow(File).to receive(:exist?).with("./#{directory_name}/#{view_name}.html.erb").and_return(false)
        allow(File).to receive(:exist?).with("./#{directory_name}/_#{view_name}.html.erb").and_return(true)
        allow(File).to receive(:open).with("./#{directory_name}/_#{view_name}.html.erb", 'w').and_yield(StringIO.new("Existing content"))
      end

      it 'reads the alternate file, processes translations, and writes back the contents' do
        expect(substitutor).to receive(:process_translation).with("Existing content", 'key1', 'value1').and_return(['stats1', 'new_content1'])
        expect(substitutor).to receive(:process_translation).with('new_content1', 'key2', 'value2').and_return(['stats2', 'new_content2'])

        view_stats = substitutor.send(:process_view, directory_name, view_name, translations)

        expect(view_stats).to eq({ 'key1' => 'stats1', 'key2' => 'stats2' })
        expect(File).to have_received(:open).with("./#{directory_name}/_#{view_name}.html.erb", 'w').twice
      end
    end
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
