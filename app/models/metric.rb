class Metric < ActiveRecord::Base
  # Constants for GraphQL queries.
  PULL_REQUEST_QUERY = <<~QUERY
    query {
      repository(owner: "%<owner_name>s", name: "%<repository_name>s") {
        pullRequest(number: %<pull_request_number>s) {
          number additions deletions changedFiles mergeable merged headRefOid
          commits(first: 100 %<after_clause>s) {
            totalCount
            pageInfo {
              hasNextPage startCursor endCursor
            }
            edges {
              node {
                id commit {
                  author {
                    name email
                  }
                  additions deletions changedFiles committedDate
                }
              }
            }
          }
        }
      }
    }
  QUERY

  REPO_QUERY = <<~QUERY
    query {
      repository(owner: "%<owner_name>s", name: "%<repository_name>s") {
        ref(qualifiedName: "master") {
          target {
            ... on Commit {
              id
              history(%<after_clause>s since: "%<start_date>s") {
                edges {
                  node {
                    id author {
                      name email date
                    }
                  }
                }
                pageInfo {
                  endCursor
                  hasNextPage
                }
              }
            }
          }
        }
      }
    }
  QUERY

  # Generate the GraphQL query text for a PULL REQUEST link.
  #
  # hyperlink_data - a hash containing the owner name, repository name, and pull request number.
  # after - a pointer provided by the Github API to where the last query left off.
  #
  # Returns a hash containing the query text.
  def self.pull_query(hyperlink_data)
    format(PULL_REQUEST_QUERY, {
      owner_name: hyperlink_data["owner_name"],
      repository_name: hyperlink_data["repository_name"],
      pull_request_number: hyperlink_data["pull_request_number"],
      after_clause: nil
    })
  end

  # Generate the GraphQL query text for a REPOSITORY link.
  #
  # hyperlink_data - a hash containing the owner name and repository name.
  # date - the assignment start date, in the format "YYYY-MM-DD".
  # after - a pointer provided by the Github API to where the last query left off.
  #
  # Returns a hash containing the query text.
  def self.repo_query(hyperlink_data, date)
    format(REPO_QUERY, {
      owner_name: hyperlink_data["owner_name"],
      repository_name: hyperlink_data["repository_name"],
      start_date: date.iso8601(3),
      after_clause: nil
    })
  end
end
