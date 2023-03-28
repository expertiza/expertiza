require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  test "pull_query returns correct GraphQL query text" do
    hyperlink_data = {
      "owner_name" => "test_owner",
      "repository_name" => "test_repo",
      "pull_request_number" => "123"
    }
    after = "ABC123"

    expected_query = "query {
        repository(owner: \"test_owner\", name:\"test_repo\") {
          pullRequest(number: 123) {
            number additions deletions changedFiles mergeable merged headRefOid
              commits(first:100 after:\"ABC123\"){
                totalCount
                  pageInfo{
                    hasNextPage startCursor endCursor
                    }
                      edges{
                        node{
                          id  commit{
                                author{
                                  name email
                                }
                               additions deletions changedFiles committedDate
                        }}}}}}}"

    assert_equal expected_query, Metric.pull_query(hyperlink_data, after)[:query]
  end

  test "repo_query returns correct GraphQL query text" do
    hyperlink_data = {
      "owner_name" => "test_owner",
      "repository_name" => "test_repo"
    }
    date = Time.now
    after = "ABC123"

    expected_query = "query {
        repository(owner: \"test_owner\", name: \"test_repo\") {
          ref(qualifiedName: \"master\") {
            target {
              ... on Commit {
                id
                  history(after:\"ABC123\" since:\"#{date.to_time.iso8601.to_s[0..18]}\") {
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
      }"

    assert_equal expected_query, Metric.repo_query(hyperlink_data, date, after)[:query]
  end
end
