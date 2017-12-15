# This rspec file is used to test that the TrelloMetricsFetcher can do:
# 1. checks whether the fetcher supports the url or not.
# 2. the fetcher can fetch the data from the test trello board.

describe "TrelloMetricsFetcher" do
  it "supports url given by user" do
    expect(TrelloMetricsFetcher.supports_url?("https://trello.com/b/rU4qGAt4/517-test-board")).to be true
  end

  it "doesn't support url given by user" do
    expect(TrelloMetricsFetcher.supports_url?("https://trello.com/")).to be false
  end

  it "fetches stats from trello" do
    params = {url: "https://trello.com/b/rU4qGAt4/517-test-board"}
    fetcher = TrelloMetricsFetcher.new(params)
    fetcher.fetch_content
    expect(fetcher.is_loaded?).to be true
    expect(fetcher.board_id).to eq "rU4qGAt4"
    expect(fetcher.total_items).to eq 11
    expect(fetcher.checked_items).to eq 3
  end
end
