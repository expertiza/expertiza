class Metric < ActiveRecord::Base

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

  # Return true if the author is on the "blacklist" of expertiza development team members
  def self.blacklist_author(author_name)
    expertiza_devs_list =
      ["Saurabh Shingte",
       "Expertiza Developer",
       "Saurabh Vinod Shingte",
       "Winbobob"
      ]
    expertiza_devs_list.member?(author_name)
  end

  private

end
