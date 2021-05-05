class Metric < ActiveRecord::Base

  # Generate the graphQL query text for a PULL REQUEST link, based on the link data and "after", which is a pointer
  # provided by the Github API to where the last query left off. Used to handle pulls containing more than 100 commits.
  def self.pull_query(hyperlink_data, after)
    {
      query: "query {
        repository(owner: \"" + hyperlink_data["owner_name"] + "\", name:\"" + hyperlink_data["repository_name"] + "\") {
          pullRequest(number: " + hyperlink_data["pull_request_number"] + ") {
            number additions deletions changedFiles mergeable merged headRefOid
              commits(first:100 #{ "after:\""+ after + "\"" unless after.nil? }){
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
    }
  end

  # Generate the graphQL query text for a REPOSITORY link, based on the link data and "after", which is a pointer
  # provided by the Github API to where the last query left off. Used to handle repositories containing more than 100 commits.
  def self.repo_query(hyperlink_data, date, after=nil)
    date = date.to_time.iso8601.to_s[0..18] # Format assignment start date for github api
    { query: "query {
        repository(owner: \"" + hyperlink_data["owner_name"] + "\", name: \"" + hyperlink_data["repository_name"] + "\") {
          ref(qualifiedName: \"master\") {
            target {
              ... on Commit {
                id
                  history(#{ "after:\""+ after + "\"" unless after.nil? } since:\"#{date}\") {
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
    }
  end
end
