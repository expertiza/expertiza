class GitDataController < ApplicationController
  before_action :set_git_datum, only: [:show, :edit, :update, :destroy]
  include GitDataHelper

  # GET /git_data
  def index
    @git_data = GitDatum.all

  end

  # GET /git_data/1
  def show
  end

  # GET /git_data/new
  def new
    @git_datum = GitDatum.new
  end

  # GET /git_data/1/edit
  def edit
  end

  # POST /git_data
  def create
    @git_datum = GitDatum.new(git_datum_params)

    if @git_datum.save
      redirect_to @git_datum, notice: 'Git datum was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /git_data/1
  def update
    if @git_datum.update(git_datum_params)
      redirect_to @git_datum, notice: 'Git datum was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /git_data/1
  def destroy
    @git_datum.destroy
    redirect_to git_data_url, notice: 'Git datum was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_git_datum
      @git_datum = GitDatum.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def git_datum_params
      params.require(:git_datum).permit(:pull_request, :author, :commits, :files, :additions, :deletions, :date)
    end
  def update_git_data
    submission_record=params[:record]
    record = SubmissionRecord.where("id = ?", submission_record).first
    git_url = record.content
    url_parts = git_url.split('/')
    pulls = fetchPulls(url_parts[3],url_parts[4])
    gitData = GitDatum.where("submission_record_id = ?", submission_record).map(&:pull_request)

    pulls.each do |res|
      if gitData.include?(res.number)

      else
        commits = fetchCommits(url_parts[3],url_parts[4], res.number)
        total_commits = Array.new
        commits.each do |commit|
          single_commit = fetchCommit(url_parts[3],url_parts[4], commit.sha)
          author_commit = total_commits.where("author = ?", commit.author.name).first
          if(author_commit.nil?)
            author_commit = GitDatum.new
            author_commit.pull_request = res.number
            author_commit.author = single_commit.author.name
            author_commit.commits = 1
            author_commit.files = single_commit.files.size
            author_commit.additions = single_commit.stats.additions
            author_commit.deletions = single_commit.stats.deletions
            total_commits.add(author_commit)
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
