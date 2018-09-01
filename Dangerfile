# ------------------------------------------------------------------------------
# Has any changes happened inside the actual library code?
# ------------------------------------------------------------------------------
if github.pr_author
  WELCOME_MESSAGE =
    markdown <<-MARKDOWN
Thanks for the pull request, and welcome! :tada: The Expertiza team is excited to review your changes, and you should hear from us soon.

This repository is being automatically checked for code quality issues using `Code Climate`.
You can see results for this analysis in the PR status below. Newly introduced issues should be fixed before a Pull Request is considered ready to review.

If you have any questions, please send email to <a href="mailto:expertiza-support@lists.ncsu.edu">expertiza-support@lists.ncsu.edu</a>.
    MARKDOWN

  message(WELCOME_MESSAGE) 
end

# ------------------------------------------------------------------------------
# You've made changes to lib, but didn't write any tests?
# ------------------------------------------------------------------------------
has_app_changes = !git.modified_files.grep(/app/).empty?
has_spec_changes = !git.modified_files.grep(/spec/).empty?

if has_app_changes && !has_spec_changes
  if Dir.exist?('spec')
    NO_TEST_MESSAGE =
      markdown <<-MARKDOWN
There are code changes, but no corresponding tests.
Please include tests if this PR introduces any modifications in behavior.
      MARKDOWN

    warn(NO_TEST_MESSAGE, sticky: true)
  else
    markdown <<-MARKDOWN
Thanks for the PR! This project lacks automated tests, which makes reviewing and approving PRs somewhat difficult.
Please make sure that your contribution has not broken backwards compatibility or introduced any risky changes.
    MARKDOWN
  end
end

# ------------------------------------------------------------------------------
# Your PR is too big (more than 500 LoC).
# ------------------------------------------------------------------------------
if git.lines_of_code > 500
  BIG_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request is more than 500 LoC.
Please make sure you did not commit unnecessary changes, such as `node_modules`, `change logs`.
    MARKDOWN

  warn(BIG_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Your PR touches too many files (more than 30 files).
# ------------------------------------------------------------------------------
if git.modified_files.size > 30
  BIG_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request touches more than 30 files.
Please make sure you did not commit unnecessary changes, such as `node_modules`, `change logs`.
    MARKDOWN

  warn(BIG_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# If a PR is a work in progress and it shouldn't be merged.
# ------------------------------------------------------------------------------
if github.pr_title.include? "WIP" or github.pr_title.include? "wip"
  warn("This pull request is classed as Work in Progress", sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not include temp, tmp, cache file.
# ------------------------------------------------------------------------------
if git.modified_files.include? "temp" or
   git.modified_files.include? "tmp"
   TEMP_FILE_MESSAGE =
   markdown <<-MARKDOWN
You committed `temp`, `tmp` or `cache` file. 
Please remove them.
   MARKDOWN

  fail(TEMP_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not include skipped test cases.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "xdescribe" or
  github.pr_diff.include? "xit" or
  github.pr_diff.include? "pending"
  TEST_SKIPPED_MESSAGE =
    markdown <<-MARKDOWN
There are one or more skipped/pending test cases in your pull request.
Because we find `xdescribe`, `xit` or `pending` in your code.
Please fix them.
    MARKDOWN

  warn(TEST_SKIPPED_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Most of time, the PR should not change README.md.
# ------------------------------------------------------------------------------
unless git.modified_files.grep(/\.md/).empty?
  MARKDOWN_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You changed MARKDOWN (`*.md`) documents, please double check if it is necessary.
Alternatively, you can write project related content in pull request description field.
    MARKDOWN
  warn(MARKDOWN_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should change db schema only if there is new db migrations.
# ------------------------------------------------------------------------------
if git.modified_files.include? "schema.rb" or git.modified_files.include? "schema.json"
  DB_SCHEMA_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You should commit the changes of DB schema only if you created new DB migrations.
Please double check your code. If you did not aim to change the DB, please revert the DB schema changes.
    MARKDOWN
  warn(DB_SCHEMA_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should avoid using global variables and/or class variables.
# ------------------------------------------------------------------------------
# if github.pr_diff.include? "$" or github.pr_diff.include? /@@[A-Za-z0-9_]+/
if github.pr_diff.include? "$"
  warn("You are using global variables (`$`), please double check if it is necessary", sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should avoid keeping debugging code.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "puts" or
   github.pr_diff.include? "binding.pry" or
   github.pr_diff.include? "debugger;" or
   github.pr_diff.include? "console.log"
   fail("You are including debug code in your pull request, please remove them.", sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying *.yml or *.yml.example file.
# ------------------------------------------------------------------------------
unless git.modified_files.grep(/\.yml/).empty?
  fail("You should not change YAML (`*.yml`) or example (`*.yml.example`) files, please revert these changes.", sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying vendor folder.
# ------------------------------------------------------------------------------
unless git.modified_files.grep(/vendor/).empty?
  warn("You are modifying `vendor` folder, please double check if it is necessary", sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying rails_helper.rb or spec_helper.rb file.
# ------------------------------------------------------------------------------
if git.modified_files.include? "rails_helper.rb" or
   git.modified_files.include? "spec_helper.rb"
  fail("You should not change `rails_helper.rb` or `spec_helper.rb` file, please revert these changes.", sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying Gemfile, Gemfile.lock.
# ------------------------------------------------------------------------------
if git.modified_files.include? "Gemfile" or git.modified_files.include? "Gemfile.lock"
  GEMFILE_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You are modifying `Gemfile` or `Gemfile.lock`, please double check if it is necessary.
You are suppose to add a new gem only if you have a very concret reason.
Please revert changes of `Gemfile.lock` made by IDE.
    MARKDOWN
  warn(GEMFILE_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying /spec/factories/ folder.
# ------------------------------------------------------------------------------
unless git.modified_files.grep(/spec\/factories/).empty?
  warn("You are modifying `/spec/factories/` folder, please double check if it is necessary", sticky: true)
end

# ------------------------------------------------------------------------------
# The rspec does not need to require helper files.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "require 'spec_helper'" or
   github.pr_diff.include? "require \"spec_helper\"" or
   github.pr_diff.include? "require 'rails_helper'" or
   github.pr_diff.include? "require \"rails_helper\"" or
   github.pr_diff.include? "require 'factory_girl_rails'" or
   github.pr_diff.include? "require \"factory_girl_rails\""
  RSPEC_REQUIRE_MESSAGE =
    markdown <<-MARKDOWN
You are requiring different helper methods in Rspec tests.
There have already been included, you do not need to require them again.
Please remove them.
    MARKDOWN
  warn(RSPEC_REQUIRE_MESSAGE, sticky: true)
end