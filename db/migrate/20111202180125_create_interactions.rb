class CreateInteractions < ActiveRecord::Migration
   def self.up
      create_table "interactions", :force => true do |t|
        t.column "interaction_datetime", :datetime # the question content
        t.column "number_of_minutes", :integer # is this a true/false question?
        t.column "comments", :text # the scoring weight
        t.column "score", :integer # the questionnaire to which this question belongs
        t.column "type", :string
        t.column "participant_id", :integer
        t.column "team_id", :integer
        t.column "status", :string
      end

      add_index "interactions", ["participant_id"], :name => "fk_participants"

      execute "alter table interactions
                 add constraint fk_participants
                 foreign key (participant_id) references participants(id)"

      add_index "interactions", ["team_id"], :name => "fk_teams"

      execute "alter table interactions
                 add constraint fk_teams
                 foreign key (team_id) references teams(id)"

   end

  def self.down
    drop_table :interactions
  end
end
