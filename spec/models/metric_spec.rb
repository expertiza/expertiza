describe Metric do

  describe 'pull_query' do

    it 'constructs the query for the first page' do
      query = {
        query: "query {
  repository(owner: \"expertiza\", name: \"expertiza\") {
    pullRequest(number: 1228) {
      number additions deletions changedFiles mergeable merged headRefOid
      commits(first: 100 ) {
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
}"
      }
      hyperlink_data = {}
      hyperlink_data["owner_name"] = "expertiza"
      hyperlink_data["repository_name"] = "expertiza"
      hyperlink_data["pull_request_number"] = "1228"
      response = Metric.pull_query(hyperlink_data)
      expect(response.strip).to eq(query[:query])
    end
  end
end
