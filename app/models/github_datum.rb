class GithubDatum < ActiveRecord::Base
  belongs_to :submission_record

  # Returns a structured query result or raises Error if the request failed.
  def query(definition, variables = {})
    response = Expertiza::GitHub::Client.query(definition, variables: variables, context: client_context)

    if response.errors.any?
      raise QueryError.new(response.errors[:data].join(", "))
    else
      response.data
    end
  end
  private :query

  # Public: Useful helper method for tracking GraphQL context data to pass
  # along to the network adapter.
  def client_context
    # Use static access token from environment.
    { access_token: Expertiza::GitHub::Application.secrets.github_access_token }
  end
  private :client_context

  IndexQuery = Expertiza::GitHub::Client.parse <<-'GRAPHQL'
    query($owner: String!, $name: String!, $pull: Int!){
      repository(owner: $owner, name: $name) {
        name
        url
        pullRequest(number: $pull) {
          number
          commits(first: 250) {
            totalCount
            nodes {
              commit {
                oid
                committer {
                  name
                }
                committedDate
                additions
                deletions
                message
                changedFiles
              }
            }
          }
        }
      }
    }
  GRAPHQL

  GITHUB_PULL_REGEX = %r(https?:\/\/(?:[w]{3}\.)?github\.com\/([A-Z0-9_\-]+)\/([A-Z0-9_\-]+)\/pull\/([0-9]+)[\S]*)i

  def retrieve_commit_data(submission)
    owner, repo, pull_number = retrieve_github_url(submission)
    unless pull_number.nil?
      retrieve_graphql_data(submission, owner, repo, pull_number)
    end
    @commits
  end

  def retrieve_graphql_data(submission, owner, repo, pull)
    #Run GraphQL query
    data = query IndexQuery, owner: owner, name: repo, pull: pull.to_i
    github_commits = data.repository.pull_request.commits
    @commits = Array.new
    github_commits.nodes.each do |node|
      next if node.commit.message.start_with? "Merge"
      #search by unique commit id
      commit = GithubDatum.where(oid: node.commit.oid).first
      commit = GithubDatum.create(submission_record: submission,
                                  oid: node.commit.oid,
                                  committer: node.commit.committer.name,
                                  additions: node.commit.additions,
                                  deletions: node.commit.deletions,
                                  changed_files: node.commit.changed_files,
                                  committed_date: DateTime.parse(node.commit.committed_date),
                                  message: node.commit.message) if commit.nil?
      @commits.push(commit)
    end
  end

  def retrieve_github_url(submission)
    if submission.operation != 'Submit Hyperlink'
      return nil
    end
    matches = GITHUB_PULL_REGEX.match(submission.content)
    return nil if matches.nil?
    matches[1,3]
  end
end
