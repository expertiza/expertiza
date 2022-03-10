class CreateQuizResponses < ActiveRecord::Migration[4.2]
  def self.up
    create_table :quiz_responses do |t|
      t.text :response
      t.references :assignment, :integer
      t.references :questionnaire, :integer
      t.references :question, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :quiz_responses
  end
end
