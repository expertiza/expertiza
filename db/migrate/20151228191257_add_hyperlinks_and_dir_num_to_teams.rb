class AddHyperlinksAndDirNumToTeams < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :submitted_hyperlinks, :text
    add_column :teams, :directory_num, :integer

    teams = AssignmentTeam.all
    teams.each do |team|
      participants = team.participants
      next if participants.empty?

      team.directory_num = participants.first.directory_num
      hyperlinks = []
      participants.each do |participant|
        participant_hyperlinks_array = participant.hyperlinks_array
        hyperlinks += participant_hyperlinks_array
      end

      hyperlinks = hyperlinks.uniq
      team.submitted_hyperlinks = YAML.dump(hyperlinks)
      team.save
    end
  end
end
