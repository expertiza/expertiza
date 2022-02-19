class Locale
  attr_reader :code_name, :display_name, :database_encoding

  # Initializes a new locale
  # == Example
  #  Locale.new(:en_US, 'English', 1)
  #
  def initialize(code_name, display_name, database_encoding)
    @code_name = code_name
    @display_name = display_name
    @database_encoding = database_encoding
  end

  # Returns +true+ or +false+ depending on whether the given locale is equivalent to this one
  def ==(other)
    code_name == other.code_name && display_name == other.display_name && database_encoding == other.database_encoding
  end

  # A locale used to represent the lack of a locale preference
  # == Example
  # A new user who has not configured his locale preference may be initialized with this as his locale preference
  @no_preference = Locale.new(:no_pref, 'No Preference', 0)

  class << self
    # Returns the list of all locales for which there is a registered I18n locale.
    # I18n locales are typically registered in application.rb to match YML files defined in config/locales
    # == Example
    #   Locale.available_locales # return a array of Locale: Locale[]
    def available_locales
      @registry ||= I18n.config.available_locales.map(&method(:from_i18n_locale))
    end

    # Similar to +Locale.available_locales+, except it includes the no_preference locale
    def available_locale_preferences
      [@no_preference] + available_locales
    end

    # Return a hash that maps the locale +code_name+ to the +database_encoding+ for each item of the provided enumerable
    # Defaults to +Locale.available_locales+ if no enumerable is provided
    # == Example
    #   Locale.code_name_to_db_encoding([Locale.new(:no_pref, 'No Preference', 0)])) # {no_pref: 1}
    def code_name_to_db_encoding(locales = Locale.available_locales)
      tabulate(locales, %i[code_name database_encoding]).to_h
    end

    def tabulate(enumerable, fields)
      enumerable.map { |item| fields.map { |field| item.send(field) } }
    end

    private

    # Initializes a new +Locale+ for the given i18m code_name by looking up the required details in the corresponding
    # I18n YAML file, or null if not found
    # == Example
    #   Locale.find_by_code(:en_US) == Locale.new(:en_US, 'English', 1)
    #   # Where 'English' is defined in en_US.yml under and the key display_name, and '1' under database_encoding
    def from_i18n_locale(locale)
      I18n.with_locale(locale) { Locale.new(locale, I18n.t('.display_name'), I18n.t('.database_encoding')) }
    end
  end
end
