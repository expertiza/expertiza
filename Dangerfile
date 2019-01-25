CURRENT_MAINTAINERS = %w[
  efg
  Winbobob
  TheAkbar
].freeze

MODIFIED_FILES = git.modified_files + git.added_files

# ------------------------------------------------------------------------------
# Welcome message
# ------------------------------------------------------------------------------
unless CURRENT_MAINTAINERS.include? github.pr_author
  if github.pr_title =~ /E[0-9]{4}/
    WELCOME_MESSAGE_COURSE_PROJECT =
      markdown <<-MARKDOWN
Thanks for the pull request, and welcome! :tada: The Expertiza team is excited to review your changes, and you should hear from us soon.

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

This repository is being automatically checked for code quality issues using `Code Climate`.
You can see results for this analysis in the PR status below. Newly introduced issues should be fixed before a pull request is considered ready to review.

If you have any questions, please send email to <a href="mailto:expertiza-support@lists.ncsu.edu">expertiza-support@lists.ncsu.edu</a>.
      MARKDOWN

    message(WELCOME_MESSAGE)
  end
end

# ------------------------------------------------------------------------------
# You've made changes to app, but didn't write any tests?
# ------------------------------------------------------------------------------
if MODIFIED_FILES.grep(/app/).any? && MODIFIED_FILES.grep(/spec/).empty?
  NO_TEST_MESSAGE =
    markdown <<-MARKDOWN
There are code changes, but no corresponding tests.
Please include tests if this PR introduces any modifications in behavior.
    MARKDOWN

  warn(NO_TEST_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Your PR is too big (more than 500 LoC).
# ------------------------------------------------------------------------------
if git.lines_of_code > 500
  BIG_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request is more than 500 LoC.
Please make sure you did not commit unnecessary changes, such as `schema.rb`, `node_modules`, `change logs`.
    MARKDOWN

  warn(BIG_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Your course project PR is too small (less than 50 LoC).
# ------------------------------------------------------------------------------
if github.pr_title =~ /E[0-9]{4}/ and git.lines_of_code < 50
  SMALL_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request is less than 50 LoC.
If you are finished refactoring the code, please consider writing corresponding tests.
    MARKDOWN

  warn(SMALL_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Your PR touches too many files (more than 30 files).
# ------------------------------------------------------------------------------
if MODIFIED_FILES.size > 30
  BIG_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request touches more than 30 files.
Please make sure you did not commit unnecessary changes, such as `node_modules`, `change logs`.
    MARKDOWN

  warn(BIG_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Your PR should not have too many duplicated commit messages.
# ------------------------------------------------------------------------------
messages = git.commits.map(&:message)
if messages.size - messages.uniq.size >= 5
  DUP_COMMIT_MESSAGE =
    markdown <<-MARKDOWN
Your pull request has many duplicated commit messages. Please try to `squash` similar commits.
And using meaningful commit messages later.
    MARKDOWN

  warn(DUP_COMMIT_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# If a PR is a work in progress and it shouldn't be merged.
# ------------------------------------------------------------------------------
if github.pr_title.include? "WIP" or github.pr_title.include? "wip"
  WIP_MESSAGE =
    markdown <<-MARKDOWN
This pull request is classed as `Work in Progress`. It cannot be merged right now.
    MARKDOWN

  warn(WIP_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not contain "Todo".
# ------------------------------------------------------------------------------
if github.pr_diff.include? "TODO" or
  github.pr_diff.include? "Todo" or
  github.pr_diff.include? "todo" or
  github.pr_diff.include? "toDo"
  TODO_MESSAGE =
    markdown <<-MARKDOWN
This pull request contains `TODO` task(s); please fix them.
  MARKDOWN

  warn(TODO_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not include temp, tmp, cache file.
# ------------------------------------------------------------------------------
if git.added_files.grep(/.*temp.*/).any? or
   git.added_files.grep(/.*tmp.*/).any? or
   git.added_files.grep(/.*cache.*/).any?
  TEMP_FILE_MESSAGE =
    markdown <<-MARKDOWN
You committed `temp`, `tmp` or `cache` files. Please remove them.
   MARKDOWN

  fail(TEMP_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not include skipped/pending/focused test cases.
# ------------------------------------------------------------------------------
MODIFIED_FILES.each do |file|
  next unless file =~ /.*_spec\.rb$/
  diff = git.diff_for_file(file).patch
  if diff.include? "xdescribe" or
     diff.include? "xspecify" or
     diff.include? "xexample" or
     diff.include? "xit" or
     diff.include? "skip(" or
     diff.include? "skip " or
     diff.include? "pending(" or
     diff.include? "fdescribe" or
     diff.include? "fit"
    TEST_SKIPPED_MESSAGE =
      markdown <<-MARKDOWN
There are one or more skipped/pending/focused test cases in your pull request. Please fix them.
      MARKDOWN

    warn(TEST_SKIPPED_MESSAGE, sticky: true)
  end
end

# ------------------------------------------------------------------------------
# Most of time, the PR should not change or add *.md files.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.md/).any?
  MARKDOWN_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You changed MARKDOWN (`*.md`) documents; please double-check whether it is necessary to do so.
Alternatively, you can insert project-related content in the description field of the pull request.
    MARKDOWN

  warn(MARKDOWN_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should change db schema only if there is new db migrations.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and
  (MODIFIED_FILES.grep(/schema\.rb/).any? or MODIFIED_FILES.grep(/schema\.json/).any?)
  DB_SCHEMA_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You should commit changes to the DB schema (`db/schema.rb`) only if you have created new DB migrations.
Please double check your code. If you did not aim to change the DB, please revert the DB schema changes.
    MARKDOWN

  warn(DB_SCHEMA_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should normally avoid using global variables and/or class variables.
# ------------------------------------------------------------------------------
if github.pr_diff =~ /\$[A-Za-z0-9_]+/ or github.pr_diff =~ /@@[A-Za-z0-9_]+/
  GLOBAL_CLASS_VARIABLE_MESSAGE =
    markdown <<-MARKDOWN
You are using global variables (`$`) or class variables (`@@`); please double-check whether this is necessary.
    MARKDOWN

  warn(GLOBAL_CLASS_VARIABLE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should avoid keeping debugging code.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "puts " or
   github.pr_diff.include? "print " or
   github.pr_diff.include? "binding.pry" or
   github.pr_diff.include? "debugger;" or
   github.pr_diff.include? "console.log"
  fail("You are including debug code in your pull request, please remove it.", sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying *.yml or *.yml.example file.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.yml/).any?
  YAML_FILE_MESSAGE =
    markdown <<-MARKDOWN
You changed YAML (`*.yml`) or example (`*.yml.example`) files; please double-check whether this is necessary.
    MARKDOWN

  warn(YAML_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying rails_helper.rb or spec_helper.rb file.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and
  (MODIFIED_FILES.grep(/rails_helper\.rb/).any? or MODIFIED_FILES.grep(/spec_helper\.rb/).any?)
  TEST_HELPER_FILE_MESSAGE =
    markdown <<-MARKDOWN
You should not change `rails_helper.rb` or `spec_helper.rb` file; please revert these changes.
  MARKDOWN

  warn(TEST_HELPER_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying Gemfile, Gemfile.lock.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and
  (MODIFIED_FILES.include? "Gemfile" or MODIFIED_FILES.include? "Gemfile.lock")
  GEMFILE_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You are modifying `Gemfile` or `Gemfile.lock`, please double check whether it is necessary.
You are suppose to add a new gem only if you have a very good reason. Try to use existing gems instead.
Please revert changes to `Gemfile.lock` made by the IDE.
    MARKDOWN

  warn(GEMFILE_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The rspec does not need to require helper files.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "require 'rspec'" or
   github.pr_diff.include? "require \"rspec\"" or
   github.pr_diff.include? "require 'spec_helper'" or
   github.pr_diff.include? "require \"spec_helper\"" or
   github.pr_diff.include? "require 'rails_helper'" or
   github.pr_diff.include? "require \"rails_helper\"" or
   github.pr_diff.include? "require 'test_helper'" or
   github.pr_diff.include? "require \"test_helper\"" or
   github.pr_diff.include? "require 'factory_girl_rails'" or
   github.pr_diff.include? "require \"factory_girl_rails\""
  RSPEC_REQUIRE_MESSAGE =
    markdown <<-MARKDOWN
You are requiring `rspec` gem or different helper methods in RSpec tests.
There have already been included, you do not need to require them again. Please remove them.
    MARKDOWN

  warn(RSPEC_REQUIRE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Unit tests and integration tests should avoid using "create" keyword.
# ------------------------------------------------------------------------------
MODIFIED_FILES.each do |file|
  next unless file =~ /spec\/models/ or file =~ /spec\/controllers/
  diff = git.diff_for_file(file).patch
  next unless diff.include? " create(" or diff.include? "{create("
  CREATE_MOCK_UP_OBJ_MESSAGE =
    markdown <<-MARKDOWN
  Using `create` in unit tests or integration tests may be overkill. Try to use `build` or `double` instead.
        MARKDOWN

  warn(CREATE_MOCK_UP_OBJ_MESSAGE, sticky: true)
  break
end

# ------------------------------------------------------------------------------
# RSpec tests should avoid using "should" keyword.
# ------------------------------------------------------------------------------
MODIFIED_FILES.each do |file|
  next unless file =~ /.*_spec\.rb$/
  next unless git.diff_for_file(file).patch.include? ".should"
  NO_SHOULD_SYNTAX_MESSAGE =
    markdown <<-MARKDOWN
The `should` syntax is deprecated in RSpec 3. Please use `expect` syntax instead.
Even in test descriptions, please avoid using `should`.
    MARKDOWN

  warn(NO_SHOULD_SYNTAX_MESSAGE, sticky: true)
  break
end

# ------------------------------------------------------------------------------
# RSpec tests should avoid committing text files.
# ------------------------------------------------------------------------------
if MODIFIED_FILES.grep(/.*\.txt/).any? or MODIFIED_FILES.grep(/.*\.csv/).any?
  warn("You committed text files (`*.txt` or `*.csv`); please double-check whether this is necessary.", sticky: true)
end

# ------------------------------------------------------------------------------
# You should not change .bowerrc.
# ------------------------------------------------------------------------------
fail("You changed .bowerrc; please double-check whether this is necessary", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.bowerrc/).any?

# ------------------------------------------------------------------------------
# You should not change .gitignore.
# ------------------------------------------------------------------------------
fail("You changed .gitignore; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.gitignore/).any?

# ------------------------------------------------------------------------------
# You should not change .mention-bot.
# ------------------------------------------------------------------------------
fail("You changed .mention-bot; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.mention-bot/).any?

# ------------------------------------------------------------------------------
# You should not change .rspec.
# ------------------------------------------------------------------------------
fail("You changed .rspec; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.rspec/).any?

# ------------------------------------------------------------------------------
# You should not change Capfile.
# ------------------------------------------------------------------------------
fail("You changed Capfile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Capfile/).any?

# ------------------------------------------------------------------------------
# You should not change Dangerfile.
# ------------------------------------------------------------------------------
fail("You changed Dangerfile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Dangerfile/).any?

# ------------------------------------------------------------------------------
# You should not change Guardfile.
# ------------------------------------------------------------------------------
fail("You changed Guardfile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Guardfile/).any?

# ------------------------------------------------------------------------------
# You should not change LICENSE.
# ------------------------------------------------------------------------------
fail("You changed LICENSE; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/LICENSE/).any?

# ------------------------------------------------------------------------------
# You should not change Procfile.
# ------------------------------------------------------------------------------
fail("You changed Procfile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Procfile/).any?

# ------------------------------------------------------------------------------
# You should not change Rakefile.
# ------------------------------------------------------------------------------
fail("You changed Rakefile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Rakefile/).any?

# ------------------------------------------------------------------------------
# You should not change bower.json.
# ------------------------------------------------------------------------------
fail("You changed bower.json; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/bower\.json/).any?

# ------------------------------------------------------------------------------
# You should not change config.ru.
# ------------------------------------------------------------------------------
fail("You changed config.ru; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/config\.ru/).any?

# ------------------------------------------------------------------------------
# You should not change setup.sh.
# ------------------------------------------------------------------------------
fail("You changed setup.sh; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/setup\.sh/).any?

# ------------------------------------------------------------------------------
# The PR should not modifying vendor folder.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/vendor/).any?
  VENDOR_MESSAGE =
    markdown <<-MARKDOWN
You modified `vendor` folder, please double-check whether it is necessary.
    MARKDOWN

  warn(VENDOR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying /spec/factories/ folder.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/spec\/factories/).any?
  FIXTURE_FILE_MESSAGE =
    markdown <<-MARKDOWN
You modified `spec/factories/` folder; please double-check whether it is necessary.
  MARKDOWN

  warn(FIXTURE_FILE_MESSAGE, sticky: true)
end

# git.added_files
# ------------------------------------------------------------------------------
# The PR should not include .vscode folder.
# ------------------------------------------------------------------------------
if git.added_files.grep(/\.vscode/).any?
  VSCODE_MESSAGE =
    markdown <<-MARKDOWN
You committed `.vscode/` folder; please remove it.
  MARKDOWN

  warn(VSCODE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# RSpec tests should avoid shallow tests.
# ------------------------------------------------------------------------------
MODIFIED_FILES.each do |file|
  next unless file =~ /.*_spec\.rb$/
  diff = git.diff_for_file(file).patch
  num_of_expectations_of_obj_on_page = diff.scan(/expect\(page\).to have/).count
  next unless num_of_expectations_of_obj_on_page >= 5
  EXPECT_ON_OBJ_ON_PAGE_MESSAGE =
    markdown <<-MARKDOWN
In your tests, there are many expectations of elements on pages, which is good.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please write more expectations to validate other things, such as database records, dynamically generated contents.
    MARKDOWN

  warn(EXPECT_ON_OBJ_ON_PAGE_MESSAGE, sticky: true)
  break
end
