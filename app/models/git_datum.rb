class GitDatum < ActiveRecord::Base
  include GitDataHelper
  attr_accessible
  belongs_to :SubmissionRecord
  validates :pull_request, presence: true
  validates :submission_record_id, presence: true
  validates :author, presence: true
  validates :commits, presence: true
  validates :files, presence: true
  validates :additions, presence: true
  validates :deletions, presence: true
  validates :lines_modified, presence: true
  validates :date, presence: true

  def self.update_git_data(id)
    submission_record = id
    record = SubmissionRecord.find_by(id: submission_record)
    git_url = record.content
    url_parts = git_url.split('/')

    pulls = GitDataHelper.fetch_pulls(url_parts[3], url_parts[4])
    git_data = GitDatum.where("submission_record_id = ?", submission_record).map(&:pull_request)

    pulls.each do |res|
      if git_data.include?(res.number)
      else
        commits = GitDataHelper.fetch_commits(url_parts[3], url_parts[4], res.number)
        total_commits = []
        commits.each do |commit|
          single_commit = GitDataHelper.fetch_commit(url_parts[3], url_parts[4], commit.sha)
          author_commit = total_commits.select {|row| row.author == single_commit.commit.author.email }.first
          if author_commit.nil?
            total_commits << create_git_data(res, single_commit, id)
          else
            author_commit = update_git_array(author_commit, single_commit)
          end
        end
        total_commits.each(&:save)
      end
    end
  end

  def self.create_git_data(res, single_commit, id)
    author_commit = GitDatum.new
    author_commit.pull_request = res.number
    author_commit.author = single_commit.commit.author.email
    author_commit.commits = 1
    author_commit.files = single_commit.files.size
    author_commit.additions = single_commit.stats.additions
    author_commit.deletions = single_commit.stats.deletions
    author_commit.lines_modified = author_commit.additions + author_commit.deletions
    author_commit.submission_record_id = id
    author_commit.date = res.created_at
    author_commit
  end

  def self.update_git_array(author_commit, single_commit)
    author_commit.commits = author_commit.commits + 1
    author_commit.files = author_commit.files + single_commit.files.size
    author_commit.additions = author_commit.additions + single_commit.stats.additions
    author_commit.deletions = author_commit.deletions + single_commit.stats.deletions
    author_commit.lines_modified = author_commit.additions + author_commit.deletions
    author_commit
  end

  private_class_method :create_git_data, :update_git_array
end
