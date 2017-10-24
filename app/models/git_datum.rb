class GitDatum < ActiveRecord::Base
  include GitDataHelper

  belongs_to :SubmissionRecord
  validates :pull_request, :presence => true
  validates :submission_record_id, :presence => true
  validates :author, :presence => true
  validates :commits, :presence => true
  validates :files, :presence => true
  validates :additions, :presence => true
  validates :deletions, :presence => true
  validates :date, :presence => true

  def self.update_git_data(id)
    submission_record = id
    record = SubmissionRecord.where("id = ?", submission_record).first
    git_url = record.content
    url_parts = git_url.split('/')

    pulls = GitDataHelper.fetchPulls(url_parts[3],url_parts[4])
    gitData = GitDatum.where("submission_record_id = ?", submission_record).map(&:pull_request)

    pulls.each do |res|
      if gitData.include?(res.number)

      else
        commits = GitDataHelper.fetchCommits(url_parts[3],url_parts[4], res.number)
        total_commits = Array.new
        commits.each do |commit|
          single_commit = GitDataHelper.fetchCommit(url_parts[3],url_parts[4], commit.sha)
          author_commit = total_commits.select{|row| row.author == single_commit.commit.author.email}.first
          if(author_commit.nil?)
            author_commit = GitDatum.new
            author_commit.pull_request = res.number
            author_commit.author = single_commit.commit.author.email
            author_commit.commits = 1
            author_commit.files = single_commit.files.size
            author_commit.additions = single_commit.stats.additions
            author_commit.deletions = single_commit.stats.deletions
            author_commit.submission_record_id = id
            author_commit.date = res.created_at
            total_commits << author_commit
          else
            author_commit.commits = author_commit.commits + 1
            author_commit.files = author_commit.files + single_commit.files.size
            author_commit.additions = author_commit.additions + single_commit.stats.additions
            author_commit.deletions = author_commit.deletions + single_commit.stats.deletions
          end
        end
        total_commits.each do |row|
           row.save
        end
      end
    end
  end
end
