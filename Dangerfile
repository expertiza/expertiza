CURRENT_MAINTAINERS = %w[
  efg
  Winbobob
  TheAkbar
  johnbumgardner
  nnhimes
].freeze

ADDED_FILES    = git.added_files
DELETED_FILES  = git.deleted_files
MODIFIED_FILES = git.modified_files
RENAMED_FILES  = git.renamed_files
TOUCHED_FILES  = ADDED_FILES + DELETED_FILES + MODIFIED_FILES + RENAMED_FILES
LoC            = git.lines_of_code
COMMITS        = git.commits

PR_AUTHOR      = github.pr_author
PR_TITLE       = github.pr_title
PR_DIFF        = github.pr_diff
PR_ADDED       = PR_DIFF
                 .split("\n")
                 .select { |loc| loc.start_with?('+') && !loc.include?('+++ b') }
                 .join('')

def warning_message_of_config_file_change(filename, regex)
  if !CURRENT_MAINTAINERS.include?(PR_AUTHOR) && MODIFIED_FILES.grep(regex).any?
    raise("You changed #{filename}; please double-check whether this is necessary.", sticky: true)
  end
end

# ------------------------------------------------------------------------------
# 0. Welcome message
# ------------------------------------------------------------------------------
unless CURRENT_MAINTAINERS.include? PR_AUTHOR
  if PR_TITLE =~ /E[0-9]{4}/
    WELCOME_MESSAGE_COURSE_PROJECT =
      markdown <<-MARKDOWN
Thanks for the pull request, and welcome! :tada: The Expertiza team is excited to review your changes, and you should hear from us soon.

Please make sure the PR passes all checks and you have run `rubocop -a` to autocorrect issues before requesting a review.

This repository is being automatically checked for code-quality issues using `Code Climate`.
You can see results for this analysis in the PR status below. Newly introduced issues should be fixed before a pull request is considered ready to review.

Also, please spend some time looking at the instructions at the top of your course project writeup.
If you have any questions, please send email to <a href="mailto:expertiza-support@lists.ncsu.edu">expertiza-support@lists.ncsu.edu</a>.
      MARKDOWN

    message(WELCOME_MESSAGE_COURSE_PROJECT)
  else
    WELCOME_MESSAGE =
      markdown <<-MARKDOWN
Thanks for the pull request, and welcome! :tada: The Expertiza team is excited to review your changes, and you should hear from us soon.

Please make sure the PR passes all checks and you have run `rubocop -a` to autocorrect issues before requesting a review.

This repository is being automatically checked for code quality issues using `Code Climate`.
You can see results for this analysis in the PR status below. Newly introduced issues should be fixed before a pull request is considered ready to review.

If you have any questions, please send email to <a href="mailto:expertiza-support@lists.ncsu.edu">expertiza-support@lists.ncsu.edu</a>.
      MARKDOWN

    message(WELCOME_MESSAGE)
  end
end

# ------------------------------------------------------------------------------
# 1. Your pull request should not be too big (more than 500 LoC).
# ------------------------------------------------------------------------------
if LoC > 500
  BIG_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request is more than 500 LoC.
Please make sure you did not commit unnecessary changes, such as `schema.rb`, `node_modules`, `change logs`.
    MARKDOWN

  warn(BIG_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 2. Your pull request should not be too small (less than 50 LoC).
# ------------------------------------------------------------------------------
if PR_TITLE =~ /E[0-9]{4}/ && (LoC < 50)
  SMALL_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request is less than 50 LoC.
If you are finished refactoring the code, please consider writing corresponding tests.
    MARKDOWN

  warn(SMALL_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 3. Your pull request should not touch too many files (more than 30 files).
# ------------------------------------------------------------------------------
if TOUCHED_FILES.size > 30
  BIG_PR_MESSAGE2 =
    markdown <<-MARKDOWN
Your pull request touches more than 30 files.
Please make sure you did not commit unnecessary changes, such as `node_modules`, `change logs`.
    MARKDOWN

  warn(BIG_PR_MESSAGE2, sticky: true)
end

# ------------------------------------------------------------------------------
# 4. Your pull request should not have too many duplicated commit messages.
# ------------------------------------------------------------------------------
has_many_dup_commit_messages = false
messages = COMMITS.map(&:message)
messages.uniq.each do |msg|
  if messages.count(msg) >= 5
    has_many_dup_commit_messages = true
    break
  end
end

if has_many_dup_commit_messages
  DUP_COMMIT_MESSAGE =
    markdown <<-MARKDOWN
Your pull request has many duplicated commit messages. Please try to `squash` similar commits.
And using meaningful commit messages later.
    MARKDOWN

  warn(DUP_COMMIT_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 5. Your pull request is "work in progress" and it will not be merged.
# ------------------------------------------------------------------------------
if PR_TITLE.include?('WIP') || PR_TITLE.include?('wip')
  WIP_MESSAGE =
    markdown <<-MARKDOWN
This pull request is classed as `Work in Progress`. It cannot be merged right now.
    MARKDOWN

  warn(WIP_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 6. Your pull request should not contain "Todo" or "Fixme" keyword.
# ------------------------------------------------------------------------------
if PR_ADDED.include?('TODO') ||
   PR_ADDED.include?('Todo') ||
   PR_ADDED.include?('todo') ||
   PR_ADDED.include?('toDo') ||
   PR_ADDED.include?('FIXME') ||
   PR_ADDED.include?('FixMe') ||
   PR_ADDED.include?('Fixme') ||
   PR_ADDED.include?('fixme')
  TODO_MESSAGE =
    markdown <<-MARKDOWN
This pull request contains `TODO` or `FIXME` task(s); please fix them.
    MARKDOWN

  warn(TODO_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 7. Your pull request should not include temp, tmp, cache file.
# ------------------------------------------------------------------------------
if ADDED_FILES.grep(/.*temp.*/).any? ||
   ADDED_FILES.grep(/.*tmp.*/).any? ||
   ADDED_FILES.grep(/.*cache.*/).any?
  TEMP_FILE_MESSAGE =
    markdown <<-MARKDOWN
You committed `temp`, `tmp` or `cache` files. Please remove them.
    MARKDOWN

  raise(TEMP_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 8. Your pull request should avoid using global variables and/or class variables.
# ------------------------------------------------------------------------------
(ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).each do |file|
  next unless file =~ /.*\.rb$/

  added_lines = git
                .diff_for_file(file)
                .patch
                .split("\n")
                .select { |loc| loc.start_with?('+') && !loc.include?('+++ b') }
                .join('')
  next unless added_lines =~ /\$[A-Za-z0-9_]+/ || added_lines =~ /@@[A-Za-z0-9_]+/

  GLOBAL_CLASS_VARIABLE_MESSAGE =
    markdown <<-MARKDOWN
  You are using global variables (`$`) or class variables (`@@`); please double-check whether this is necessary.
    MARKDOWN

  warn(GLOBAL_CLASS_VARIABLE_MESSAGE, sticky: true)
  break
end

# ------------------------------------------------------------------------------
# 9. Your pull request should avoid keeping debugging code.
# ------------------------------------------------------------------------------
if PR_ADDED.include?('puts ') ||
   PR_ADDED.include?('print ') ||
   PR_ADDED.include?('binding.pry') ||
   PR_ADDED.include?('debugger;') ||
   PR_ADDED.include?('console.log')
  warn('You are including debug code in your pull request, please remove it.', sticky: true)
end

# ------------------------------------------------------------------------------
# 10. You should write tests after making changes to the application.
# ------------------------------------------------------------------------------
if TOUCHED_FILES.grep(/app/).any? && TOUCHED_FILES.grep(/spec/).empty?
  NO_TEST_MESSAGE =
    markdown <<-MARKDOWN
There are code changes, but no corresponding tests.
Please include tests if this PR introduces any modifications in behavior.
    MARKDOWN

  warn(NO_TEST_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 11. Your pull request should not include skipped/pending/focused test cases.
# ------------------------------------------------------------------------------
(ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).each do |file|
  next unless file =~ /.*_spec\.rb$/

  added_lines = git
                .diff_for_file(file)
                .patch
                .split("\n")
                .select { |loc| loc.start_with?('+') && !loc.include?('+++ b') }
                .join('')
  if added_lines.include?('xdescribe') ||
     added_lines.include?('xspecify')  ||
     added_lines.include?('xexample')  ||
     added_lines.include?('xit')       ||
     added_lines.include?('skip(')     ||
     added_lines.include?('skip ')     ||
     added_lines.include?('pending(')  ||
     added_lines.include?('fdescribe') ||
     added_lines.include?('fit')
    TEST_SKIPPED_MESSAGE =
      markdown <<-MARKDOWN
There are one or more skipped/pending/focused test cases in your pull request. Please fix them.
      MARKDOWN

    warn(TEST_SKIPPED_MESSAGE, sticky: true)
    break
  end
end

# ------------------------------------------------------------------------------
# 12. Unit tests and integration tests should avoid using "create" keyword.
# ------------------------------------------------------------------------------
(ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).each do |file|
  next unless file =~ %r{spec/models} || file =~ %r{spec/controllers}

  added_lines = git
                .diff_for_file(file)
                .patch
                .split("\n")
                .select { |loc| loc.start_with?('+') && !loc.include?('+++ b') }
                .join('')
  next unless added_lines =~ /create\(/

  CREATE_MOCK_UP_OBJ_MESSAGE =
    markdown <<-MARKDOWN
  Using `create` in unit tests or integration tests may be overkill. Try to use `build` or `double` instead.
    MARKDOWN

  warn(CREATE_MOCK_UP_OBJ_MESSAGE, sticky: true)
  break
end

# ------------------------------------------------------------------------------
# 13. RSpec tests should avoid using "should" keyword.
# ------------------------------------------------------------------------------
(ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).each do |file|
  next unless file =~ /.*_spec\.rb$/

  added_lines = git
                .diff_for_file(file)
                .patch
                .split("\n")
                .select { |loc| loc.start_with?('+') && !loc.include?('+++ b') }
                .join('')
  next unless added_lines.include? '.should'

  NO_SHOULD_SYNTAX_MESSAGE =
    markdown <<-MARKDOWN
The `should` syntax is deprecated in RSpec 3. Please use `expect` syntax instead.
Even in test descriptions, please avoid using `should`.
    MARKDOWN

  warn(NO_SHOULD_SYNTAX_MESSAGE, sticky: true)
  break
end

# ------------------------------------------------------------------------------
# 14. Your RSpec testing files do not need to require helper files (e.g., rails_helper.rb, spec_helper.rb).
# ------------------------------------------------------------------------------
if PR_ADDED.include?("require 'rspec'") ||
   PR_ADDED.include?('require "rspec"') ||
   PR_ADDED.include?("require 'spec_helper'") ||
   PR_ADDED.include?('require "spec_helper"') ||
   PR_ADDED.include?("require 'rails_helper'") ||
   PR_ADDED.include?('require "rails_helper"') ||
   PR_ADDED.include?("require 'test_helper'") ||
   PR_ADDED.include?('require "test_helper"') ||
   PR_ADDED.include?("require 'factory_girl_rails'") ||
   PR_ADDED.include?('require "factory_girl_rails"') ||
   PR_ADDED.include?("require 'factory_bot_rails'") ||
   PR_ADDED.include?('require "factory_bot_rails"')
  RSPEC_REQUIRE_MESSAGE =
    markdown <<-MARKDOWN
You are requiring `rspec` gem, fixture-related gem(s) or different helper methods in RSpec tests.
There have already been included, you do not need to require them again. Please remove them.
    MARKDOWN

  warn(RSPEC_REQUIRE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 15. You should avoid committing text files for RSpec tests.
# ------------------------------------------------------------------------------
if (ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).grep(/.*spec.*\.txt/).any? ||
   (ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).grep(/.*spec.*\.csv/).any?
  warn('You committed text files (`*.txt` or `*.csv`) for RSpec tests; please double-check whether this is necessary.', sticky: true)
end

# ------------------------------------------------------------------------------
# 16. Your pull request should not change or add *.md files unless you have a good reason.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include?(PR_AUTHOR) && (ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).grep(/\.md/).any?
  MARKDOWN_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You changed MARKDOWN (`*.md`) documents; please double-check whether it is necessary to do so.
Alternatively, you can insert project-related content in the description field of the pull request.
    MARKDOWN

  warn(MARKDOWN_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 17. Your pull request should not change DB schema unless there is new DB migrations.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include?(PR_AUTHOR) &&
   (TOUCHED_FILES.grep(%r{db/migrate}).empty? &&
   (MODIFIED_FILES.grep(/schema\.rb/).any? || (ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).grep(/schema\.json/).any?))
  DB_SCHEMA_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You should commit changes to the DB schema (`db/schema.rb`) only if you have created new DB migrations.
Please double check your code. If you did not aim to change the DB, please revert the DB schema changes.
    MARKDOWN

  warn(DB_SCHEMA_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 18. Your pull request should not modify *.yml or *.yml.example file.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include?(PR_AUTHOR) && (ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).grep(/\.yml/).any?
  YAML_FILE_MESSAGE =
    markdown <<-MARKDOWN
You changed YAML (`*.yml`) or example (`*.yml.example`) files; please double-check whether this is necessary.
    MARKDOWN

  warn(YAML_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 19. Your pull request should not modify test-related helper files.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include?(PR_AUTHOR) &&
   (MODIFIED_FILES.grep(/rails_helper\.rb/).any? || MODIFIED_FILES.grep(/spec_helper\.rb/).any?)
  TEST_HELPER_FILE_MESSAGE =
    markdown <<-MARKDOWN
You should not change `rails_helper.rb` or `spec_helper.rb` file; please revert these changes.
    MARKDOWN

  warn(TEST_HELPER_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 20. Your pull request should not modify Gemfile, Gemfile.lock.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include?(PR_AUTHOR) &&
   (MODIFIED_FILES.include?('Gemfile') || MODIFIED_FILES.include?('Gemfile.lock'))
  GEMFILE_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You are modifying `Gemfile` or `Gemfile.lock`, please double check whether it is necessary.
You are suppose to add a new gem only if you have a very good reason. Try to use existing gems instead.
Please revert changes to `Gemfile.lock` made by the IDE.
    MARKDOWN

  warn(GEMFILE_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 21. You should not change .bowerrc.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('.bowerrc', /\.bowerrc/)

# ------------------------------------------------------------------------------
# 22. You should not change .gitignore.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('.gitignore', /\.gitignore/)

# ------------------------------------------------------------------------------
# 23. You should not change .mention-bot.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('.mention-bot', /\.mention-bot/)

# ------------------------------------------------------------------------------
# 24. You should not change .rspec.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('.rspec', /\.rspec/)

# ------------------------------------------------------------------------------
# 25. You should not change Capfile.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('Capfile', /Capfile/)

# ------------------------------------------------------------------------------
# 26. You should not change Dangerfile.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('Dangerfile', /Dangerfile/)

# ------------------------------------------------------------------------------
# 27. You should not change Guardfile.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('Guardfile', /Guardfile/)

# ------------------------------------------------------------------------------
# 28. You should not change LICENSE.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('LICENSE', /LICENSE/)

# ------------------------------------------------------------------------------
# 29. You should not change Procfile.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('Procfile', /Procfile/)

# ------------------------------------------------------------------------------
# 30. You should not change Rakefile.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('Rakefile', /Rakefile/)

# ------------------------------------------------------------------------------
# 31. You should not change bower.json.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('bower.json', /bower\.json/)

# ------------------------------------------------------------------------------
# 32. You should not change config.ru.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('config.ru', /config\.ru/)

# ------------------------------------------------------------------------------
# 33. You should not change setup.sh.
# ------------------------------------------------------------------------------
warning_message_of_config_file_change('setup.sh', /setup\.sh/)

# ------------------------------------------------------------------------------
# 34. The PR should not modify vendor folder.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include?(PR_AUTHOR) && (ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).grep(/vendor/).any?
  VENDOR_MESSAGE =
    markdown <<-MARKDOWN
You modified `vendor` folder, please double-check whether it is necessary.
    MARKDOWN

  warn(VENDOR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 35. You should not modify /spec/factories/ folder.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include?(PR_AUTHOR) && (ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).grep(%r{spec/factories}).any?
  FIXTURE_FILE_MESSAGE =
    markdown <<-MARKDOWN
You modified `spec/factories/` folder; please double-check whether it is necessary.
    MARKDOWN

  warn(FIXTURE_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 36. You should not commit .vscode folder to your pull request.
# ------------------------------------------------------------------------------
if ADDED_FILES.grep(/\.vscode/).any?
  VSCODE_MESSAGE =
    markdown <<-MARKDOWN
You committed `.vscode` folder; please remove it.
    MARKDOWN

  warn(VSCODE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# RSpec tests should avoid shallow tests
# 37. Including greater than or equal to five wildcard argument matchers (e.g., anything, any_args).
# 38. Not writing/commenting out expectations for the tests.
# 39. Test expectations do not include matchers, such as comparisons (e.g.,equal(expected_value)),
#     the status change of objects (e.g.,change(object, :value).by(delta)), error handlings (e.g.,raise_error("message")).
# 40. Test expectations only focus on the return value not being nil, empty or not equal to 0 without testing the real value.
# 41. In feature tests, expectations only focus on words appearance on the view(e.g.,expect(page).to have_content(word)),
#     and without otherevidence, such as the new creation of the object, new record in DB.
# ------------------------------------------------------------------------------
(ADDED_FILES + MODIFIED_FILES + RENAMED_FILES).each do |file|
  next unless file =~ /.*_spec\.rb$/

  added_lines_arr = git
                    .diff_for_file(file)
                    .patch
                    .split("\n")
                    .select { |loc| loc.start_with?('+') && !loc.include?('+++ b') }
  added_lines = added_lines_arr.join('')
  num_of_tests = added_lines.scan(/\+\s*it\s*['"]/).count
  num_of_expect_key_words = added_lines.scan(/\+\s*expect\s*(\(|\{|do)/).count
  num_of_commented_out_expect_key_words = added_lines.scan(/\+\s*#\s*expect\s*(\(|\{|do)/).count
  num_of_expectation_without_machers = added_lines_arr.count { |loc| (loc.scan(/^\+\s*expect\s*[\(\{]/).count > 0) && (loc.scan(/\.(to|not_to|to_not)/).count == 0) }
  num_of_expectation_not_focus_on_real_value = added_lines_arr.count { |loc| (loc.scan(/^\+\s*expect\s*[\(\{]/).count > 0) && (loc.scan(/\.(not_to|to_not)\s*(be_nil|be_empty|eq 0|eql 0|equal 0)/).count > 0) }
  num_of_wildcard_argument_matchers = added_lines.scan(/\((anything|any_args)\)/).count
  num_of_expectations_on_page = added_lines.scan(/\+\s*expect\s*\(page\)/).count

  if num_of_wildcard_argument_matchers >= 5
    WILDCARD_ARGUMENT_MATCHERS_MESSAGE =
      markdown <<-MARKDOWN
There are many wildcard argument matchers (e.g., `anything`, `any_args`) in your tests.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please avoid wildcard matchers.
      MARKDOWN

    warn(WILDCARD_ARGUMENT_MATCHERS_MESSAGE, sticky: true)
    break
  elsif (num_of_expect_key_words < num_of_tests) || (num_of_commented_out_expect_key_words > 0)
    NOT_WRITING_EXPECTATIONS_FOR_TESTS_MESSAGE =
      markdown <<-MARKDOWN
One or more of your tests do not have expectations or you commented out some expectations.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please write at least one expectation for each test and do not comment out expectations.
      MARKDOWN

    warn(NOT_WRITING_EXPECTATIONS_FOR_TESTS_MESSAGE, sticky: true)
    break
  elsif num_of_expectation_without_machers > 0
    EXPECTATION_WITHOUT_MATCHERS_MESSAGE =
      markdown <<-MARKDOWN
One or more of your test expectations do not have matchers.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please include matchers, such as comparisons (e.g., `equal(expected_value)`), the status change of objects (e.g., `change(object, :value).by(delta)`), error handlings (e.g., `raise_error("message")`).
      MARKDOWN

    warn(EXPECTATION_WITHOUT_MATCHERS_MESSAGE, sticky: true)
    break
  elsif num_of_expectation_not_focus_on_real_value > 0
    EXPECTATION_NOT_FOCUS_ON_REAL_VALUE =
      markdown <<-MARKDOWN
One or more of your test expectations only focus on the return value not being `nil`, `empty` or not equal to `0` without testing the `real` value.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please write expectations to test the `real` value.
      MARKDOWN

    warn(EXPECTATION_NOT_FOCUS_ON_REAL_VALUE, sticky: true)
    break
  elsif num_of_expect_key_words - num_of_expectations_on_page < num_of_tests
    EXPECT_ON_OBJ_ON_PAGE_MESSAGE =
      markdown <<-MARKDOWN
In your tests, there are many expectations of elements on pages, which is good.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please write more expectations to validate other things, such as database records, dynamically generated contents.
      MARKDOWN

    warn(EXPECT_ON_OBJ_ON_PAGE_MESSAGE, sticky: true)
    break
  end
end
