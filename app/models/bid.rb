class Bid < ApplicationRecord
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :team

  # Create new bids for team based on `ranks` variable for each team member
  # Structure of users_bidding_info variable:
  # [[topic_1_priority, topic_2_priority, ...], [topic_1_priority, topic_2_priority, ...], ...]
  # Currently, it is possible (already proved by db records) that
  # some teams have multiple 1st priority, multiply 2nd priority.
  # these multiple identical priorities come from different
  # previous teams
  # [Future work]: we need to find a better way to merge bids
  # that came from different previous teams
  def self.merge_bids_from_different_users(team_id, sign_up_topics, users_bidding_info)
    # Select data from `users_bidding_info` variable and transpose it.
    # For example, if users_bidding_infos is [[1, 0, 2, 2], [2, 1, 3, 0], [3, 2, 1, 1]]
    # transformation's result will be matrix with 4 topics (key) and corresponding priorities
    # given by 3 team members (value).
    # {
    #   1: [1, 2, 3],
    #   2: [0, 1, 2],
    #   3: [2, 3, 1],
    #   4: [2, 0, 1]
    # }
    bidding_matrix = Hash.new { |hash, key| hash[key] = [] }
    users_bidding_info.each do |bids|
      sign_up_topics.each_with_index do |topic, index|
        bidding_matrix[topic.id] << bids[index]
      end
    end

    # Below is the structure of matrix summary
    # The first value is the number of nonzero item, the second value is the sum of priorities, the third value of the topic_id.
    # [
    #   [3, 6, 1],
    #   [2, 3, 2],
    #   [3, 6, 3],
    #   [2, 3, 4]
    # ]
    bidding_matrix_summary = []
    bidding_matrix.each do |topic_id, value|
      # Exclude topics that no one bid for
      bidding_matrix_summary << [value.count { |i| i != 0 }, value.inject(:+), topic_id] unless value.inject(:+).zero?
    end
    bidding_matrix_summary.sort! { |b1, b2| [b2[0], b1[1]] <=> [b1[0], b2[1]] }
    # Result of sorting first element descendingly and second element ascendingly.
    # We want the topic with most bids and lowest sum of priorities at the top.
    # [
    #   [3, 6, 1],
    #   [3, 6, 3],
    #   [2, 3, 2],
    #   [2, 3, 4]
    # ]
    # Therefore the bidding priority of these 4 topics is 1 -> 3 -> 2 -> 4
    bidding_matrix_summary.each_with_index do |b, index|
      Bid.create(topic_id: b[2], team_id: team_id, priority: index + 1)
    end
  end
end
