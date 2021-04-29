describe Metric do

  describe 'pull_query' do
    it 'constructs the query for the first page' do
      query = {
        query: "query {
        repository(owner: \"expertiza\", name:\"expertiza\") {
          pullRequest(number: 1228) {
            number additions deletions changedFiles mergeable merged headRefOid
              commits(first:100 ){
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
      hyperlink_data = {}
      hyperlink_data["owner_name"] = "expertiza"
      hyperlink_data["repository_name"] = "expertiza"
      hyperlink_data["pull_request_number"] = "1228"
      response = Metric.pull_query(hyperlink_data, nil)
      expect(response).to eq(query)
    end

    it 'constructs the query for additional pages after 100 commits' do
      query = {
        query: "query {
        repository(owner: \"expertiza\", name:\"expertiza\") {
          pullRequest(number: 1228) {
            number additions deletions changedFiles mergeable merged headRefOid
              commits(first:100 after:\"pointer\"){
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
      hyperlink_data = {}
      hyperlink_data["owner_name"] = "expertiza"
      hyperlink_data["repository_name"] = "expertiza"
      hyperlink_data["pull_request_number"] = "1228"
      after="pointer" # In production, this will be a github SHA1 hash
      response = Metric.pull_query(hyperlink_data, after)
      expect(response).to eq(query)
    end
  end

  describe 'repo_query' do
    it 'constructs the query for the first page' do
      date = DateTime.yesterday
      query = {
        query: "query {
        repository(owner: \"expertiza\", name: \"expertiza\") {
          ref(qualifiedName: \"master\") {
            target {
              ... on Commit {
                id
                  history( since:\"#{date.to_time.iso8601.to_s[0..18]}\") {
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
      hyperlink_data = {}
      hyperlink_data["owner_name"] = "expertiza"
      hyperlink_data["repository_name"] = "expertiza"
      response = Metric.repo_query(hyperlink_data, date, nil)
      expect(response).to eq(query)
    end

    it 'constructs the query for additional pages after 100 commits' do
      date = DateTime.yesterday
      query = {
        query: "query {
        repository(owner: \"expertiza\", name: \"expertiza\") {
          ref(qualifiedName: \"master\") {
            target {
              ... on Commit {
                id
                  history(after:\"pointer\" since:\"#{date.to_time.iso8601.to_s[0..18]}\") {
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
      hyperlink_data = {}
      hyperlink_data["owner_name"] = "expertiza"
      hyperlink_data["repository_name"] = "expertiza"
      hyperlink_data["pull_request_number"] = "1228"
      after="pointer" # In production, this will be a github SHA1 hash
      response = Metric.repo_query(hyperlink_data, date, after)
      expect(response).to eq(query)
    end
  end

end