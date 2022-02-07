describe Locale do
  let(:no_pref_locale) { Locale.new(:no_pref, 'No Preference', 0) }

  describe '#available_locales' do
    it 'finds translations for the mandatory fields (such as display_name and db_encoding) for all available locales' do
      expect(Locale.available_locales.to_s).to_not match('translation missing')
    end
    it 'contains only unique display_names, code_names and database_encodings' do
      display_names = Locale.available_locales.map(&:display_name)
      expect(display_names.uniq.length).to eq(display_names.length)
      code_names = Locale.available_locales.map(&:code_name)
      expect(code_names.uniq.length).to eq(code_names.length)
      database_encodings = Locale.available_locales.map(&:database_encoding)
      expect(database_encodings.uniq.length).to eq(database_encodings.length)
    end
  end

  describe '#available_locale_preferences' do
    it 'should contain the no preference locale as the first element followed by all available locales' do
      expect(Locale.available_locale_preferences).to eq([no_pref_locale] + Locale.available_locales)
    end
    it 'contains only unique display_names, code_names and database_encodings' do
      display_names = Locale.available_locale_preferences.map(&:display_name)
      expect(display_names.uniq.length).to eq(display_names.length)
      code_names = Locale.available_locale_preferences.map(&:code_name)
      expect(code_names.uniq.length).to eq(code_names.length)
      database_encodings = Locale.available_locale_preferences.map(&:database_encoding)
      expect(database_encodings.uniq.length).to eq(database_encodings.length)
    end
  end

  describe '#code_name_to_db_encoding' do
    it 'correctly produces a mapping between the code_name and the db_encoding' do
      expect(Locale.code_name_to_db_encoding([no_pref_locale])).to eq(no_pref: 0)
    end
  end

  describe '#tabulate' do
    it 'produces a 2D array with rows corresponding to the given array and columns corresponding to the given fields' do
      expect(Locale.tabulate([no_pref_locale, Locale.new(:asd, 'Asd', 12)],
                             %i[display_name code_name])).to eq([['No Preference', :no_pref], ['Asd', :asd]])
    end
  end
end
