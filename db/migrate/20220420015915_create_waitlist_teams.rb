class CreateWaitlistTeams < ActiveRecord::Migration[5.1]

  def self.up
    create_table 'waitlist_teams' do |t|
      t.column 'team_id', :integer
      t.column 'topic_id', :integer
      t.timestamps
    end

    add_index 'waitlist_teams', ['team_id'], name: 'fk_waitlist_teams'

    execute "alter table waitlist_teams
                 add constraint fk_waitlist_teams
                 foreign key (team_id) references teams(id)"

    add_index 'waitlist_teams', ['topic_id'], name: 'fk_waitlist_teams_sign_up_topics'

    execute "alter table waitlist_teams
               add constraint fk_waitlist_teams_sign_up_topics
               foreign key (topic_id) references sign_up_topics(id)"
  end

  def self.down
    drop_table 'waitlist_teams'
  end
end
